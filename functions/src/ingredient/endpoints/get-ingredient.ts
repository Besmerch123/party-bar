/**
 * Get Ingredient by ID Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/https';
import { IngredientService } from '../ingredient.service';

const ingredientService = new IngredientService();

/**
 * Retrieves an ingredient by ID
 */
export const getIngredient = onCall(async (request) => {
  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { id } = request.data;
    
    if (!id) {
      throw new HttpsError('invalid-argument', 'Ingredient ID is required');
    }

    const ingredient = await ingredientService.getIngredient(id);
    
    return {
      success: true,
      data: ingredient,
    };
  } catch (error) {
    console.error('Error getting ingredient:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'Unknown error occurred');
  }
});
