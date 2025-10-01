import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';

import type { EquipmentDocument } from './equipment.model';
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
};

type GeminiEquipmentSuggestion = {
  title: Record<SupportedLocale, string>;
  image?: string;
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

  console.log(`Requesting equipment items from Gemini (${model} @ ${location})...`);

  const prompt = buildEquipmentPrompt();
  const suggestions = await requestGeminiJson<GeminiEquipmentSuggestion[]>(generativeModel, prompt);
  const validSuggestions = filterValidSuggestions(suggestions);

  if (validSuggestions.length === 0) {
    console.warn('No valid equipment returned from Gemini. Nothing to insert.');
    return;
  }

  console.log(`Received ${validSuggestions.length} candidate equipment items. Preparing to ${options.dryRun ? 'preview' : 'insert'}...`);

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

    const docRef = firestore.collection('equipment').doc(docId);
    const snapshot = await docRef.get();
    if (snapshot.exists) {
      skipped.push(`${englishTitle} (already exists)`);
      continue;
    }

    const docData: EquipmentDocument = {
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
  let dryRun = false;

  for (let i = 0; i < args.length; i += 1) {
    const arg = args[i];
    switch (arg) {
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
        console.warn(`Ignoring unknown argument: ${arg}`);
        break;
    }
  }

  return {
    dryRun
  };
}

function printUsage(): void {
  console.log('\nUsage: pnpm build && node lib/equipment/equipment.seed.js [--dry-run]\n');
  console.log('Arguments:');
  console.log('  --dry-run, -d   Preview results without writing to Firestore');
}

function buildEquipmentPrompt(): string {
  return 'You are an expert mixologist helping seed a cocktail bar database. Generate a comprehensive list of unique pieces of equipment commonly used in cocktail preparation and bartending. ' +
    'Return ONLY valid JSON (no markdown). The JSON must be an array where each element has:\n' +
    '{\n' +
    '  "title": { "en": "English name", "uk": "Ukrainian translation" },\n' +
    '  "image"?: "Optional short description of the image or image URL"\n' +
    '}\n' +
    'Include essential bar tools like shakers, strainers, jiggers, muddlers, bar spoons, mixing glasses, ice tools, garnish tools, measuring tools, glassware accessories, and any other relevant bartending equipment. ' +
    'Ensure translations are natural (not transliterations) where possible. Respond with compact JSON.';
}

function filterValidSuggestions(suggestions: GeminiEquipmentSuggestion[]): GeminiEquipmentSuggestion[] {
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
