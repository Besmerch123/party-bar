import { httpsCallable, getFunctions } from 'firebase/functions';
import { useMutation } from '@tanstack/vue-query';
import type { CocktailDocument, UpdateCocktailDto } from '../../../functions/src/cocktail/cocktail.model';
import { useLocale } from './useLocale';

type SavePayload = {
  id: string;
  cocktailDocument: Partial<CocktailDocument>;
};

export function useCocktailSave() {
  const app = useFirebaseApp();
  const toast = useToast();
  const locale = useLocale();

  const functions = getFunctions(app);

  const updateCocktail = httpsCallable<UpdateCocktailDto>(functions, 'updateCocktail');

  return useMutation({
    mutationKey: ['save-cocktail', locale],
    mutationFn: (payload: SavePayload) => updateCocktail({ id: payload.id, ...payload.cocktailDocument }),
    onSuccess: () => {
      toast.add({
        color: 'success',
        title: 'Cocktail saved successfully',
        duration: 5000
      });
    }
  });
}
