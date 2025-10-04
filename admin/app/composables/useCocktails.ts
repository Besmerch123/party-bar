import {
  collection,
  query,
  orderBy,
  limit,
  startAfter,
  getDocs
} from 'firebase/firestore';
import type { CollectionReference, DocumentSnapshot } from 'firebase/firestore';
import { useInfiniteQuery } from '@tanstack/vue-query';
import type { CocktailDocument } from '../../../functions/src/cocktail/cocktail.model';

const PAGE_SIZE = 25;

export function useCocktails() {
  const db = useFirestore();
  const cocktailsCollection = collection(db, 'cocktails') as CollectionReference<CocktailDocument>;

  return useInfiniteQuery({
    queryKey: ['cocktails'],
    queryFn: async ({ pageParam }) => {
      let q = query(
        cocktailsCollection,
        orderBy('createdAt', 'desc'),
        limit(PAGE_SIZE)
      );

      if (pageParam) {
        q = query(
          cocktailsCollection,
          orderBy('createdAt', 'desc'),
          startAfter(pageParam),
          limit(PAGE_SIZE)
        );
      }

      const snapshot = await getDocs(q);
      const cocktails = snapshot.docs;

      return {
        cocktails,
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
}
