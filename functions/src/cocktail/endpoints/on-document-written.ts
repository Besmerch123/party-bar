import { type Change, onDocumentWritten as firebaseOnDocumentWritten,  } from 'firebase-functions/firestore';
import type { DocumentSnapshot } from 'firebase-admin/firestore';

import type {  CocktailDocument, CocktailSearchDocument } from '../cocktail.model';
import { EquipmentDocument, EquipmentService } from '../../equipment';
import { IngredientDocument, IngredientService } from '../../ingredient';
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
  const ingredientService = new IngredientService();

  const [equipment, ingredients] =  await Promise.all([
    equipmentService.getEquipmentByIds(data?.equipments || []),
    ingredientService.getIngredientsByIds(data?.ingredients || []),
  ]);

  const cocktailSearchDoc = toCocktailSearchDocument(after, equipment, ingredients);

  console.info('Inserting document in index', after.id, cocktailSearchDoc);

  await elasticService.insertDocument<CocktailSearchDocument>('cocktails', cocktailSearchDoc);
});

function toCocktailSearchDocument(
  cocktailDoc: DocumentSnapshot<CocktailDocument>,
  equipmentSnapshots: DocumentSnapshot<EquipmentDocument>[],
  ingredientSnapshots: DocumentSnapshot<IngredientDocument>[]
): CocktailSearchDocument {
  const cocktailData = cocktailDoc.data();

  const ingredients: CocktailSearchDocument['ingredients'] = ingredientSnapshots.map((ingredient) => {
    const data = ingredient.data();

    return {
      id: ingredient.id,
      title: data?.title || {},
      category: data!.category,
      image: data?.image,
    };
  });

  const equipment: CocktailSearchDocument['equipment'] = equipmentSnapshots.map((equip) => {
    const data = equip.data();

    return {
      id: equip.id,
      title: data?.title || {},
      image: data?.image,
    };
  });

  return {
    id: cocktailDoc.id,
    title: cocktailData?.title || {}, 
    categories: cocktailData?.categories || [],
    description: cocktailData?.description || {},
    abv: cocktailData?.abv || 0,
    image: cocktailData?.image,
    ingredients,
    equipment
  };
}
