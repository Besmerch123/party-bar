/**
 * Generate Cocktail Endpoint
 * 
 * Generates a complete cocktail recipe using AI based on user's desired cocktail name.
 * Uses Gemini 2.5 Pro to generate all needed information including ABV and preparation steps.
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { VertexAI } from '@google-cloud/vertexai';
import * as admin from 'firebase-admin';

import type { CreateCocktailDto } from '../cocktail.model';
import { COCKTAIL_CATEGORIES, type CocktailCategory } from '../cocktail.model';
import type { IngredientDocument } from '../../ingredient/ingredient.model';
import type { EquipmentDocument } from '../../equipment/equipment.model';
import type { SupportedLocale } from '../../shared/types';
import { SUPPORTED_LOCALES } from '../../shared/types';
import { CocktailService } from '../cocktail.service';
import {
  extractTextResponse,
  parseJsonResponse,
  hasAllLocaleTitles,
} from '../../shared/cli-tools';

const cocktailService = new CocktailService();

interface GenerateCocktailRequest {
  /** Desired cocktail name in plain English */
  name: string;
  /** Optional: Additional preferences or notes */
  preferences?: string;
}

interface GeminiGeneratedCocktail {
  title: Record<SupportedLocale, string>;
  description: Record<SupportedLocale, string>;
  ingredients: string[];
  equipments: string[];
  categories: CocktailCategory[];
  abv: number;
  preparationSteps: Record<SupportedLocale, string[]>;
}

/**
 * Generates a cocktail recipe using AI
 */
export const generateCocktail = onCall<GenerateCocktailRequest>(async (request) => {
  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const requestData = request.data;

    if (!requestData?.name || typeof requestData.name !== 'string' || requestData.name.trim() === '') {
      throw new HttpsError('invalid-argument', 'Cocktail name is required');
    }

    const name = requestData.name.trim();
    const preferences = requestData.preferences?.trim() || '';

    console.log(`Generating cocktail: "${name}"${preferences ? ` with preferences: ${preferences}` : ''}`);

    // Initialize Vertex AI with Gemini 2.5 Pro
    const projectId = process.env.GCLOUD_PROJECT || process.env.GOOGLE_CLOUD_PROJECT;
    if (!projectId) {
      throw new HttpsError('internal', 'Project ID is not configured');
    }

    const location = process.env.GOOGLE_CLOUD_LOCATION || process.env.VERTEX_LOCATION || 'us-central1';
    const vertexAI = new VertexAI({ project: projectId, location });
    const model = 'gemini-2.5-pro'; // Using Gemini 2.5 Pro for high-quality generation
    const generativeModel = vertexAI.getGenerativeModel({ model });

    // Fetch available ingredients and equipment
    const firestore = admin.firestore();
    const [ingredientsSnapshot, equipmentSnapshot] = await Promise.all([
      firestore.collection('ingredients').get(),
      firestore.collection('equipment').get(),
    ]);

    const availableIngredients = ingredientsSnapshot.docs.map(doc => {
      const data = doc.data() as IngredientDocument;
      return {
        id: doc.id,
        title: data.title.en || doc.id,
      };
    });

    const availableEquipment = equipmentSnapshot.docs.map(doc => {
      const data = doc.data() as EquipmentDocument;
      return {
        id: doc.id,
        title: data.title.en || doc.id,
      };
    });

    if (availableIngredients.length === 0 || availableEquipment.length === 0) {
      throw new HttpsError('failed-precondition', 'No ingredients or equipment found in database');
    }

    // Build prompt for Gemini
    const prompt = buildGenerationPrompt(name, preferences, availableIngredients, availableEquipment);

    // Request generation from Gemini
    const result = await generativeModel.generateContent({
      contents: [
        {
          role: 'user',
          parts: [{ text: prompt }],
        },
      ],
      generationConfig: {
        responseMimeType: 'application/json',
        temperature: 0.7, // Higher temperature for creativity
        topP: 0.95,
        topK: 40,
      },
    });

    const textResponse = extractTextResponse(result);
    if (!textResponse) {
      throw new HttpsError('internal', 'AI did not return a valid response');
    }

    // Parse the response - it might be wrapped in an array
    const parsedResponse = parseJsonResponse<GeminiGeneratedCocktail | GeminiGeneratedCocktail[]>(textResponse);
    
    // Extract the cocktail data (handle both single object and array)
    const generatedData: GeminiGeneratedCocktail = Array.isArray(parsedResponse) 
      ? parsedResponse[0] 
      : parsedResponse;

    if (!generatedData) {
      throw new HttpsError('internal', 'AI returned empty response');
    }

    console.log('Validating generated cocktail', [generatedData]);

    // Validate the generated cocktail
    validateGeneratedCocktail(generatedData, availableIngredients, availableEquipment);

    // Convert to CreateCocktailDto
    const cocktailDto: CreateCocktailDto = {
      title: generatedData.title,
      description: generatedData.description,
      ingredients: generatedData.ingredients.map(id => `ingredients/${id}`),
      equipments: generatedData.equipments.map(id => `equipment/${id}`),
      categories: generatedData.categories,
      abv: generatedData.abv,
      preparationSteps: generatedData.preparationSteps,
    };

    // Create the cocktail
    const cocktail = await cocktailService.createCocktail(cocktailDto);

    console.log(`Successfully generated cocktail: ${cocktail.id}`);

    return  cocktail;
  } catch (error) {
    console.error('Error generating cocktail:', error);

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
      'internal',
      error instanceof Error ? error.message : 'An error occurred while generating the cocktail'
    );
  }
});

