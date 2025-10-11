import { type Change, onDocumentWritten as firebaseOnDocumentWritten,  } from 'firebase-functions/firestore';
import type { DocumentSnapshot } from 'firebase-admin/firestore';
import type {  CocktailDocument } from '../cocktail.model';
import { EquipmentService } from '../../equipment';
import { getElasticService } from '../../elastic/elastic.service';

export const onDocumentWritten = firebaseOnDocumentWritten('cocktails/{cocktailId}', async (event) => {
  const change = event.data as Change<DocumentSnapshot<CocktailDocument>> | undefined;

  if (!change) {
    return;
  }
  
  const elasticService = getElasticService();

  const after = change.after;

  if (!after) {
    console.info('Document deleted, removing from index', change.before.id);
    await elasticService.deleteDocument('cocktails', change.before.id);
    return;
  }

  const data = after.data();

  const equipmentService = new EquipmentService();

  const [equipment] =  await Promise.all([
    equipmentService.getEquipmentByIds(data?.equipments || []),
  ]);

  console.log('Indexing cocktail', after.id, data, equipment);

  // await elasticService.insertDocument<CocktailSearchDocument>('cocktails', {
  //   id: after.id,
  // });
});
