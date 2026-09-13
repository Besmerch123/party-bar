/**
 * Cocktail Generation
 *
 * The prompt, the shape it must come back in, and the validation that decides
 * whether it is usable. Shared by `generateCocktail` (one new drink from a
 * name) and `backfillCocktails` (the recipe vocabulary for drinks that predate
 * it), so the two cannot drift into producing differently-shaped recipes.
 *
 * Everything Explore filters and sorts on -- method, base spirit, flavour,
 * prep time -- has to be produced here. A drink generated without them is not
 * partially complete, it is invisible: every one of those filters reads a null
 * field as "does not match".
 */

import { GoogleGenAI } from '@google/genai';
import { firestore } from 'firebase-admin';

import type { IngredientDocument } from '../ingredient/ingredient.model';
import type { EquipmentDocument } from '../equipment/equipment.model';

import type { SupportedLocale } from '../shared/types';
import { SUPPORTED_LOCALES } from '../shared/types';
import {
  extractTextResponse,
  parseJsonResponse,
  hasAllLocaleTitles,
} from '../shared/cli-tools';

import {
  COCKTAIL_CATEGORIES,
  COCKTAIL_METHODS,
  BASE_SPIRITS,
  FLAVOR_PROFILES,
  MEASURE_UNITS,
  type CocktailCategory,
  type CocktailMethod,
  type BaseSpirit,
  type FlavorProfile,
  type MeasureUnit,
  type IngredientMeasure,
  type PourStep,
  type CreateCocktailDto,
} from './cocktail.model';

/** A catalogue entry offered to the model as a choice. */
export interface CatalogueOption {
  id: string;
  title: string;
}

/**
 * What the model is asked to return.
 *
 * Deliberately flat and id-based: the model picks from the catalogue we hand
 * it rather than inventing ingredient names we would then have to resolve.
 */
export interface GeneratedCocktail {
  title: Record<SupportedLocale, string>;
  description: Record<SupportedLocale, string>;
  ingredients: string[];
  equipments: string[];
  categories: CocktailCategory[];
  abv: number;
  prepTimeMinutes: number;
  method: CocktailMethod;
  baseSpirit: BaseSpirit;
  flavor: FlavorProfile;
  popularity: number;
  seasonalScore: number;
  measures: Record<string, { amount: number; unit: MeasureUnit; optional?: boolean }>;
  preparationSteps: Record<SupportedLocale, string[]>;
  pourSteps: Array<{
    title: Record<SupportedLocale, string>;
    body?: Record<SupportedLocale, string>;
    durationSeconds?: number | null;
  }>;
}

const MIN_INGREDIENTS = 2;
const MAX_INGREDIENTS = 6;
const MIN_EQUIPMENT = 2;
const MAX_EQUIPMENT = 4;
const MIN_STEPS = 3;
const MAX_STEPS = 10;
const MIN_POUR_STEPS = 3;
const MAX_POUR_STEPS = 8;

/**
 * Builds the prompt.
 *
 * `existing` turns this from "invent a drink" into "describe this drink in the
 * new vocabulary", which is what the backfill needs: it already has a title,
 * an ingredient list and steps, and must not have them rewritten out from
 * under the images and ids that reference them.
 */
