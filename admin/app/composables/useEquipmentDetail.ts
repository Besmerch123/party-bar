import type { DocumentReference } from 'firebase/firestore';
import { doc, getDoc } from 'firebase/firestore';
import { useQuery } from '@tanstack/vue-query';
import type { EquipmentDocument } from '../../../functions/src/equipment/equipment.model';

export function useEquipmentDetail(id: string) {
  const db = useFirestore();

  return useQuery({
    queryKey: ['equipment', id],
    enabled: !!id && id !== 'create',
    queryFn: async () => {
      const docRef = doc(db, 'equipment', id) as DocumentReference<EquipmentDocument>;
      const docSnap = await getDoc(docRef);

      if (!docSnap.exists()) {
        throw new Error(`Equipment with ID ${id} not found`);
      }

      return {
        equipment: docSnap.data()
      };
    }
  });
}
