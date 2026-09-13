import type { FormSubmitEvent } from '@nuxt/ui';
import { useMutation } from '@tanstack/vue-query';
import { httpsCallable } from 'firebase/functions';
import type { Cocktail, Equipment, Ingredient, IngredientMeasure } from '~/types';

import { useCocktailSave } from './useCocktailSave';

type FormState = Omit<Cocktail, 'id' | 'createdAt' | 'updatedAt'>;

/** A copy of `source` without `key`. */
function omitKey<T>(source: Record<string, T> | undefined, key: string): Record<string, T> {
  return Object.fromEntries(Object.entries(source ?? {}).filter(([k]) => k !== key));
}

export function useCocktailForm(cocktail?: Cocktail) {
  const state = reactive<FormState>({
    title: { en: '', uk: '', ...cocktail?.title },
    description: { en: '', uk: '', ...cocktail?.description },
    abv: cocktail?.abv,
    image: cocktail?.image ?? '',
    preparationSteps: { en: [''], uk: [''], ...cocktail?.preparationSteps },
    categories: cocktail?.categories || [],
    ingredients: [...cocktail?.ingredients || []],
    equipments: [...cocktail?.equipments || []],

    // The recipe vocabulary Explore filters and sorts on. Left null the drink
    // matches none of those filters, so these are the fields most worth
    // filling in -- but null is still a legitimate "not decided yet".
    prepTimeMinutes: cocktail?.prepTimeMinutes ?? null,
    method: cocktail?.method ?? null,
    baseSpirit: cocktail?.baseSpirit ?? null,
    flavor: cocktail?.flavor ?? null,
    popularity: cocktail?.popularity ?? null,
    seasonalScore: cocktail?.seasonalScore ?? null,

    measures: { ...cocktail?.measures },
    pourSteps: [...cocktail?.pourSteps || []]
  });

  /**
   * Removing an ingredient takes its measure with it.
   *
   * The stored map is keyed by ingredient id and the backend rejects a key the
   * recipe does not list, so a left-behind measure is not merely untidy -- it
   * fails the next save with an error about an ingredient that is no longer
   * on screen.
   */
  const removeIngredient = (id: string) => {
    state.ingredients = state.ingredients.filter(ing => ing.id !== id);
    state.measures = omitKey(state.measures, id);
  };

  const removeEquipment = (id: string) => {
    state.equipments = state.equipments.filter(eq => eq.id !== id);
  };

  /** Writes one ingredient's measure back into the map the recipe stores. */
  const setMeasure = (id: string, value: IngredientMeasure | undefined) => {
    state.measures = value
      ? { ...state.measures, [id]: value }
      : omitKey(state.measures, id);
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

    // `equipment`, singular -- that is the collection name. This used to write
    // "equipments/", which survived only because reads take the last path
    // segment and ignore the rest.
    const equipments = data.equipments.map(eq => `equipment/${eq.id}`);

    // Only measures for ingredients still on the recipe, so a stale key cannot
    // fail the save.
    const ingredientIds = new Set(data.ingredients.map(ing => ing.id));
    const measures = Object.fromEntries(
      Object.entries(data.measures ?? {}).filter(([id]) => ingredientIds.has(id))
    );

    await save({
      ...data,
      id: cocktail.id,
      ingredients,
      equipments,
      measures
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
    setMeasure,

    addEquipment,
    isAddingEquipment,
    removeEquipment,

    submit,
    isSaving: isPending
  };
}
