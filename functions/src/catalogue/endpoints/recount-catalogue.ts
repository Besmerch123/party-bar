/**
 * Recount Catalogue Endpoint
 *
 * Recomputes the derived figures on ingredients and equipment. Triggered from
 * the admin panel rather than on every cocktail write: one cocktail edit can
 * move the numbers on a dozen ingredients, so doing it per-write would mean a
 * fan-out of updates for a figure nothing reads in real time.
 */

import { onCall, HttpsError } from 'firebase-functions/https';

import { runCatalogueRecount, type RecountResult } from '../catalogue.stats';

export const recountCatalogue = onCall<void, Promise<RecountResult>>(
  { timeoutSeconds: 540 },
  async (request) => {
    try {
      if (!request.auth) {
        throw new HttpsError('unauthenticated', 'User must be authenticated');
      }

      const result = await runCatalogueRecount();

      console.info('Catalogue recount complete', result);

      return result;
    } catch (error) {
      console.error('Error recounting catalogue:', error);

      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError(
        'internal',
        error instanceof Error ? error.message : 'An error occurred while recounting the catalogue'
      );
    }
  }
);
