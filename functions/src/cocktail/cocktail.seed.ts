import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';

import type { CocktailDocument } from './cocktail.model';
import { COCKTAIL_CATEGORIES, type CocktailCategory } from './cocktail.model';
import type { IngredientDocument } from '../ingredient/ingredient.model';
import type { EquipmentDocument } from '../equipment/equipment.model';
import { SUPPORTED_LOCALES, type SupportedLocale } from '../shared/types';
import {
  getProjectId,
  initializeVertexAI,
  getVertexModel,
  getVertexLocation,
  requestGeminiJson,
  createSlug,
  hasAllLocaleTitles
} from '../shared/cli-tools';

type CliOptions = {
  dryRun: boolean;
  count: number;
};

type GeminiCocktailSuggestion = {
  title: Record<SupportedLocale, string>;
  description: Record<SupportedLocale, string>;
  ingredients: string[];
  equipments: string[];
  categories: CocktailCategory[];
};

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const firestore = admin.firestore();

async function main(): Promise<void> {
  const options = parseCliArguments();

  const projectId = getProjectId();
  if (!projectId) {
    throw new Error(
      'Unable to determine project ID. Set GOOGLE_CLOUD_PROJECT, GCLOUD_PROJECT, or FIREBASE_CONFIG.'
    );
  }

  console.log('Fetching existing data from Firestore...');
  
  // Fetch existing cocktails to avoid duplicates
  const existingCocktails = await fetchExistingCocktails();
  console.log(`Found ${existingCocktails.size} existing cocktails.`);

  // Fetch available ingredients
  const availableIngredients = await fetchAvailableIngredients();
  if (availableIngredients.length === 0) {
    throw new Error('No ingredients found in database. Please seed ingredients first.');
  }
  console.log(`Found ${availableIngredients.length} available ingredients.`);

  // Fetch available equipment
  const availableEquipment = await fetchAvailableEquipment();
  if (availableEquipment.length === 0) {
    throw new Error('No equipment found in database. Please seed equipment first.');
  }
  console.log(`Found ${availableEquipment.length} available equipment items.`);

  const vertexAI = initializeVertexAI(projectId);
  const model = getVertexModel();
  const location = getVertexLocation();
  const generativeModel = vertexAI.getGenerativeModel({ model });

  console.log(`\nRequesting ${options.count} cocktail(s) from Gemini (${model} @ ${location})...`);

  const prompt = buildCocktailPrompt(
    options.count,
    availableIngredients,
    availableEquipment,
    existingCocktails
  );
  
  const suggestions = await requestGeminiJson<GeminiCocktailSuggestion[]>(
    generativeModel, 
    prompt,
    0.7 // Higher temperature for more creative cocktails
  );
  
  const validSuggestions = filterValidSuggestions(
    suggestions,
    availableIngredients,
    availableEquipment,
    existingCocktails
  );

  if (validSuggestions.length === 0) {
    console.warn('No valid cocktails returned from Gemini. Nothing to insert.');
    return;
  }

  console.log(`\nReceived ${validSuggestions.length} valid cocktail(s). Preparing to ${options.dryRun ? 'preview' : 'insert'}...`);

  const now = Timestamp.now();
  const batch = firestore.batch();
  const skipped: string[] = [];
  const inserted: string[] = [];

  for (const suggestion of validSuggestions) {
    const englishTitle = suggestion.title.en?.trim();
    if (!englishTitle) {
      skipped.push('(missing English title)');
      continue;
    }

    const docId = createSlug(englishTitle);
    if (!docId) {
      skipped.push(`${englishTitle} (invalid slug)`);
      continue;
    }

    // Double-check it doesn't exist (in case Gemini ignored our list)
    if (existingCocktails.has(docId)) {
      skipped.push(`${englishTitle} (already exists)`);
      continue;
    }

    const docRef = firestore.collection('cocktails').doc(docId);
    
    const docData: CocktailDocument = {
      title: suggestion.title,
      description: suggestion.description,
      abv: undefined, // To be calculated later
      preparationSteps: { en: [], uk: [] }, // To be filled in later
      ingredients: suggestion.ingredients.map(id => `ingredients/${id}`),
      equipments: suggestion.equipments.map(id => `equipment/${id}`),
      categories: suggestion.categories,
      image: null, // To be added later
      createdAt: now,
      updatedAt: now
    };

    if (!options.dryRun) {
      batch.set(docRef, docData);
    }

    inserted.push(`${englishTitle} [${docId}] - ${suggestion.ingredients.length} ingredients, ${suggestion.equipments.length} equipment`);
  }

  if (!options.dryRun && inserted.length > 0) {
    await batch.commit();
  }

  console.log('\n=== Seed Summary ===');
  console.log(`Mode: ${options.dryRun ? 'DRY-RUN (no writes)' : 'WRITE'}`);
  console.log(`Requested: ${options.count} cocktail(s)`);
  console.log(`Inserted (${inserted.length}):`);
  inserted.forEach((entry) => console.log(`  • ${entry}`));

  if (skipped.length > 0) {
    console.log(`\nSkipped (${skipped.length}):`);
    skipped.forEach((entry) => console.log(`  • ${entry}`));
  }
}

