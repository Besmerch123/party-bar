import { HttpsError, onCall } from 'firebase-functions/https';

import { IngredientService } from '../ingredient.service';
import { CreateIngredientDto, Ingredient } from '../ingredient.model';

const ingredientService = new IngredientService();

/**
 * Creates a new ingredient
 */
export const createIngredient = onCall<CreateIngredientDto, Promise<Ingredient>>(async (request) => {
  try {
    const data = request.data;
    
    if (!data) {
      throw new HttpsError('invalid-argument', 'Ingredient data is required');
    }

    return ingredientService.createIngredient(data);
  } catch (error) {
    console.error('Error creating ingredient:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'Unknown error occurred');
  }
});
