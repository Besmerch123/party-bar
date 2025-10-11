import { type Change, onDocumentWritten as firebaseOnDocumentWritten } from 'firebase-functions/firestore';
import type { DocumentSnapshot } from 'firebase-admin/firestore';

import type {  CocktailDocument } from '../cocktail.model';
import { getCocktailService } from '../cocktail.service';

export const onDocumentWritten = firebaseOnDocumentWritten('cocktails/{cocktailId}', async (event) => {
  const change = event.data as Change<DocumentSnapshot<CocktailDocument>> | undefined;

  if (!change) {
    return;
  }
  
  const cocktailService = getCocktailService();

  const after = change.after;

  if (!after) {
    console.info('Document deleted, removing from index', change.before.id);
    await cocktailService.repository.elastic.deleteDocument('cocktails', change.before.id);
    return;
  }

  await cocktailService.insertCocktailToElasticIndex(after);
});

