import { httpsCallable } from 'firebase/functions';
import { useMutation, useQueryClient } from '@tanstack/vue-query';
import type { UpdateIngredientDto, CreateIngredientDto, Ingredient } from '~/types';
import { useFunctions } from '~/composables/useFunctions';

export function useIngredientSave() {
  const toast = useToast();
  const queryClient = useQueryClient();
  const functions = useFunctions();

  const createIngredient = httpsCallable<CreateIngredientDto, Ingredient>(functions, 'createIngredient');
  const updateIngredient = httpsCallable<UpdateIngredientDto, Ingredient>(functions, 'updateIngredient');

  return useMutation({
    mutationKey: ['save-ingredient'],
    mutationFn: (payload: UpdateIngredientDto | CreateIngredientDto) => {
      if (isCreatePayload(payload)) {
        return createIngredient(payload);
      }

      return updateIngredient(payload);
    },
    onSuccess: ({ data }, variables) => {
      toast.add({
        color: 'success',
        title: 'Ingredient saved successfully',
        duration: 5000
      });

      if (isCreatePayload(variables)) {
        navigateTo(`/ingredients/${data.id}`);
      } else {
        queryClient.invalidateQueries({ queryKey: ['ingredient', data.id] });
      }
    },
    onError: (error: Error) => {
      toast.add({
        color: 'error',
        title: 'Error saving ingredient',
        description: error.message,
        duration: 10000
      });
    }
  });
}

function isCreatePayload(payload: UpdateIngredientDto | CreateIngredientDto): payload is CreateIngredientDto {
  return !('id' in payload) || !payload.id;
}