/**
 * Builds the prompt for Gemini to generate a cocktail
 */
function buildGenerationPrompt(
  name: string,
  preferences: string,
  ingredients: Array<{ id: string; title: string }>,
  equipment: Array<{ id: string; title: string }>
): string {
  const categoriesList = Object.values(COCKTAIL_CATEGORIES).join(', ');

  const ingredientsList = ingredients
    .map(ing => `  - ${ing.id}: ${ing.title}`)
    .join('\n');

  const equipmentList = equipment
    .map(eq => `  - ${eq.id}: ${eq.title}`)
    .join('\n');

  const preferencesNote = preferences
    ? `\n\nADDITIONAL PREFERENCES: ${preferences}`
    : '';

  return `You are an expert mixologist creating a sophisticated cocktail recipe database. Generate a complete, detailed cocktail recipe for: "${name}"
${preferencesNote}

CRITICAL REQUIREMENTS:
1. Use ONLY ingredient IDs from this list (use the ID, not the title):
${ingredientsList}

2. Use ONLY equipment IDs from this list (use the ID, not the title):
${equipmentList}

3. The cocktail MUST include:
   - 2-6 ingredients (reference by their IDs)
   - 2-4 equipment items (reference by their IDs)
   - 1-3 categories from: ${categoriesList}
   - Calculated ABV (alcohol by volume) as a number between 0 and 100
   - Bilingual title (English and Ukrainian - natural translation, not transliteration)
   - Bilingual description (English and Ukrainian)
   - Bilingual preparation steps (English and Ukrainian)

4. Title should be the cocktail name or closely related to "${name}"

5. Description should be concise (2-4 sentences):
   - Flavor profile and character
   - What makes this cocktail special
   - Serving suggestions or best occasions

6. Preparation steps should be detailed, clear, and actionable:
   - Each step should be a complete instruction
   - Include specific techniques (shake, stir, muddle, etc.)
   - Include timing when relevant (shake for 10 seconds, stir for 30 seconds)
   - Include measurements and proportions
   - Include garnishing and presentation
   - 4-8 steps is ideal
   - Write steps in imperative mood (do this, add that)

7. ABV calculation:
   - Calculate realistic alcohol by volume percentage
   - Consider the strength and proportion of alcoholic ingredients
   - Typical ranges: shots (30-40%), strong cocktails (20-30%), medium (10-20%), light (5-10%), mocktails (0%)
   - Return as a number (e.g., 15 for 15% ABV)

Return ONLY valid JSON (no markdown, no code blocks). The JSON must have this exact structure:
{
  "title": { 
    "en": "English cocktail name", 
    "uk": "Ukrainian cocktail name (natural translation, not transliteration)" 
  },
  "description": { 
    "en": "English description (2-4 sentences about flavor, character, and appeal)", 
    "uk": "Ukrainian description (2-4 sentences about flavor, character, and appeal)" 
  },
  "ingredients": ["ingredient-id-1", "ingredient-id-2", "ingredient-id-3"],
  "equipments": ["equipment-id-1", "equipment-id-2"],
  "categories": ["category1", "category2"],
  "abv": 15,
  "preparationSteps": {
    "en": [
      "Step 1 in English with detailed instructions",
      "Step 2 in English with detailed instructions",
      "Step 3 in English with detailed instructions"
    ],
    "uk": [
      "Крок 1 українською з детальними інструкціями",
      "Крок 2 українською з детальними інструкціями",
      "Крок 3 українською з детальними інструкціями"
    ]
  }
}

Make the recipe authentic, delicious, and practical. If "${name}" is a known cocktail, use the traditional recipe as a base. If it's a new creation, be creative but ensure it's balanced and appealing. Respond with compact JSON only.`;
}

