/**
 * Update Cocktail Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { CocktailService } from '../cocktail.service';
import { UpdateCocktailDto } from '../cocktail.model';

const cocktailService = new CocktailService();

/**
 * Updates an existing cocktail
 */
export const updateCocktail = onCall(async (request) => {
  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { id, ...updateData } = (request.data ?? {}) as { id?: string } & UpdateCocktailDto;

    if (!id) {
      throw new HttpsError('invalid-argument', 'Cocktail ID is required');
    }

    const cocktail = await cocktailService.updateCocktail(id, updateData);

    return {
      success: true,
      data: cocktail,
    };
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
