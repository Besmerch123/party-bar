import { httpsCallable } from 'firebase/functions';
import { useMutation, useQueryClient } from '@tanstack/vue-query';
import type { UpdateEquipmentDto } from '~/types';
import { useFunctions } from '~/composables/useFunctions';

export function useEquipmentSave() {
  const toast = useToast();
  const queryClient = useQueryClient();
  const functions = useFunctions();

  const updateEquipment = httpsCallable<UpdateEquipmentDto>(functions, 'updateEquipment');

  return useMutation({
    mutationKey: ['save-equipment'],
    mutationFn: (payload: UpdateEquipmentDto) => updateEquipment(payload),
    onSuccess: (_, variables) => {
      toast.add({
        color: 'success',
        title: 'Equipment saved successfully',
        duration: 5000
      });
      // Invalidate the equipment detail query to refetch
      queryClient.invalidateQueries({ queryKey: ['equipment', variables.id] });
    },
    onError: (error: Error) => {
      toast.add({
        color: 'error',
        title: 'Error saving equipment',
        description: error.message,
        duration: 10000
      });
    }
  });
}