export function buildGenerationPrompt(options: {
  name: string;
  preferences?: string;
  ingredients: CatalogueOption[];
  equipment: CatalogueOption[];
  existing?: {
    description?: string;
    ingredientIds?: string[];
    equipmentIds?: string[];
    preparationSteps?: string[];
  };
}): string {
  const { name, preferences, ingredients, equipment, existing } = options;

  const categoriesList = Object.values(COCKTAIL_CATEGORIES).join(', ');
  const methodsList = Object.values(COCKTAIL_METHODS).join(', ');
  const spiritsList = Object.values(BASE_SPIRITS).join(', ');
  const flavorsList = Object.values(FLAVOR_PROFILES).join(', ');
  const unitsList = Object.values(MEASURE_UNITS).join(', ');

  const ingredientsList = ingredients.map((item) => `  - ${item.id}: ${item.title}`).join('\n');
  const equipmentList = equipment.map((item) => `  - ${item.id}: ${item.title}`).join('\n');

  const preferencesNote = preferences?.trim()
    ? `\n\nADDITIONAL PREFERENCES: ${preferences.trim()}`
    : '';

  const existingNote = existing
    ? `

THIS COCKTAIL ALREADY EXISTS in the catalogue. You are describing it in a richer
vocabulary, NOT reinventing it. Keep it recognisably the same drink.
${existing.description ? `  Current description: ${existing.description}\n` : ''}${
  existing.ingredientIds?.length ? `  Current ingredients: ${existing.ingredientIds.join(', ')}\n` : ''
}${existing.equipmentIds?.length ? `  Current equipment: ${existing.equipmentIds.join(', ')}\n` : ''}${
  existing.preparationSteps?.length
    ? `  Current preparation steps:\n${existing.preparationSteps.map((step, i) => `    ${i + 1}. ${step}`).join('\n')}\n`
    : ''
}
Prefer the existing ingredients and equipment. Change them only where the current
list is plainly wrong or incomplete for the drink.`
    : '';

  return `You are an expert mixologist building a cocktail recipe database. Generate a complete, detailed recipe for: "${name}"
${preferencesNote}${existingNote}

CRITICAL REQUIREMENTS:
1. Use ONLY ingredient IDs from this list (use the ID, not the title):
${ingredientsList}

2. Use ONLY equipment IDs from this list (use the ID, not the title):
${equipmentList}

3. The cocktail MUST include:
   - ${MIN_INGREDIENTS}-${MAX_INGREDIENTS} ingredients (reference by their IDs)
   - ${MIN_EQUIPMENT}-${MAX_EQUIPMENT} equipment items (reference by their IDs)
   - 1-3 categories from: ${categoriesList}
   - Bilingual title, description, preparation steps and pour steps
     (English and Ukrainian - natural translation, never transliteration)

4. Title should be the cocktail name or closely related to "${name}"

5. Description: concise, 2-4 sentences covering flavour and character, what
   makes it special, and when to serve it.

6. "measures" -- how much of each ingredient the recipe wants:
   - An entry for EVERY ingredient ID you listed, keyed by that exact ID
   - "amount": a number. "unit": one of ${unitsList}
   - Use ml for liquids, dash for bitters, barspoon for small volumes,
     piece for whole items (a lime wedge, an egg), splash or topUp for
     "top with soda". splash and topUp carry no meaningful amount -- send
     amount 0 for those
   - "optional": true for garnishes and top-ups a person could skip. These do
     NOT count when deciding whether someone's bar can make the drink, so mark
     every garnish optional and never mark a core spirit optional

7. "method" -- how the drink is assembled, one of: ${methodsList}
   Judge the actual technique, not the equipment: a drink stirred in the glass
   is "built" even if a shaker is listed for chilling.

8. "baseSpirit" -- the bottle the drink is built around, one of: ${spiritsList}
   Must be consistent with your ingredient list. Use "zeroProof" for any drink
   with no alcohol, and "other" only when no single spirit dominates.

9. "flavor" -- the dominant taste, one of: ${flavorsList}

10. "prepTimeMinutes" -- whole minutes of active work, typically 1-5. A built
    highball is 1-2; something shaken with a garnish to cut is 3-5.

11. "abv" -- calculated alcohol by volume, 0-100. Consider the strength and
    proportion of the alcoholic ingredients against the dilution.
    Typical: shots 30-40, strong 20-30, medium 10-20, light 5-10, mocktails 0.

12. "popularity" -- 0-100, how widely known the drink is. A Mojito or Negroni
    is 90+; an original creation is under 30.

13. "seasonalScore" -- 0-100, how well it fits the current season in the
    northern hemisphere. Light citrus and spritzes score high in summer,
    spirit-forward and spiced drinks high in winter.

14. "preparationSteps" -- the readable recipe, ${MIN_STEPS}-${MAX_STEPS} steps,
    imperative mood, with measurements, techniques and garnishing.

15. "pourSteps" -- the SAME recipe cut into the units a person actually
    performs while making it, hands busy, glancing at a phone:
    - ${MIN_POUR_STEPS}-${MAX_POUR_STEPS} steps
    - "title" is the instruction itself, short and scannable: "Shake hard"
    - "body" is optional detail, only where a step genuinely needs it
    - "durationSeconds" ONLY on steps that are genuinely timed (shaking,
      stirring, resting). Omit it or send null everywhere else.

Return ONLY valid JSON (no markdown, no code blocks), with this exact structure:
{
  "title": { "en": "English name", "uk": "Ukrainian name" },
  "description": { "en": "English description", "uk": "Ukrainian description" },
  "ingredients": ["ingredient-id-1", "ingredient-id-2"],
  "equipments": ["equipment-id-1", "equipment-id-2"],
  "categories": ["classic"],
  "abv": 15,
  "prepTimeMinutes": 3,
  "method": "shaken",
  "baseSpirit": "gin",
  "flavor": "citrus",
  "popularity": 75,
  "seasonalScore": 60,
  "measures": {
    "ingredient-id-1": { "amount": 45, "unit": "ml", "optional": false },
    "ingredient-id-2": { "amount": 1, "unit": "piece", "optional": true }
  },
  "preparationSteps": {
    "en": ["Step 1 in English", "Step 2 in English", "Step 3 in English"],
    "uk": ["Крок 1 українською", "Крок 2 українською", "Крок 3 українською"]
  },
  "pourSteps": [
    {
      "title": { "en": "Fill the shaker with ice", "uk": "Наповніть шейкер льодом" },
      "durationSeconds": null
    },
    {
      "title": { "en": "Shake hard", "uk": "Струсіть енергійно" },
      "body": { "en": "Until the tin frosts over", "uk": "Поки шейкер не вкриється інеєм" },
      "durationSeconds": 12
    },
    {
      "title": { "en": "Strain and garnish", "uk": "Процідіть і прикрасьте" },
      "durationSeconds": null
    }
  ]
}

Make the recipe authentic, delicious and practical. If "${name}" is a known
cocktail, use the traditional recipe as a base. If it is a new creation, be
creative but keep it balanced. Respond with compact JSON only.`;
}

