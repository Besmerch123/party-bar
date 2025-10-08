/**
 * Get Ingredient Categories Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/https';
import { IngredientService } from '../ingredient.service';

const ingredientService = new IngredientService();

/**
 * Gets all available ingredient categories
 */
export const getIngredientCategories = onCall(async (request) => {
  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const categories = ingredientService.getAvailableCategories();
    
    return {
      success: true,
      data: categories,
    };
  } catch (error) {
    console.error('Error getting ingredient categories:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'Unknown error occurred');
  }
});
