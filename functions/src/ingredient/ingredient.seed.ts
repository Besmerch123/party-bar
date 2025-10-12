import * as admin from 'firebase-admin';

import { IngredientService } from './ingredient.service';
import {
  INGREDIENT_CATEGORIES,
  type IngredientCategory,
  type CreateIngredientDto
} from './ingredient.model';
import { SUPPORTED_LOCALES, type SupportedLocale } from '../shared/types';
import {
  getProjectId,
  initializeVertexAI,
  getVertexModel,
  getVertexLocation,
  requestGeminiJson,
  hasAllLocaleTitles
} from '../shared/cli-tools';

type CliOptions = {
  category: IngredientCategory;
  dryRun: boolean;
};

type GeminiIngredientSuggestion = {
  title: Record<SupportedLocale, string>;
};

if (admin.apps.length === 0) {
  admin.initializeApp();
}

async function main(): Promise<void> {
  const options = parseCliArguments();

  const projectId = getProjectId();
  if (!projectId) {
    throw new Error(
      'Unable to determine project ID. Set GOOGLE_CLOUD_PROJECT, GCLOUD_PROJECT, or FIREBASE_CONFIG.'
    );
  }

  const vertexAI = initializeVertexAI(projectId);
  const model = getVertexModel();
  const location = getVertexLocation();
  const generativeModel = vertexAI.getGenerativeModel({ model });

  // Query existing ingredients from the category first
  console.log(`Querying existing "${options.category}" ingredients from Firestore...`);
  const ingredientService = new IngredientService();
  const existingIngredients = await ingredientService.getIngredientsByCategory(options.category);
  const existingTitles = existingIngredients.map(ing => ing.title.en).filter((title): title is string => Boolean(title));
  
  console.log(`Found ${existingTitles.length} existing ingredients in "${options.category}" category.`);
  if (existingTitles.length > 0) {
    console.log('Existing ingredients:', existingTitles.join(', '));
  }

  console.log(`Requesting "${options.category}" ingredients from Gemini (${model} @ ${location})...`);

  const prompt = buildIngredientPrompt(options.category, existingTitles);
  const suggestions = await requestGeminiJson<GeminiIngredientSuggestion[]>(generativeModel, prompt);
  const validSuggestions = filterValidSuggestions(suggestions);

  if (validSuggestions.length === 0) {
    console.warn('No valid ingredients returned from Gemini. Nothing to insert.');
    return;
  }

  console.log(`Received ${validSuggestions.length} candidate ingredients. Preparing to ${options.dryRun ? 'preview' : 'insert'}...`);

  const skipped: string[] = [];
  const inserted: string[] = [];

  for (const suggestion of validSuggestions) {
    const englishTitle = suggestion.title.en?.trim();
    if (!englishTitle) {
      skipped.push('(missing English title)');
      continue;
    }

    try {
      // Check if ingredient already exists
      const existingIngredient = await ingredientService.getIngredient(
        `${options.category}-${englishTitle.toLowerCase().replace(/\s+/g, '-')}`
      );
      if (existingIngredient) {
        skipped.push(`${englishTitle} (already exists)`);
        continue;
      }
    } catch {
      // Ingredient doesn't exist, continue with creation
    }

    const ingredientData: CreateIngredientDto = {
      title: suggestion.title,
      category: options.category,
      image: null
    };

    if (!options.dryRun) {
      try {
        await ingredientService.createIngredient(ingredientData);
        inserted.push(englishTitle);
      } catch (error) {
        skipped.push(`${englishTitle} (creation failed: ${error})`);
      }
    } else {
      inserted.push(englishTitle);
    }
  }

  console.log('\n=== Seed Summary ===');
  console.log(`Mode: ${options.dryRun ? 'DRY-RUN (no writes)' : 'WRITE'}`);
  console.log(`Inserted (${inserted.length}):`);
  inserted.forEach((entry) => console.log(`  • ${entry}`));

  if (skipped.length > 0) {
    console.log(`\nSkipped (${skipped.length}):`);
    skipped.forEach((entry) => console.log(`  • ${entry}`));
  }
}

function parseCliArguments(): CliOptions {
  const args = process.argv.slice(2);
  let category: string | undefined;
  let dryRun = false;

  for (let i = 0; i < args.length; i += 1) {
    const arg = args[i];
    switch (arg) {
      case '--category':
      case '-c':
        category = args[i + 1];
        i += 1;
        break;
      case '--dry-run':
      case '--dryrun':
      case '-d':
        dryRun = true;
        break;
      case '--help':
      case '-h':
        printUsage();
        process.exit(0);
        break;
      default:
        if (!arg.startsWith('-') && !category) {
          category = arg;
        } else {
          console.warn(`Ignoring unknown argument: ${arg}`);
        }
        break;
    }
  }

  if (!category) {
    printUsage();
    throw new Error('Missing ingredient category. Provide via --category <value>.');
  }

  const categoryValue = category.toLowerCase();
  const validCategory = Object.values(INGREDIENT_CATEGORIES).find((value) => value === categoryValue);

  if (!validCategory) {
    const available = Object.values(INGREDIENT_CATEGORIES).join(', ');
    throw new Error(`Invalid category "${category}". Choose one of: ${available}`);
  }

  return {
    category: validCategory,
    dryRun
  };
}

function printUsage(): void {
  console.log('\nUsage: pnpm build && node lib/ingredient/seed.js --category <category> [--dry-run]\n');
  console.log('Arguments:');
  console.log('  --category, -c  Ingredient category to generate (required)');
  console.log('  --dry-run, -d   Preview results without writing to Firestore');
}

function buildIngredientPrompt(category: IngredientCategory, existingTitles: string[]): string {
  let prompt = `You are an expert mixologist helping seed a cocktail bar database. Generate unique ingredients that belong to the "${category}" category. ` +
    'Return ONLY valid JSON (no markdown). The JSON must be an array where each element has:\n' +
    '{\n' +
    '  "title": { "en": "English name", "uk": "Ukrainian translation" }\n' +
    '}\n' +
    'Ensure translations are natural (not transliterations) where possible. Favour well-known bar ingredients.';
  
  if (existingTitles.length > 0) {
    prompt += `\n\nIMPORTANT: The following "${category}" ingredients already exist in the database. DO NOT include these items in your response:\n`;
    prompt += existingTitles.map(title => `- ${title}`).join('\n');
    prompt += `\n\nGenerate NEW "${category}" ingredients that are NOT in the list above.`;
  }
  
  prompt += ' Respond with compact JSON.';
  
  return prompt;
}

function filterValidSuggestions(suggestions: GeminiIngredientSuggestion[]): GeminiIngredientSuggestion[] {
  return suggestions.filter((suggestion) => {
    if (!suggestion || typeof suggestion !== 'object') {
      return false;
    }

    return hasAllLocaleTitles(suggestion.title, SUPPORTED_LOCALES);
  });
}

void main().catch((error) => {
  console.error('Seed script failed:', error);
  process.exitCode = 1;
});
