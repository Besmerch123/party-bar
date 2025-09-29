/**
 * Delete Cocktail Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { CocktailService } from '../cocktail.service';

const cocktailService = new CocktailService();

/**
 * Deletes a cocktail by ID
 */
export const deleteCocktail = onCall(async (request) => {
  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { id } = (request.data ?? {}) as { id?: string };

    if (!id) {
      throw new HttpsError('invalid-argument', 'Cocktail ID is required');
    }

    await cocktailService.deleteCocktail(id);

    return {
      success: true,
      message: 'Cocktail deleted successfully',
    };
  } catch (error) {
    console.error('Error deleting cocktail:', error);

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
      'internal',
      error instanceof Error ? error.message : 'An error occurred while deleting the cocktail'
    );
  }
});
