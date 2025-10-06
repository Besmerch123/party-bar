import { httpsCallable, getFunctions } from 'firebase/functions';
import { useMutation, useQueryClient } from '@tanstack/vue-query';
import type { EquipmentDocument } from '../../../functions/src/equipment/equipment.model';

type SavePayload = {
  id: string;
  equipmentDocument: Partial<EquipmentDocument>;
};

export function useEquipmentSave() {
  const app = useFirebaseApp();
  const toast = useToast();
  const queryClient = useQueryClient();

  const functions = getFunctions(app);

  const updateEquipment = httpsCallable(functions, 'updateEquipment');

  return useMutation({
    mutationKey: ['save-equipment'],
    mutationFn: (payload: SavePayload) => updateEquipment({ id: payload.id, ...payload.equipmentDocument }),
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
