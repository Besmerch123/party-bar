import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';

import {
  INGREDIENT_CATEGORIES,
  type IngredientCategory,
  type IngredientDocument
} from './ingredient.model';
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
  category: IngredientCategory;
  dryRun: boolean;
};

type GeminiIngredientSuggestion = {
  title: Record<SupportedLocale, string>;
  image?: string;
  notes?: string;
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

  const vertexAI = initializeVertexAI(projectId);
  const model = getVertexModel();
  const location = getVertexLocation();
  const generativeModel = vertexAI.getGenerativeModel({ model });

  console.log(`Requesting "${options.category}" ingredients from Gemini (${model} @ ${location})...`);

  const prompt = buildIngredientPrompt(options.category);
  const suggestions = await requestGeminiJson<GeminiIngredientSuggestion[]>(generativeModel, prompt);
  const validSuggestions = filterValidSuggestions(suggestions);

  if (validSuggestions.length === 0) {
    console.warn('No valid ingredients returned from Gemini. Nothing to insert.');
    return;
  }

  console.log(`Received ${validSuggestions.length} candidate ingredients. Preparing to ${options.dryRun ? 'preview' : 'insert'}...`);

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

    const docId = createSlug(`${options.category}-${englishTitle}`);
    if (!docId) {
      skipped.push(`${englishTitle} (invalid slug)`);
      continue;
    }

    const docRef = firestore.collection('ingredients').doc(docId);
    const snapshot = await docRef.get();
    if (snapshot.exists) {
      skipped.push(`${englishTitle} (already exists)`);
      continue;
    }

    const docData: IngredientDocument = {
      category: options.category,
      title: suggestion.title,
      createdAt: now,
      updatedAt: now,
      ...(suggestion.image?.trim() ? { image: suggestion.image.trim() } : {})
    };

    if (!options.dryRun) {
      batch.set(docRef, docData);
    }

    inserted.push(`${englishTitle} [${docId}]`);
  }

  if (!options.dryRun && inserted.length > 0) {
    await batch.commit();
  }

  console.log('\n=== Seed Summary ===');
  console.log(`Mode: ${options.dryRun ? 'DRY-RUN (no writes)' : 'WRITE'}`);
  console.log(`Inserted (${inserted.length}):`);
  inserted.forEach((entry) => console.log(`  • ${entry}`));

  console.log(`Skipped (${skipped.length}):`);
  skipped.forEach((entry) => console.log(`  • ${entry}`));
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

function buildIngredientPrompt(category: IngredientCategory): string {
  return `You are an expert mixologist helping seed a cocktail bar database. Generate unique ingredients that belong to the "${category}" category. ` +
    'Return ONLY valid JSON (no markdown). The JSON must be an array where each element has:\n' +
    '{\n' +
    '  "title": { "en": "English name", "uk": "Ukrainian translation" },\n' +
    '  "image"?: "Optional short description of the image or image URL",\n' +
    '  "notes"?: "Brief note about flavour or usage"\n' +
    '}\n' +
    'Ensure translations are natural (not transliterations) where possible. Favour well-known bar ingredients. Respond with compact JSON.';
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
