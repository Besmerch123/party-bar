/**
 * Create Ingredient Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { IngredientService } from '../ingredient.service';
import { CreateIngredientDto } from '../ingredient.model';

const ingredientService = new IngredientService();

/**
 * Creates a new ingredient
 */
export const createIngredient = onCall(async (request) => {
  try {
    // Basic auth check (you may want to add proper authentication later)
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const data = request.data as CreateIngredientDto;
    
    if (!data) {
      throw new HttpsError('invalid-argument', 'Ingredient data is required');
    }

    const ingredient = await ingredientService.createIngredient(data);
    
    return {
      success: true,
      data: ingredient,
    };
  } catch (error) {
    console.error('Error creating ingredient:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'Unknown error occurred');
  }
});