/**
 * Validates a generated recipe against the catalogue and the model's own rules.
 *
 * Throws on anything unusable. The caller turns that into an HttpsError -- a
 * failed generation is better than a drink that silently never matches a
 * filter.
 */
export function validateGeneratedCocktail(
  data: GeneratedCocktail,
  availableIngredients: CatalogueOption[],
  availableEquipment: CatalogueOption[]
): void {
  if (!data || typeof data !== 'object') {
    throw new Error('AI returned invalid data structure');
  }

  const ingredientIds = new Set(availableIngredients.map((item) => item.id));
  const equipmentIds = new Set(availableEquipment.map((item) => item.id));

  if (!hasAllLocaleTitles(data.title, SUPPORTED_LOCALES)) {
    throw new Error('AI did not provide all required title translations');
  }

  if (!hasAllLocaleTitles(data.description, SUPPORTED_LOCALES)) {
    throw new Error('AI did not provide all required description translations');
  }

  // --- References into the catalogue
  if (
    !Array.isArray(data.ingredients)
    || data.ingredients.length < MIN_INGREDIENTS
    || data.ingredients.length > MAX_INGREDIENTS
  ) {
    throw new Error(`Invalid ingredients count: ${data.ingredients?.length ?? 0}`);
  }

  const invalidIngredients = data.ingredients.filter((id) => !ingredientIds.has(id));
  if (invalidIngredients.length > 0) {
    throw new Error(`AI used invalid ingredient IDs: ${invalidIngredients.join(', ')}`);
  }

  if (
    !Array.isArray(data.equipments)
    || data.equipments.length < MIN_EQUIPMENT
    || data.equipments.length > MAX_EQUIPMENT
  ) {
    throw new Error(`Invalid equipment count: ${data.equipments?.length ?? 0}`);
  }

  const invalidEquipment = data.equipments.filter((id) => !equipmentIds.has(id));
  if (invalidEquipment.length > 0) {
    throw new Error(`AI used invalid equipment IDs: ${invalidEquipment.join(', ')}`);
  }

  // --- Categories
  if (!Array.isArray(data.categories) || data.categories.length === 0 || data.categories.length > 3) {
    throw new Error(`Invalid categories count: ${data.categories?.length ?? 0}`);
  }

  assertAllowed(data.categories, COCKTAIL_CATEGORIES, 'category');

  // --- The vocabulary Explore filters on
  assertAllowed([data.method], COCKTAIL_METHODS, 'method');
  assertAllowed([data.baseSpirit], BASE_SPIRITS, 'baseSpirit');
  assertAllowed([data.flavor], FLAVOR_PROFILES, 'flavor');

  assertNumberInRange(data.abv, 0, 100, 'abv');
  assertWholeNumberInRange(data.prepTimeMinutes, 1, 240, 'prepTimeMinutes');
  assertWholeNumberInRange(data.popularity, 0, 100, 'popularity');
  assertWholeNumberInRange(data.seasonalScore, 0, 100, 'seasonalScore');

  // --- Measures: one per listed ingredient, no strays
  if (!data.measures || typeof data.measures !== 'object' || Array.isArray(data.measures)) {
    throw new Error('AI did not provide measures');
  }

  const allowedUnits = Object.values(MEASURE_UNITS) as string[];
  const listedIngredients = new Set(data.ingredients);

  for (const [id, measure] of Object.entries(data.measures)) {
    if (!listedIngredients.has(id)) {
      throw new Error(`AI provided a measure for an ingredient it did not list: ${id}`);
    }

    if (!measure || typeof measure !== 'object') {
      throw new Error(`AI provided an invalid measure for ${id}`);
    }

    if (typeof measure.amount !== 'number' || !Number.isFinite(measure.amount) || measure.amount < 0) {
      throw new Error(`AI provided an invalid amount for ${id}: ${measure.amount}`);
    }

    if (typeof measure.unit !== 'string' || !allowedUnits.includes(measure.unit)) {
      throw new Error(`AI provided an invalid unit for ${id}: ${measure.unit}`);
    }
  }

  const missingMeasures = data.ingredients.filter((id) => !(id in data.measures));
  if (missingMeasures.length > 0) {
    throw new Error(`AI did not provide measures for: ${missingMeasures.join(', ')}`);
  }

  // A drink where everything is optional is makeable from an empty shelf.
  const required = data.ingredients.filter((id) => data.measures[id]?.optional !== true);
  if (required.length === 0) {
    throw new Error('AI marked every ingredient optional, leaving the drink with no required ingredients');
  }

  // --- Preparation steps
  if (!data.preparationSteps || typeof data.preparationSteps !== 'object') {
    throw new Error('AI did not provide preparation steps');
  }

  for (const locale of SUPPORTED_LOCALES) {
    const steps = data.preparationSteps[locale];

    if (!Array.isArray(steps) || steps.length < MIN_STEPS || steps.length > MAX_STEPS) {
      throw new Error(`Invalid preparation steps for locale ${locale}: ${steps?.length ?? 0} steps`);
    }

    if (steps.some((step) => typeof step !== 'string' || step.trim().length === 0)) {
      throw new Error(`AI provided empty or invalid preparation steps for locale ${locale}`);
    }
  }

  // --- Pour steps
  if (
    !Array.isArray(data.pourSteps)
    || data.pourSteps.length < MIN_POUR_STEPS
    || data.pourSteps.length > MAX_POUR_STEPS
  ) {
    throw new Error(`Invalid pour steps count: ${data.pourSteps?.length ?? 0}`);
  }

  data.pourSteps.forEach((step, index) => {
    if (!step || typeof step !== 'object') {
      throw new Error(`pourSteps[${index}] is not an object`);
    }

    if (!hasAllLocaleTitles(step.title, SUPPORTED_LOCALES)) {
      throw new Error(`pourSteps[${index}] is missing title translations`);
    }

    if (step.body !== undefined && step.body !== null && !hasAllLocaleTitles(step.body, SUPPORTED_LOCALES)) {
      throw new Error(`pourSteps[${index}] has an incomplete body translation`);
    }

    if (step.durationSeconds !== undefined && step.durationSeconds !== null) {
      assertWholeNumberInRange(step.durationSeconds, 1, 3600, `pourSteps[${index}].durationSeconds`);
    }
  });
}

