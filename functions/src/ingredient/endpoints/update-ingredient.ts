/**
 * Update Ingredient Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { IngredientService } from '../ingredient.service';
import { UpdateIngredientDto } from '../ingredient.model';

const ingredientService = new IngredientService();

/**
 * Updates an existing ingredient
 */
export const updateIngredient = onCall(async (request) => {
  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { id, ...updateData } = request.data;
    
    if (!id) {
      throw new HttpsError('invalid-argument', 'Ingredient ID is required');
    }

    const ingredient = await ingredientService.updateIngredient(id, updateData as UpdateIngredientDto);
    
    return {
      success: true,
      data: ingredient,
    };
  } catch (error) {
    console.error('Error updating ingredient:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'Unknown error occurred');
  }
});
