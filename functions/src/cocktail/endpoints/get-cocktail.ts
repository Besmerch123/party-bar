/**
 * Get Cocktail Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/https';
import { getCocktailService } from '../cocktail.service';
import type { Cocktail } from '../cocktail.model';

/**
 * Retrieves a cocktail by ID
*/
export const getCocktail = onCall<{ id: string }, Promise<Cocktail>>(async (request) => {
  const cocktailService = getCocktailService();

  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { id } = (request.data ?? {});

    if (!id) {
      throw new HttpsError('invalid-argument', 'Cocktail ID is required');
    }

    return cocktailService.getCocktail(id);
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