function assertAllowed<T extends string>(
  values: T[],
  allowedValues: Record<string, T>,
  label: string
): void {
  const allowed = Object.values(allowedValues) as string[];
  const invalid = values.filter((value) => typeof value !== 'string' || !allowed.includes(value));

  if (invalid.length > 0) {
    throw new Error(`AI used an invalid ${label}: ${invalid.join(', ')}. Expected one of: ${allowed.join(', ')}`);
  }
}

function assertNumberInRange(value: number, min: number, max: number, field: string): void {
  if (typeof value !== 'number' || !Number.isFinite(value) || value < min || value > max) {
    throw new Error(`Invalid ${field} value: ${value}. Expected a number between ${min} and ${max}`);
  }
}

function assertWholeNumberInRange(value: number, min: number, max: number, field: string): void {
  if (typeof value !== 'number' || !Number.isInteger(value) || value < min || value > max) {
    throw new Error(`Invalid ${field} value: ${value}. Expected a whole number between ${min} and ${max}`);
  }
}

/**
 * Turns a validated generation into the shape the service writes.
 *
 * Ingredient and equipment ids become collection paths here, and only here, so
 * the two prefixes live in one place rather than being spelled out at every
 * call site.
 */
export function toCreateCocktailDto(data: GeneratedCocktail): CreateCocktailDto {
  return {
    title: data.title,
    description: data.description,
    ingredients: data.ingredients.map((id) => `ingredients/${id}`),
    equipments: data.equipments.map((id) => `equipment/${id}`),
    categories: data.categories,
    abv: data.abv,
    prepTimeMinutes: data.prepTimeMinutes,
    method: data.method,
    baseSpirit: data.baseSpirit,
    flavor: data.flavor,
    popularity: data.popularity,
    seasonalScore: data.seasonalScore,
    measures: toMeasures(data),
    preparationSteps: data.preparationSteps,
    pourSteps: toPourSteps(data),
  };
}

