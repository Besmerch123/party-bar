/**
 * Delete Ingredient Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { IngredientService } from '../ingredient.service';

const ingredientService = new IngredientService();

/**
 * Deletes an ingredient
 */
export const deleteIngredient = onCall(async (request) => {
  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { id } = request.data;
    
    if (!id) {
      throw new HttpsError('invalid-argument', 'Ingredient ID is required');
    }

    await ingredientService.deleteIngredient(id);
    
    return {
      success: true,
      message: 'Ingredient deleted successfully',
    };
  } catch (error) {
    console.error('Error deleting ingredient:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'Unknown error occurred');
  }
});
