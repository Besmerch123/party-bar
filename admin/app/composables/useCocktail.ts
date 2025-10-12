import { httpsCallable } from 'firebase/functions';
import { useQuery } from '@tanstack/vue-query';
import type { Cocktail } from '~/types';

export function useCocktail(id: string) {
  const functions = useFunctions();
  const getCocktail = httpsCallable<{ id: string }, Cocktail>(functions, 'getCocktail');

  return useQuery({
    queryKey: ['cocktail', id],
    enabled: !!id && id !== 'create',
    queryFn: async () => {
      const response = await getCocktail({ id });

      return response.data;
    }
  });
}
