/**
 * Get Ingredients by Category Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { IngredientService } from '../ingredient.service';

const ingredientService = new IngredientService();

/**
 * Retrieves ingredients by category
 */
export const getIngredientsByCategory = onCall(async (request) => {
  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { category } = request.data;
    
    if (!category) {
      throw new HttpsError('invalid-argument', 'Category is required');
    }

    const ingredients = await ingredientService.getIngredientsByCategory(category);
    
    return {
      success: true,
      data: ingredients,
    };
  } catch (error) {
    console.error('Error getting ingredients by category:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'Unknown error occurred');
  }
});
