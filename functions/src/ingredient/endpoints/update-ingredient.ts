import {  HttpsError, onCall } from 'firebase-functions/https';

import { IngredientService } from '../ingredient.service';
import { UpdateIngredientDto, Ingredient } from '../ingredient.model';

const ingredientService = new IngredientService();

/**
 * Updates an existing ingredient
 */
export const updateIngredient = onCall<UpdateIngredientDto, Promise<Ingredient>>(async (request) => {
  try {
    
    if (!request.data.id) {
      throw new HttpsError('invalid-argument', 'Ingredient ID is required');
    }

    return ingredientService.updateIngredient(request.data);
  } catch (error) {
    console.error('Error updating ingredient:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'Unknown error occurred');
  }
});