/**
 * Validates the generated cocktail data
 */
function validateGeneratedCocktail(
  data: GeminiGeneratedCocktail,
  availableIngredients: Array<{ id: string; title: string }>,
  availableEquipment: Array<{ id: string; title: string }>
): void {
  console.log('Validating generated cocktail', data);

  const ingredientIds = new Set(availableIngredients.map(ing => ing.id));
  const equipmentIds = new Set(availableEquipment.map(eq => eq.id));
  const validCategories = new Set(Object.values(COCKTAIL_CATEGORIES));

  console.log({ ingredientIds: Array.from(ingredientIds.values()).slice(0,3), equipmentIds: Array.from(equipmentIds.values()).slice(0,3) });

  if (!data || typeof data !== 'object') {
    throw new HttpsError('internal', 'AI returned invalid data structure');
  }

  // Validate title
  if (!hasAllLocaleTitles(data.title, SUPPORTED_LOCALES)) {
    throw new HttpsError('internal', 'AI did not provide all required title translations');
  }

  // Validate description
  if (!hasAllLocaleTitles(data.description, SUPPORTED_LOCALES)) {
    throw new HttpsError('internal', 'AI did not provide all required description translations');
  }

  // Validate ingredients
  if (!Array.isArray(data.ingredients) || data.ingredients.length < 2 || data.ingredients.length > 6) {
    throw new HttpsError('internal', `Invalid ingredients count: ${data.ingredients?.length || 0}`);
  }

  const invalidIngredients = data.ingredients.filter(id => !ingredientIds.has(id));
  if (invalidIngredients.length > 0) {
    throw new HttpsError('internal', `AI used invalid ingredient IDs: ${invalidIngredients.join(', ')}`);
  }

  // Validate equipment
  if (!Array.isArray(data.equipments) || data.equipments.length < 2 || data.equipments.length > 4) {
    throw new HttpsError('internal', `Invalid equipment count: ${data.equipments?.length || 0}`);
  }

  const invalidEquipment = data.equipments.filter(id => !equipmentIds.has(id));
  if (invalidEquipment.length > 0) {
    throw new HttpsError('internal', `AI used invalid equipment IDs: ${invalidEquipment.join(', ')}`);
  }

  // Validate categories
  if (!Array.isArray(data.categories) || data.categories.length === 0 || data.categories.length > 3) {
    throw new HttpsError('internal', `Invalid categories count: ${data.categories?.length || 0}`);
  }

  const invalidCategories = data.categories.filter(cat => !validCategories.has(cat));
  if (invalidCategories.length > 0) {
    throw new HttpsError('internal', `AI used invalid categories: ${invalidCategories.join(', ')}`);
  }

  // Validate ABV
  if (typeof data.abv !== 'number' || data.abv < 0 || data.abv > 100) {
    throw new HttpsError('internal', `Invalid ABV value: ${data.abv}`);
  }

  // Validate preparation steps
  if (!data.preparationSteps || typeof data.preparationSteps !== 'object') {
    throw new HttpsError('internal', 'AI did not provide preparation steps');
  }

  for (const locale of SUPPORTED_LOCALES) {
    const steps = data.preparationSteps[locale];
    if (!Array.isArray(steps) || steps.length < 3 || steps.length > 10) {
      throw new HttpsError('internal', `Invalid preparation steps for locale ${locale}: ${steps?.length || 0} steps`);
    }

    if (steps.some(step => typeof step !== 'string' || step.trim().length === 0)) {
      throw new HttpsError('internal', `AI provided empty or invalid preparation steps for locale ${locale}`);
    }
  }
}
