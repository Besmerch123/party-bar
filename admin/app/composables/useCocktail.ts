import type { Firestore, DocumentReference, CollectionReference } from 'firebase/firestore';
import { doc, getDoc, collection, where, query, getDocs } from 'firebase/firestore';
import type { CocktailDocument } from '../../../functions/src/cocktail/cocktail.model';
import type { IngredientDocument } from '../../../functions/src/ingredient/ingredient.model';
import type { EquipmentDocument } from '../../../functions/src/equipment/equipment.model';

export function useCocktail(id: string) {
  const db = useFirestore();

  return useAsyncData(`cocktail-${id}`, async () => {
    const docSnap = await loadCocktailDoc(id, db);

    if (!docSnap.exists()) {
      throw new Error(`Cocktail with ID ${id} not found`);
    }

    const cocktailData = docSnap.data();

    const [ingredients, equipments] = await Promise.all([
      loadIngredients(cocktailData.ingredients, db),
      loadEquipments(cocktailData.equipments, db)
    ]);

    return {
      cocktailData,
      ingredients,
      equipments
    };
  });
}

function loadCocktailDoc(id: string, db: Firestore) {
  const docRef = doc(db, 'cocktails', id) as DocumentReference<CocktailDocument>;
  return getDoc(docRef);
}

async function loadIngredients(ingredientRefs: string[], db: Firestore) {
  const sanitizedRefs = ingredientRefs.map(ref => ref.replace(/^\/?ingredients\//, ''));

  const ingredientsCollection = collection(db, 'ingredients') as CollectionReference<IngredientDocument>;
  const q = query(ingredientsCollection, where('__name__', 'in', sanitizedRefs));
  const snap = await getDocs(q);

  return snap.docs;
}

async function loadEquipments(equipmentRefs: string[], db: Firestore) {
  const sanitizedRefs = equipmentRefs.map(ref => ref.replace(/^\/?equipment\//, ''));

  const equipmentCollection = collection(db, 'equipment') as CollectionReference<EquipmentDocument>;
  const q = query(equipmentCollection, where('__name__', 'in', sanitizedRefs));
  const snap = await getDocs(q);

  return snap.docs;
}
