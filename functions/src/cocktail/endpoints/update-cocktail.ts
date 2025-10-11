/**
 * Update Cocktail Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/https';
import { getCocktailService } from '../cocktail.service';
import { UpdateCocktailDto } from '../cocktail.model';

/**
 * Updates an existing cocktail
*/
export const updateCocktail = onCall<UpdateCocktailDto>(async (request) => {
  const cocktailService = getCocktailService();

  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const cocktail = await cocktailService.updateCocktail(request.data);

    return  cocktail;
  } catch (error) {
    console.error('Error updating cocktail:', error);

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
      'internal',
      error instanceof Error ? error.message : 'An error occurred while updating the cocktail'
    );
  }
});
