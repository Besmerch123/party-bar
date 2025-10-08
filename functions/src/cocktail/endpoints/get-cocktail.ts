/**
 * Get Cocktail Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/https';
import { CocktailService } from '../cocktail.service';

const cocktailService = new CocktailService();

/**
 * Retrieves a cocktail by ID
 */
export const getCocktail = onCall(async (request) => {
  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { id } = (request.data ?? {}) as { id?: string };

    if (!id) {
      throw new HttpsError('invalid-argument', 'Cocktail ID is required');
    }

    const cocktail = await cocktailService.getCocktail(id);

    return {
      success: true,
      data: cocktail,
    };
  } catch (error) {
    console.error('Error getting cocktail:', error);

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
      'internal',
      error instanceof Error ? error.message : 'An error occurred while retrieving the cocktail'
    );
  }
});
