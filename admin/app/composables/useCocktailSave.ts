import { httpsCallable, getFunctions } from 'firebase/functions';
import { useMutation } from '@tanstack/vue-query';
import type { CocktailDocument, UpdateCocktailDto } from '../../../functions/src/cocktail/cocktail.model';

type SavePayload = {
  id: string;
  cocktailDocument: Partial<CocktailDocument>;
};

export function useCocktailSave() {
  const app = useFirebaseApp();
  const toast = useToast();

  const functions = getFunctions(app);

  const updateCocktail = httpsCallable<UpdateCocktailDto>(functions, 'updateCocktail');

  return useMutation({
    mutationKey: ['save-cocktail'],
    mutationFn: (payload: SavePayload) => updateCocktail({ id: payload.id, ...payload.cocktailDocument }),
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