function parseCliArguments(): CliOptions {
  const args = process.argv.slice(2);
  let dryRun = false;
  let count = 1; // Default to 1 cocktail

  for (let i = 0; i < args.length; i += 1) {
    const arg = args[i];
    switch (arg) {
      case '--dry-run':
      case '--dryrun':
      case '-d':
        dryRun = true;
        break;
      case '--count':
      case '-c': {
        const nextArg = args[i + 1];
        if (!nextArg || Number.isNaN(Number(nextArg))) {
          console.error('Error: --count requires a numeric argument');
          printUsage();
          process.exit(1);
        }
        count = parseInt(nextArg, 10);
        if (count < 1 || count > 100) {
          console.error('Error: --count must be between 1 and 100');
          process.exit(1);
        }
        i += 1; // Skip the next argument
        break;
      }
      case '--help':
      case '-h':
        printUsage();
        process.exit(0);
        break;
      default:
        console.warn(`Ignoring unknown argument: ${arg}`);
        break;
    }
  }

  return {
    dryRun,
    count
  };
}

function printUsage(): void {
  console.log('\nUsage: pnpm build && node lib/cocktail/cocktail.seed.js [options]\n');
  console.log('Options:');
  console.log('  --count, -c <number>  Number of cocktails to generate (default: 1, max: 100)');
  console.log('  --dry-run, -d         Preview results without writing to Firestore');
  console.log('  --help, -h            Show this help message');
  console.log('\nExamples:');
  console.log('  node lib/cocktail/cocktail.seed.js --count 5');
  console.log('  node lib/cocktail/cocktail.seed.js -c 10 --dry-run');
}

async function fetchExistingCocktails(): Promise<Set<string>> {
  const snapshot = await firestore.collection('cocktails').select().get();
  return new Set(snapshot.docs.map(doc => doc.id));
}

async function fetchAvailableIngredients(): Promise<Array<{ id: string; title: string }>> {
  const snapshot = await firestore.collection('ingredients').get();
  return snapshot.docs.map(doc => {
    const data = doc.data() as IngredientDocument;
    return {
      id: doc.id,
      title: data.title.en || doc.id
    };
  });
}

async function fetchAvailableEquipment(): Promise<Array<{ id: string; title: string }>> {
  const snapshot = await firestore.collection('equipment').get();
  return snapshot.docs.map(doc => {
    const data = doc.data() as EquipmentDocument;
    return {
      id: doc.id,
      title: data.title.en || doc.id
    };
  });
}

