import * as admin from 'firebase-admin';

import { EquipmentService } from './equipment.service';
import type { CreateEquipmentDto } from './equipment.model';
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
  dryRun: boolean;
};

type GeminiEquipmentSuggestion = {
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

  // Query existing equipment first
  console.log('Querying existing equipment from Firestore...');
  const equipmentService = new EquipmentService();
  const existingEquipment = await equipmentService.getAllEquipment();
  const existingTitles = existingEquipment.map(eq => eq.title.en).filter((title): title is string => Boolean(title));
  
  console.log(`Found ${existingTitles.length} existing equipment items.`);
  if (existingTitles.length > 0) {
    console.log('Existing equipment:', existingTitles.join(', '));
  }

  console.log(`Requesting equipment items from Gemini (${model} @ ${location})...`);

  const prompt = buildEquipmentPrompt(existingTitles);
  const suggestions = await requestGeminiJson<GeminiEquipmentSuggestion[]>(generativeModel, prompt);
  const validSuggestions = filterValidSuggestions(suggestions);

  if (validSuggestions.length === 0) {
    console.warn('No valid equipment returned from Gemini. Nothing to insert.');
    return;
  }

  console.log(`Received ${validSuggestions.length} candidate equipment items. Preparing to ${options.dryRun ? 'preview' : 'insert'}...`);

  const skipped: string[] = [];
  const inserted: string[] = [];

  for (const suggestion of validSuggestions) {
    const englishTitle = suggestion.title.en?.trim();
    if (!englishTitle) {
      skipped.push('(missing English title)');
      continue;
    }

    try {
      // Check if equipment already exists
      const existingEquipment = await equipmentService.getEquipment(englishTitle.toLowerCase().replace(/\s+/g, '-'));
      if (existingEquipment) {
        skipped.push(`${englishTitle} (already exists)`);
        continue;
      }
    } catch {
      // Equipment doesn't exist, continue with creation
    }

    const equipmentData: CreateEquipmentDto = {
      title: suggestion.title,
      image: null
    };

    if (!options.dryRun) {
      try {
        await equipmentService.createEquipment(equipmentData);
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

function buildEquipmentPrompt(existingTitles: string[]): string {
  let prompt = 'You are an expert mixologist helping seed a cocktail bar database. Generate a comprehensive list of common and essential equipment used in cocktail preparation and bartending. ' +
    'Return ONLY valid JSON (no markdown). The JSON must be an array where each element has:\n' +
    '{\n' +
    '  "title": { "en": "English name", "uk": "Ukrainian translation" }\n' +
    '}\n' +
    'Include essential bar tools and glassware:\n' +
    '1. Basic bar tools: Shaker (just one generic shaker, not specific types), Strainer, Jigger, Muddler, Bar Spoon, Mixing Glass\n' +
    '2. Popular glassware types: Rocks Glass, Martini Glass, Highball Glass, Coupe Glass, Collins Glass, Shot Glass, Margarita Glass, Wine Glass, Champagne Flute\n' +
    '3. Other essential tools: Ice Bucket, Cocktail Picks, Cutting Board, Knife, Citrus Juicer, Bottle Opener, Corkscrew\n' +
    'Use generic, common names (e.g., "Shaker" not "Boston Shaker" or "French Shaker"). Ensure Ukrainian translations are natural (not transliterations).';
  
  if (existingTitles.length > 0) {
    prompt += '\n\nIMPORTANT: The following equipment already exists in the database. DO NOT include these items in your response:\n';
    prompt += existingTitles.map(title => `- ${title}`).join('\n');
    prompt += '\n\nGenerate NEW equipment items that are NOT in the list above.';
  }
  
  prompt += ' Respond with compact JSON.';
  
  return prompt;
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
