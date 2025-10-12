/**
 * Get Ingredient by ID Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/https';
import { IngredientService } from '../ingredient.service';
import type { Ingredient } from '../ingredient.model';

const ingredientService = new IngredientService();

/**
 * Retrieves an ingredient by ID
 */
export const getIngredient = onCall<{ id: string }, Promise<Ingredient>>(async (request) => {
  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { id } = request.data;
    
    if (!id) {
      throw new HttpsError('invalid-argument', 'Ingredient ID is required');
    }

    return ingredientService.getIngredient(id);
    
  } catch (error) {
    console.error('Error getting ingredient:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'Unknown error occurred');
  }
});
