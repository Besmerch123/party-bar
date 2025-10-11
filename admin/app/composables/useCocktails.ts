import { useQuery } from '@tanstack/vue-query';
import { refDebounced } from '@vueuse/core';
import { httpsCallable } from 'firebase/functions';
import type { ElasticSearchResults, CocktailSearchDocument, CocktailsSearchSchema } from '~/types';

const PAGE_SIZE = 10;

export function useCocktails() {
  // const db = useFirestore();
  // const cocktailsCollection = collection(db, 'cocktails') as CollectionReference<CocktailDocument>;

  const functions = useFunctions();

  const searchCocktails = httpsCallable<CocktailsSearchSchema, ElasticSearchResults<CocktailSearchDocument>>(functions, 'searchCocktails');

  const search = ref('');
  const page = ref(1);
  const filters = reactive<NonNullable<CocktailsSearchSchema['filters']>>({});

  const debouncedSearch = refDebounced(search, 1000);

  watch([filters, debouncedSearch], () => {
    page.value = 1;
  });

  const { data, isLoading } = useQuery({
    queryKey: ['cocktails', debouncedSearch, page, filters],
    queryFn: async () => {
      const result = await searchCocktails({
        query: debouncedSearch.value,
        filters,
        pagination: {
          pageSize: PAGE_SIZE,
          page: page.value
        }
      });

      return result.data;
    }
  });

  return {
    data,
    search,
    page,
    filters,
    isLoading
  };
}
