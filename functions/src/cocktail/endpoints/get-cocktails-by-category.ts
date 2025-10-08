/**
 * Get Cocktails By Category Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/https';
import { CocktailService } from '../cocktail.service';

const cocktailService = new CocktailService();

/**
 * Retrieves cocktails filtered by category
 */
export const getCocktailsByCategory = onCall(async (request) => {
  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { category } = (request.data ?? {}) as { category?: string };

    if (!category) {
      throw new HttpsError('invalid-argument', 'Category is required');
    }

    const cocktails = await cocktailService.getCocktailsByCategory(category);

    return {
      success: true,
      data: cocktails,
    };
  } catch (error) {
    console.error('Error getting cocktails by category:', error);

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
      'internal',
      error instanceof Error ? error.message : 'An error occurred while filtering cocktails'
    );
  }
});
