import {  HttpsError, onCall } from 'firebase-functions/https';

import { IngredientService } from '../ingredient.service';
import { UpdateIngredientDto } from '../ingredient.model';

const ingredientService = new IngredientService();

/**
 * Updates an existing ingredient
 */
export const updateIngredient = onCall<UpdateIngredientDto>(async (request) => {
  try {
    
    if (!request.data.id) {
      throw new HttpsError('invalid-argument', 'Ingredient ID is required');
    }

    const ingredient = await ingredientService.updateIngredient(request.data);
    
    return ingredient;
  } catch (error) {
    console.error('Error updating ingredient:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'Unknown error occurred');
  }
});
