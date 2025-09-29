/**
 * Get Cocktail Categories Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { CocktailService } from '../cocktail.service';

const cocktailService = new CocktailService();

/**
 * Gets all available cocktail categories
 */
export const getCocktailCategories = onCall(async (request) => {
  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const categories = cocktailService.getAvailableCategories();

    return {
      success: true,
      data: categories,
    };
  } catch (error) {
    console.error('Error getting cocktail categories:', error);

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
      'internal',
      error instanceof Error ? error.message : 'An error occurred while retrieving cocktail categories'
    );
  }
});
