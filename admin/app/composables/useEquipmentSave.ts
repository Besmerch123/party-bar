import { httpsCallable } from 'firebase/functions';
import { useMutation, useQueryClient } from '@tanstack/vue-query';
import type { UpdateEquipmentDto, CreateEquipmentDto, Equipment } from '~/types';
import { useFunctions } from '~/composables/useFunctions';

export function useEquipmentSave() {
  const toast = useToast();
  const queryClient = useQueryClient();
  const functions = useFunctions();

  const createEquipment = httpsCallable<CreateEquipmentDto, Equipment>(functions, 'createEquipment');
  const updateEquipment = httpsCallable<UpdateEquipmentDto, Equipment>(functions, 'updateEquipment');

  return useMutation({
    mutationKey: ['save-equipment'],
    mutationFn: (payload: UpdateEquipmentDto | CreateEquipmentDto) => {
      if (isCreatePayload(payload)) {
        return createEquipment(payload);
      }

      return updateEquipment(payload);
    },
    onSuccess: ({ data }, variables) => {
      toast.add({
        color: 'success',
        title: 'Equipment saved successfully',
        duration: 5000
      });

      if (isCreatePayload(variables)) {
        navigateTo(`/equipment/${data.id}`);
      } else {
        queryClient.invalidateQueries({ queryKey: ['equipment', data.id] });
      }
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

function isCreatePayload(payload: UpdateEquipmentDto | CreateEquipmentDto): payload is CreateEquipmentDto {
  return !('id' in payload) || !payload.id;
}
