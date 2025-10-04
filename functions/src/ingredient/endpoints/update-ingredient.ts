import { onRequest, HttpsError } from 'firebase-functions/v2/https';

import { IngredientService } from '../ingredient.service';
import { UpdateIngredientDto } from '../ingredient.model';

const ingredientService = new IngredientService();

/**
 * Updates an existing ingredient
 */
export const updateIngredient = onRequest(async (request, response) => {
  try {
    const { id, ...updateData } = request.body as Partial<UpdateIngredientDto> & { id: string };
    
    if (!id) {
      throw new HttpsError('invalid-argument', 'Ingredient ID is required');
    }

    const ingredient = await ingredientService.updateIngredient(id, updateData as UpdateIngredientDto);
    
    response.status(200).send(ingredient);
  } catch (error) {
    console.error('Error updating ingredient:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'Unknown error occurred');
  }
});