/** The measures map, with `optional` made explicit rather than left undefined. */
export function toMeasures(data: GeneratedCocktail): Record<string, IngredientMeasure> {
  const measures: Record<string, IngredientMeasure> = {};

  for (const [id, measure] of Object.entries(data.measures)) {
    measures[id] = {
      amount: measure.amount,
      unit: measure.unit,
      optional: measure.optional ?? false,
    };
  }

  return measures;
}

/** Pour steps, with the absent timer normalised to null rather than undefined. */
export function toPourSteps(data: GeneratedCocktail): PourStep[] {
  return data.pourSteps.map((step) => ({
    title: step.title,
    ...(step.body ? { body: step.body } : {}),
    durationSeconds: step.durationSeconds ?? null,
  }));
}

/**
 * Asks Gemini for a recipe and returns it validated.
 *
 * Temperature stays high enough to write a decent description but the shape is
 * pinned by `responseMimeType`, so the variance lands in the prose rather than
 * in whether `method` comes back at all.
 */
export async function requestGeneratedCocktail(options: {
  ai: GoogleGenAI;
  model?: string;
  prompt: string;
  availableIngredients: CatalogueOption[];
  availableEquipment: CatalogueOption[];
}): Promise<GeneratedCocktail> {
  const { ai, prompt, availableIngredients, availableEquipment } = options;

  const result = await ai.models.generateContent({
    model: options.model ?? 'gemini-2.5-pro',
    contents: prompt,
    config: {
      responseMimeType: 'application/json',
      temperature: 0.7,
      topP: 0.95,
      topK: 40,
    },
  });

  const textResponse = extractTextResponse(result);
  if (!textResponse) {
    throw new Error('AI did not return a valid response');
  }

  // `parseJsonResponse` wraps a bare object into an array, so both shapes arrive here.
  const parsed = parseJsonResponse<GeneratedCocktail | GeneratedCocktail[]>(textResponse);
  const generated = Array.isArray(parsed) ? parsed[0] : parsed;

  if (!generated) {
    throw new Error('AI returned empty response');
  }

  validateGeneratedCocktail(generated, availableIngredients, availableEquipment);

  return generated;
}

/**
 * The ingredients and equipment the model is allowed to choose from.
 *
 * Loaded fresh per generation rather than cached: the catalogue is edited in
 * the same panel that triggers generation, and an ingredient added a minute
 * ago should be pickable.
 */
export async function loadCatalogueOptions(): Promise<{
  ingredients: CatalogueOption[];
  equipment: CatalogueOption[];
}> {
  const fs = firestore();

  const [ingredientsSnapshot, equipmentSnapshot] = await Promise.all([
    fs.collection('ingredients').get(),
    fs.collection('equipment').get(),
  ]);

  const ingredients = ingredientsSnapshot.docs.map((doc) => {
    const data = doc.data() as IngredientDocument;
    return { id: doc.id, title: data.title.en || doc.id };
  });

  const equipment = equipmentSnapshot.docs.map((doc) => {
    const data = doc.data() as EquipmentDocument;
    return { id: doc.id, title: data.title.en || doc.id };
  });

  return { ingredients, equipment };
}
