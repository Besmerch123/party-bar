import { httpsCallable, getFunctions } from 'firebase/functions';
import { useMutation } from '@tanstack/vue-query';
import type { Cocktail } from '~/types';

interface GenerateCocktailRequest {
  /** Desired cocktail name in plain English */
  name: string;
  /** Optional: Additional preferences or notes */
  preferences?: string;
}

export function useCocktailGenerate() {
  const app = useFirebaseApp();
  const toast = useToast();

  const functions = getFunctions(app);

  const generateCocktail = httpsCallable<GenerateCocktailRequest, Cocktail>(functions, 'generateCocktail');

  return useMutation({
    mutationKey: ['generate-cocktail'],
    mutationFn: (request: GenerateCocktailRequest) => generateCocktail(request),
    onSuccess: ({ data: cocktail }) => {
      toast.add({
        color: 'success',
        title: 'Cocktail generated successfully',
        duration: 5000
      });
      navigateTo(`/cocktails/${cocktail.id}`);
    },
    onError: (error: Error) => {
      toast.add({
        color: 'error',
        title: 'Error generating cocktail',
        description: error.message,
        duration: 10000
      });
    }
  });
}
