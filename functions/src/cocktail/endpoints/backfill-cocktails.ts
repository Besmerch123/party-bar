/**
 * Backfill Cocktails Endpoint
 *
 * Fills the recipe vocabulary on cocktails that predate it. Those drinks are
 * not slightly incomplete -- with a null `method`, `baseSpirit`, `flavor` or
 * `prepTimeMinutes` they match none of Explore's filters, and with no
 * `measures` their recipe card prints ingredients without quantities.
 *
 * Runs the same prompt as `generateCocktail`, handed the drink's current
 * description, ingredients and steps, so the result is the existing drink
 * described more richly rather than a different drink under the same name.
 * The title and image are never touched: the document id derives from the
 * title, and the image is generated separately.
 */

import { onCall, HttpsError } from 'firebase-functions/https';
import { GoogleGenAI } from '@google/genai';
import { firestore } from 'firebase-admin';

import type { CocktailDocument, UpdateCocktailDto } from '../cocktail.model';
import { getCocktailService } from '../cocktail.service';
import {
  buildGenerationPrompt,
  loadCatalogueOptions,
  requestGeneratedCocktail,
  toMeasures,
  toPourSteps,
} from '../cocktail.generation';

interface BackfillCocktailsRequest {
  /**
   * How many cocktails to process in this run. Each one is a Gemini round
   * trip, so the whole catalogue does not fit in a single invocation.
   */
  limit?: number;

  /**
   * Re-generate drinks that already carry the new fields. Off by default, so
   * repeated runs walk forward through what is still missing instead of
   * rewriting the same drinks.
   */
  force?: boolean;

  /** Backfill exactly this cocktail, ignoring `limit` and the missing check. */
  cocktailId?: string;
}

interface BackfillResult {
  /** Cocktails considered in this run. */
  processed: number;
  updated: number;
  /** Already complete, and `force` was not set. */
  skipped: number;
  failures: Array<{ id: string; error: string }>;
  /** True when cocktails are still missing the vocabulary -- run it again. */
  hasMore: boolean;
}

const DEFAULT_LIMIT = 10;
const MAX_LIMIT = 50;

/**
 * Whether a drink already carries everything Explore needs to see it.
 *
 * `measures` and `pourSteps` count as present only when non-empty: an empty
 * map is what a partial earlier write leaves behind, and it reads the same as
 * absent on the device.
 */
function isComplete(cocktail: CocktailDocument): boolean {
  return Boolean(
    cocktail.method
    && cocktail.baseSpirit
    && cocktail.flavor
    && cocktail.prepTimeMinutes
    && cocktail.measures
    && Object.keys(cocktail.measures).length > 0
    && cocktail.pourSteps
    && cocktail.pourSteps.length > 0
  );
}

/** "ingredients/gin" -> "gin". */
function toId(reference: string): string {
  const lastSlash = reference.lastIndexOf('/');
  return lastSlash >= 0 ? reference.substring(lastSlash + 1) : reference;
}

export const backfillCocktails = onCall<BackfillCocktailsRequest, Promise<BackfillResult>>(
  { timeoutSeconds: 3600 },
  async (request) => {
    try {
      if (!request.auth) {
        throw new HttpsError('unauthenticated', 'User must be authenticated');
      }

      const cocktailService = getCocktailService();
      const { limit, force, cocktailId } = request.data ?? {};

      const batchSize = Math.min(Math.max(limit ?? DEFAULT_LIMIT, 1), MAX_LIMIT);

      const projectId = process.env.GCLOUD_PROJECT || process.env.GOOGLE_CLOUD_PROJECT;
      if (!projectId) {
        throw new HttpsError('internal', 'Project ID is not configured');
      }

      const location = process.env.GOOGLE_CLOUD_LOCATION || process.env.VERTEX_LOCATION || 'us-central1';
      const ai = new GoogleGenAI({ vertexai: true, project: projectId, location });

      const { ingredients: availableIngredients, equipment: availableEquipment } = await loadCatalogueOptions();

      if (availableIngredients.length === 0 || availableEquipment.length === 0) {
        throw new HttpsError('failed-precondition', 'No ingredients or equipment found in database');
      }

      const fs = firestore();

      const snapshot = cocktailId
        ? await fs.collection('cocktails').where(firestore.FieldPath.documentId(), '==', cocktailId).get()
        : await fs.collection('cocktails').get();

      if (cocktailId && snapshot.empty) {
        throw new HttpsError('not-found', `Cocktail ${cocktailId} not found`);
      }

      // Pick the work before doing any of it, so `hasMore` is honest about
      // what is left rather than about what this batch happened to hit.
      const candidates = snapshot.docs.filter((doc) => {
        if (cocktailId || force) {
          return true;
        }

        return !isComplete(doc.data() as CocktailDocument);
      });

      const batch = candidates.slice(0, batchSize);

      const result: BackfillResult = {
        processed: batch.length,
        updated: 0,
        skipped: snapshot.size - candidates.length,
        failures: [],
        hasMore: candidates.length > batch.length,
      };

      console.info(
        `Backfilling ${batch.length} of ${candidates.length} candidate cocktails (${snapshot.size} total)`
      );

      for (const doc of batch) {
        const data = doc.data() as CocktailDocument;
        const englishTitle = data.title?.en;

        if (!englishTitle) {
          result.failures.push({ id: doc.id, error: 'Cocktail has no English title to generate from' });
          continue;
        }

        try {
          const prompt = buildGenerationPrompt({
            name: englishTitle,
            ingredients: availableIngredients,
            equipment: availableEquipment,
            existing: {
              description: data.description?.en,
              ingredientIds: (data.ingredients ?? []).map(toId),
              equipmentIds: (data.equipments ?? []).map(toId),
              preparationSteps: data.preparationSteps?.en,
            },
          });

          const generated = await requestGeneratedCocktail({
            ai,
            prompt,
            availableIngredients,
            availableEquipment,
          });

          // Ingredients, equipment and measures move together: a measure is
          // keyed by ingredient id and is rejected if the recipe no longer
          // lists it, so writing one without the others cannot be valid.
          const update: UpdateCocktailDto = {
            id: doc.id,
            description: generated.description,
            ingredients: generated.ingredients.map((id) => `ingredients/${id}`),
            equipments: generated.equipments.map((id) => `equipment/${id}`),
            categories: generated.categories,
            abv: generated.abv,
            prepTimeMinutes: generated.prepTimeMinutes,
            method: generated.method,
            baseSpirit: generated.baseSpirit,
            flavor: generated.flavor,
            popularity: generated.popularity,
            seasonalScore: generated.seasonalScore,
            measures: toMeasures(generated),
            preparationSteps: generated.preparationSteps,
            pourSteps: toPourSteps(generated),
          };

          await cocktailService.updateCocktail(update);

          result.updated += 1;
          console.info(`Backfilled ${doc.id} (${result.updated}/${batch.length})`);
        } catch (error) {
          const message = error instanceof Error ? error.message : 'Unknown error';
          console.error(`Failed to backfill ${doc.id}:`, error);
          result.failures.push({ id: doc.id, error: message });
        }
      }

      console.info('Backfill complete', result);

      return result;
    } catch (error) {
      console.error('Error backfilling cocktails:', error);

      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError(
        'internal',
        error instanceof Error ? error.message : 'An error occurred while backfilling cocktails'
      );
    }
  }
);
