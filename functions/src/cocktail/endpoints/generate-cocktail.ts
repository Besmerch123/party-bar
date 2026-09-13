/**
 * Generate Cocktail Endpoint
 *
 * Generates a complete cocktail recipe from a name, using Gemini. "Complete"
 * now means the whole recipe vocabulary -- measures, method, base spirit,
 * flavour, prep time and the guided pour -- not just a title and steps: a
 * drink missing those is one Explore's filters cannot see.
 *
 * The prompt and validation live in `cocktail.generation` so this and the
 * backfill stay in step.
 */

import { onCall, HttpsError } from 'firebase-functions/https';
import { GoogleGenAI } from '@google/genai';

import type { Cocktail } from '../cocktail.model';
import { getCocktailService } from '../cocktail.service';
import {
  buildGenerationPrompt,
  loadCatalogueOptions,
  requestGeneratedCocktail,
  toCreateCocktailDto,
} from '../cocktail.generation';

interface GenerateCocktailRequest {
  /** Desired cocktail name in plain English */
  name: string;
  /** Optional: Additional preferences or notes */
  preferences?: string;
}

export const generateCocktail = onCall<GenerateCocktailRequest, Promise<Cocktail>>(
  { timeoutSeconds: 300 },
  async (request) => {
    const cocktailService = getCocktailService();

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

      const projectId = process.env.GCLOUD_PROJECT || process.env.GOOGLE_CLOUD_PROJECT;
      if (!projectId) {
        throw new HttpsError('internal', 'Project ID is not configured');
      }

      const location = process.env.GOOGLE_CLOUD_LOCATION || process.env.VERTEX_LOCATION || 'us-central1';
      const ai = new GoogleGenAI({ vertexai: true, project: projectId, location });

      const { ingredients, equipment } = await loadCatalogueOptions();

      if (ingredients.length === 0 || equipment.length === 0) {
        throw new HttpsError('failed-precondition', 'No ingredients or equipment found in database');
      }

      const prompt = buildGenerationPrompt({ name, preferences, ingredients, equipment });

      const generated = await requestGeneratedCocktail({
        ai,
        prompt,
        availableIngredients: ingredients,
        availableEquipment: equipment,
      });

      const cocktail = await cocktailService.createCocktail(toCreateCocktailDto(generated));

      console.log(`Successfully generated cocktail: ${cocktail.title.en}`);

      return cocktail;
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
  }
);
