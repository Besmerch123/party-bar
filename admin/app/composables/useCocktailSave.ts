import { httpsCallable, getFunctions, connectFunctionsEmulator } from 'firebase/functions';
import { useMutation } from '@tanstack/vue-query';
import type { CocktailDocument, UpdateCocktailDto } from '../../../functions/src/cocktail/cocktail.model';
import type { SupportedLocale } from '../../../functions/src/shared/types';
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

  connectFunctionsEmulator(functions, 'localhost', 5001);

  const updateCocktail = httpsCallable<UpdateCocktailDto>(functions, 'updateCocktail');

  return useMutation({
    mutationKey: ['save-cocktail', locale],
    mutationFn: (payload: SavePayload) => updateCocktail(documentToPayload(payload.id, payload.cocktailDocument, locale.value)),
    onSuccess: () => {
      toast.add({
        color: 'success',
        title: 'Cocktail saved successfully',
        duration: 5000
      });
    }
  });
}

function documentToPayload(id: string, cocktailDocument: Partial<CocktailDocument>, locale: SupportedLocale) {
  const payload: UpdateCocktailDto = {
    id,
    title: cocktailDocument?.title?.[locale],
    description: cocktailDocument?.description?.[locale],
    ingredients: cocktailDocument?.ingredients,
    equipments: cocktailDocument?.equipments,
    categories: cocktailDocument?.categories
  };

  return payload;
}
