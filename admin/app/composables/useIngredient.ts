import type { DocumentReference } from 'firebase/firestore';
import { doc, getDoc } from 'firebase/firestore';
import { useQuery } from '@tanstack/vue-query';
import type { IngredientDocument } from '~/types';

export function useIngredient(id: string) {
  const db = useFirestore();

  return useQuery({
    queryKey: ['ingredient', id],
    queryFn: async () => {
      const docRef = doc(db, 'ingredients', id) as DocumentReference<IngredientDocument>;
      const docSnap = await getDoc(docRef);

      if (!docSnap.exists()) {
        throw new Error(`Ingredient with ID ${id} not found`);
      }

      return docSnap.data();
    }
  });
}
