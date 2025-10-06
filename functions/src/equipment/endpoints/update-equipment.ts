/**
 * Update Equipment Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { EquipmentService } from '../equipment.service';
import { UpdateEquipmentDto } from '../equipment.model';

const equipmentService = new EquipmentService();

/**
 * Updates an existing equipment
 */
export const updateEquipment = onCall<UpdateEquipmentDto>(async (request) => {
  try {
    // Basic auth check (you may want to add proper authentication later)
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const updateData = request.data;
    
    if (!updateData.id) {
      throw new HttpsError('invalid-argument', 'Equipment ID is required');
    }

    const equipment = await equipmentService.updateEquipment(updateData);
    
    return  equipment;
  } catch (error) {
    console.error('Error updating equipment:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'An error occurred while updating equipment');
  }
});
