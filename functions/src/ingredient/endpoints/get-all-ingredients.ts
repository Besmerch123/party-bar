/**
 * Get All Ingredients Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/https';
import { IngredientService } from '../ingredient.service';

const ingredientService = new IngredientService();

/**
 * Retrieves all ingredients
 */
export const getAllIngredients = onCall(async (request) => {
  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const ingredients = await ingredientService.getAllIngredients();
    
    return {
      success: true,
      data: ingredients,
    };
  } catch (error) {
    console.error('Error getting ingredients:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'Unknown error occurred');
  }
});
