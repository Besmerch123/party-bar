import {
  collection,
  query,
  orderBy,
  limit,
  startAfter,
  where,
  getDocs
} from 'firebase/firestore';
import type { CollectionReference, DocumentSnapshot } from 'firebase/firestore';
import { useInfiniteQuery } from '@tanstack/vue-query';
import type { IngredientCategory, IngredientDocument } from '~/types';

const PAGE_SIZE = 20;

type Filters = {
  category?: IngredientCategory;
};

export function useIngredients() {
  const db = useFirestore();
  const ingredientsCollection = collection(db, 'ingredients') as CollectionReference<IngredientDocument>;

  const filters = reactive<Filters>({
    category: undefined
  });

  const { data, ...queryResult } = useInfiniteQuery({
    queryKey: ['ingredients', filters],
    queryFn: async ({ pageParam }) => {
      const constraints = [];

      // Add category filter if specified
      if (filters.category) {
        constraints.push(where('category', '==', filters.category));
        // When filtering by category, order by category first to avoid needing a composite index
        constraints.push(orderBy('category'));
      } else {
        constraints.push(orderBy('createdAt', 'desc'));
      }

      // Add ordering and pagination

      if (pageParam) {
        constraints.push(startAfter(pageParam));
      }

      constraints.push(limit(PAGE_SIZE));

      const q = query(ingredientsCollection, ...constraints);

      const snapshot = await getDocs(q);
      const ingredients = snapshot.docs;

      return {
        ingredients,
        lastDoc: snapshot.docs.at(-1) || null,
        hasMore: snapshot.docs.length === PAGE_SIZE
      };
    },
    initialPageParam: undefined as DocumentSnapshot | undefined,
    getNextPageParam: (lastPage) => {
      // Return the last document if there are more pages, otherwise undefined
      return lastPage.hasMore ? lastPage.lastDoc : undefined;
    },
    getPreviousPageParam: () => {
      // Firebase cursor pagination doesn't support going backwards easily
      // Return undefined to disable previous page functionality
      return undefined;
    }
  });

  return {
    data,
    filters,
    ...queryResult
  };
}
