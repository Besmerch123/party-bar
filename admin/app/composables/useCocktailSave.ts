import { httpsCallable } from 'firebase/functions';
import { useMutation } from '@tanstack/vue-query';
import type { UpdateCocktailDto } from '../../../functions/src/cocktail/cocktail.model';
import { useFunctions } from '~/composables/useFunctions';

export function useCocktailSave() {
  const toast = useToast();
  const functions = useFunctions();

  const updateCocktail = httpsCallable<UpdateCocktailDto>(functions, 'updateCocktail');

  return useMutation({
    mutationKey: ['save-cocktail'],
    mutationFn: (payload: UpdateCocktailDto) => updateCocktail(payload),
    onSuccess: () => {
      toast.add({
        color: 'success',
        title: 'Cocktail saved successfully',
        duration: 5000
      });
    },
    onError: (error: Error) => {
      toast.add({
        color: 'error',
        title: 'Error saving cocktail',
        description: error.message,
        duration: 10000
      });
    }
  });
}
