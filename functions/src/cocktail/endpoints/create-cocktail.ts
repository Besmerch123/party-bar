/**
 * Create Cocktail Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/https';
import { getCocktailService } from '../cocktail.service';
import { CreateCocktailDto } from '../cocktail.model';

/**
 * Creates a new cocktail
 */
export const createCocktail = onCall(async (request) => {
  const cocktailService = getCocktailService();

  try {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const data = request.data as CreateCocktailDto | undefined;

    if (!data) {
      throw new HttpsError('invalid-argument', 'Cocktail data is required');
    }

    const cocktail = await cocktailService.createCocktail(data);

    return {
      success: true,
      data: cocktail,
    };
  } catch (error) {
    console.error('Error creating cocktail:', error);

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
      'internal',
      error instanceof Error ? error.message : 'An error occurred while creating the cocktail'
    );
  }
});
