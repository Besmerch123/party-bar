/**
 * Get All Cocktails Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/https';

import { ElasticSearchResults } from '../../elastic/elastic.types';

import { getCocktailService } from '../cocktail.service';
import type { CocktailsSearchSchema, CocktailSearchDocument } from '../cocktail.model';

/**
 * Retrieves all cocktails ordered by title
*/
export const searchCocktails = onCall<CocktailsSearchSchema, Promise<ElasticSearchResults<CocktailSearchDocument>>>(
  async (request) => {
    const cocktailService = getCocktailService();

    try {
      if (!request.auth) {
        throw new HttpsError('unauthenticated', 'User must be authenticated');
      }

      return cocktailService.searchCocktails(request.data);

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
