/**
 * Get All Cocktails Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { CocktailService } from '../cocktail.service';

const cocktailService = new CocktailService();

/**
 * Retrieves all cocktails ordered by title
 */
export const getAllCocktails = onCall(async (request) => {
  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const cocktails = await cocktailService.getAllCocktails();

    return {
      success: true,
      data: cocktails,
    };
  } catch (error) {
    console.error('Error getting all cocktails:', error);

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
      'internal',
      error instanceof Error ? error.message : 'An error occurred while retrieving cocktails'
    );
  }
});
