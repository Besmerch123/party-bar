import { onRequest, HttpsError } from 'firebase-functions/v2/https';

import { IngredientService } from '../ingredient.service';
import { CreateIngredientDto } from '../ingredient.model';

const ingredientService = new IngredientService();

/**
 * Creates a new ingredient
 */
export const createIngredient = onRequest(async (request, response) => {
  try {
    const data = request.body as CreateIngredientDto;
    
    if (!data) {
      throw new HttpsError('invalid-argument', 'Ingredient data is required');
    }

    const ingredient = await ingredientService.createIngredient(data);
    

    response.status(201).send(ingredient);
  } catch (error) {
    console.error('Error creating ingredient:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'Unknown error occurred');
  }
});
