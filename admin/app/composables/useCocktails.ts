import {
  collection,
  doc,
  query,
  orderBy,
  limit,
  startAfter,
  getDocs,
  getDoc
} from 'firebase/firestore'
import type { CollectionReference, DocumentSnapshot } from 'firebase/firestore'
import type { CocktailDocument } from '../../../functions/src/cocktail/cocktail.model'

export interface PaginationOptions {
  pageSize?: number
  lastDoc?: DocumentSnapshot
}

export function useCocktails() {
  const db = useFirestore()
  const cocktailsCollection = collection(db, 'cocktails') as CollectionReference<CocktailDocument>

  /**
   * Fetch cocktails with pagination
   */
  const fetchCocktails = (options?: PaginationOptions) => {
    const pageSize = options?.pageSize || 20

    return useAsyncData(
      `cocktails-${pageSize}-${options?.lastDoc?.id || 'initial'}`,
      async () => {
        let q = query(
          cocktailsCollection,
          orderBy('createdAt', 'desc'),
          limit(pageSize)
        )

        if (options?.lastDoc) {
          q = query(
            cocktailsCollection,
            orderBy('createdAt', 'desc'),
            startAfter(options.lastDoc),
            limit(pageSize)
          )
        }

        const snapshot = await getDocs(q)
        const cocktails = snapshot.docs

        return {
          cocktails,
          lastDoc: snapshot.docs.at(-1) || null,
          hasMore: snapshot.docs.length === pageSize
        }
      }
    )
  }

  /**
   * Fetch a single cocktail by ID
   */
  const fetchCocktailById = (id: string) => {
    return useAsyncData(`cocktail-${id}`, async () => {
      const docRef = doc(db, 'cocktails', id)
      const docSnap = await getDoc(docRef)

      if (!docSnap.exists()) {
        throw new Error(`Cocktail with ID ${id} not found`)
      }

      return {
        id: docSnap.id,
        ...docSnap.data()
      }
    })
  }

  return {
    fetchCocktails,
    fetchCocktailById
  }
}
