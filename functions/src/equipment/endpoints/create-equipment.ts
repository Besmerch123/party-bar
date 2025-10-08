/**
 * Create Equipment Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/https';
import { EquipmentService } from '../equipment.service';
import { CreateEquipmentDto } from '../equipment.model';

const equipmentService = new EquipmentService();

/**
 * Creates a new equipment
 */
export const createEquipment = onCall(async (request) => {
  try {
    // Basic auth check (you may want to add proper authentication later)
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const data = request.data as CreateEquipmentDto;
    
    if (!data) {
      throw new HttpsError('invalid-argument', 'Equipment data is required');
    }

    const equipment = await equipmentService.createEquipment(data);
    
    return {
      success: true,
      data: equipment,
    };
  } catch (error) {
    console.error('Error creating equipment:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'An error occurred while creating equipment');
  }
});
