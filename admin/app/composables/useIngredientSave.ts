import { httpsCallable, getFunctions } from 'firebase/functions';
import { useMutation, useQueryClient } from '@tanstack/vue-query';
import type { UpdateIngredientDto } from '~/types';

export function useIngredientSave() {
  const app = useFirebaseApp();
  const toast = useToast();
  const queryClient = useQueryClient();

  const functions = getFunctions(app);

  const updateIngredient = httpsCallable<UpdateIngredientDto>(functions, 'updateIngredient');

  return useMutation({
    mutationKey: ['save-ingredient'],
    mutationFn: (payload: UpdateIngredientDto) => updateIngredient(payload),
    onSuccess: (_, variables) => {
      toast.add({
        color: 'success',
        title: 'Ingredient saved successfully',
        duration: 5000
      });
      // Invalidate the ingredient detail query to refetch
      queryClient.invalidateQueries({ queryKey: ['ingredient', variables.id] });
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
