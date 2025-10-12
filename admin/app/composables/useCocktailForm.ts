import type { FormSubmitEvent } from '@nuxt/ui';
import { useMutation } from '@tanstack/vue-query';
import { httpsCallable } from 'firebase/functions';
import type { Cocktail, Equipment, Ingredient } from '~/types';

import { useCocktailSave } from './useCocktailSave';

type FormState = Omit<Cocktail, 'id' | 'createdAt' | 'updatedAt'>;

export function useCocktailForm(cocktail?: Cocktail) {
  const state = reactive<FormState>({
    title: { en: '', uk: '', ...cocktail?.title },
    description: { en: '', uk: '', ...cocktail?.description },
    abv: cocktail?.abv,
    image: cocktail?.image ?? '',
    preparationSteps: { en: [''], uk: [''], ...cocktail?.preparationSteps },
    categories: cocktail?.categories || [],
    ingredients: [...cocktail?.ingredients || []],
    equipments: [...cocktail?.equipments || []]
  });

  const removeIngredient = (id: string) => {
    state.ingredients = state.ingredients.filter(ing => ing.id !== id);
  };

  const removeEquipment = (id: string) => {
    state.equipments = state.equipments.filter(eq => eq.id !== id);
  };

  const { mutateAsync: save, isPending } = useCocktailSave();

  const toast = useToast();

  const submit = async (event: FormSubmitEvent<FormState>) => {
    if (!cocktail?.id) {
      toast.add({
        color: 'error',
        title: 'Can not save',
        description: 'Cocktail ID is missing'
      });
      return;
    }

    const data = event.data;

    const ingredients = data.ingredients.map(ing => `ingredients/${ing.id}`);
    const equipments = data.equipments.map(eq => `equipments/${eq.id}`);

    await save({
      ...data,
      id: cocktail.id,
      ingredients,
      equipments
    });
  };

  const functions = useFunctions();

  const getIngredient = httpsCallable<{ id: string }, Ingredient>(functions, 'getIngredient');
  const { mutateAsync: addIngredient, isPending: isAddingIngredient } = useMutation({
    mutationKey: ['add-ingredient'],
    mutationFn: async (id: string) => {
      if (state.ingredients.find(ing => ing.id === id)) {
        toast.add({
          color: 'warning',
          title: 'Ingredient already added',
          description: 'This ingredient is already in the list'
        });
        return;
      }

      const response = await getIngredient({ id });

      return response.data;
    },
    onSuccess: (data) => {
      if (!data) return;
      state.ingredients.push(data);

      toast.add({
        color: 'success',
        title: 'Ingredient added',
        description: 'The ingredient has been added to the list'
      });
    }
  });

  const getEquipment = httpsCallable<{ id: string }, Equipment>(functions, 'getEquipment');
  const { mutateAsync: addEquipment, isPending: isAddingEquipment } = useMutation({
    mutationKey: ['add-equipment'],
    mutationFn: async (id: string) => {
      if (state.equipments.find(eq => eq.id === id)) {
        toast.add({
          color: 'warning',
          title: 'Equipment already added',
          description: 'This equipment is already in the list'
        });
        return;
      }

      const response = await getEquipment({ id });

      return response.data;
    },
    onSuccess: (data) => {
      if (!data) return;
      state.equipments.push(data);

      toast.add({
        color: 'success',
        title: 'Equipment added',
        description: 'The equipment has been added to the list'
      });
    }
  });

  return {
    state,

    addIngredient,
    isAddingIngredient,
    removeIngredient,

    addEquipment,
    isAddingEquipment,
    removeEquipment,

    submit,
    isSaving: isPending
  };
}
