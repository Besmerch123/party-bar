/**
 * Get All Cocktails Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/https';

import { ElasticSearchResults } from '../../elastic/elastic.types';

import { getCocktailService } from '../cocktail.service';
import type { CocktailsSearchSchema, CocktailSearchDocument } from '../cocktail.model';

/**
 * Retrieves all cocktails ordered by title
 *
 * Deliberately open to unauthenticated callers: this is the app's Explore
 * feed (flow 2), which runs before Auth (flow 3) and the bar never gates —
 * see CLAUDE.md's flow order and the flow-04 open-seams notes. It's a
 * read-only public catalogue query with no per-user data, unlike every other
 * callable in this module.
*/
export const searchCocktails = onCall<CocktailsSearchSchema, Promise<ElasticSearchResults<CocktailSearchDocument>>>(
  async (request) => {
    const cocktailService = getCocktailService();

    try {
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
