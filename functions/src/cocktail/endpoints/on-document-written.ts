import { type Change, onDocumentWritten as firebaseOnDocumentWritten,  } from 'firebase-functions/firestore';
import type { DocumentSnapshot } from 'firebase-admin/firestore';
import {  CocktailDocument } from '../cocktail.model';
import { SUPPORTED_LOCALES } from '../../shared/types';
import { getElasticService } from '../../elastic/elastic.service';

export const onDocumentWritten = firebaseOnDocumentWritten('cocktails/{cocktailId}', async (event) => {
  const change = event.data as Change<DocumentSnapshot<CocktailDocument>> | undefined;

  if (!change) {
    return;
  }

  const after = change.after;

  console.log(after.id, after.data());

  const elasticService = getElasticService();

  for (const locale of SUPPORTED_LOCALES) {
    const data = after.data();

    await elasticService.insertDocument('cocktails', locale, {
      id: after.id,
      title: data?.title?.[locale] ?? '',
      description: data?.description?.[locale] ?? '',
    });
  }

});