function buildCocktailPrompt(
  count: number,
  ingredients: Array<{ id: string; title: string }>,
  equipment: Array<{ id: string; title: string }>,
  existingCocktails: Set<string>
): string {
  const categoriesList = Object.values(COCKTAIL_CATEGORIES).join(', ');
  
  const ingredientsList = ingredients
    .map(ing => `  - ${ing.id}: ${ing.title}`)
    .join('\n');
  
  const equipmentList = equipment
    .map(eq => `  - ${eq.id}: ${eq.title}`)
    .join('\n');

  const existingList = Array.from(existingCocktails).slice(0, 50).join(', ');
  const existingNote = existingCocktails.size > 0 
    ? `\n\nIMPORTANT: Do NOT generate any of these existing cocktails: ${existingList}${existingCocktails.size > 50 ? '...' : ''}`
    : '';

  return `You are an expert mixologist creating a sophisticated cocktail database. Generate ${count} unique, creative cocktail recipe(s).

CRITICAL REQUIREMENTS:
1. Use ONLY ingredient IDs from this list (use the ID, not the title):
${ingredientsList}

2. Use ONLY equipment IDs from this list (use the ID, not the title):
${equipmentList}

3. Each cocktail MUST include:
   - 2-6 ingredients (reference by their IDs)
   - 2-4 equipment items (reference by their IDs)
   - 1-3 categories from: ${categoriesList}
   - Bilingual title (English and Ukrainian)
   - Bilingual description (English and Ukrainian)

4. Descriptions should be concise (1-3 sentences):
   - Brief flavor profile
   - Overall character and appeal
   - DO NOT include preparation instructions (that will be added later)
${existingNote}

Return ONLY valid JSON (no markdown). The JSON must be an array where each element has:
{
  "title": { 
    "en": "English cocktail name", 
    "uk": "Ukrainian cocktail name (natural translation, not transliteration)" 
  },
  "description": { 
    "en": "Brief English description (1-3 sentences about flavor and character)", 
    "uk": "Brief Ukrainian description (1-3 sentences about flavor and character)" 
  },
  "ingredients": ["ingredient-id-1", "ingredient-id-2", ...],
  "equipments": ["equipment-id-1", "equipment-id-2", ...],
  "categories": ["category1", "category2", ...]
}

Be creative with combinations, but ensure all recipes are practical and delicious. Include classic cocktails with modern twists, seasonal variations, and original creations. Respond with compact JSON.`;
}

function filterValidSuggestions(
  suggestions: GeminiCocktailSuggestion[],
  availableIngredients: Array<{ id: string; title: string }>,
  availableEquipment: Array<{ id: string; title: string }>,
  existingCocktails: Set<string>
): GeminiCocktailSuggestion[] {
  const ingredientIds = new Set(availableIngredients.map(ing => ing.id));
  const equipmentIds = new Set(availableEquipment.map(eq => eq.id));
  const validCategories = new Set(Object.values(COCKTAIL_CATEGORIES));

  return suggestions.filter((suggestion) => {
    if (!suggestion || typeof suggestion !== 'object') {
      console.warn('Invalid suggestion object:', suggestion);
      return false;
    }

    // Validate title and description have all locales
    if (!hasAllLocaleTitles(suggestion.title, SUPPORTED_LOCALES)) {
      console.warn('Missing title translations:', suggestion.title);
      return false;
    }

    if (!hasAllLocaleTitles(suggestion.description, SUPPORTED_LOCALES)) {
      console.warn('Missing description translations:', suggestion.description);
      return false;
    }

    // Check if cocktail already exists
    const slug = createSlug(suggestion.title.en);
    if (existingCocktails.has(slug)) {
      console.warn(`Cocktail already exists: ${suggestion.title.en}`);
      return false;
    }

    // Validate ingredients
    if (!Array.isArray(suggestion.ingredients) || suggestion.ingredients.length < 2 || suggestion.ingredients.length > 6) {
      console.warn(`Invalid ingredients count for ${suggestion.title.en}: ${suggestion.ingredients?.length}`);
      return false;
    }

    const invalidIngredients = suggestion.ingredients.filter(id => !ingredientIds.has(id));
    if (invalidIngredients.length > 0) {
      console.warn(`Invalid ingredient IDs for ${suggestion.title.en}:`, invalidIngredients);
      return false;
    }

    // Validate equipment
    if (!Array.isArray(suggestion.equipments) || suggestion.equipments.length < 2 || suggestion.equipments.length > 4) {
      console.warn(`Invalid equipment count for ${suggestion.title.en}: ${suggestion.equipments?.length}`);
      return false;
    }

    const invalidEquipment = suggestion.equipments.filter(id => !equipmentIds.has(id));
    if (invalidEquipment.length > 0) {
      console.warn(`Invalid equipment IDs for ${suggestion.title.en}:`, invalidEquipment);
      return false;
    }

    // Validate categories
    if (!Array.isArray(suggestion.categories) || suggestion.categories.length === 0) {
      console.warn(`Missing categories for ${suggestion.title.en}`);
      return false;
    }

    const invalidCategories = suggestion.categories.filter(cat => !validCategories.has(cat));
    if (invalidCategories.length > 0) {
      console.warn(`Invalid categories for ${suggestion.title.en}:`, invalidCategories);
      return false;
    }

    return true;
  });
}

void main().catch((error) => {
  console.error('Seed script failed:', error);
  process.exitCode = 1;
});
