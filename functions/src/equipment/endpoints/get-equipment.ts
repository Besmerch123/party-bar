/**
 * Get Equipment Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/https';
import { EquipmentService } from '../equipment.service';
import type { Equipment } from '../equipment.model';

const equipmentService = new EquipmentService();

/**
 * Retrieves an equipment by ID
 */
export const getEquipment = onCall<{ id: string }, Promise<Equipment>>(async (request) => {
  try {
    // Basic auth check (you may want to add proper authentication later)
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { id } = request.data;
    
    if (!id) {
      throw new HttpsError('invalid-argument', 'Equipment ID is required');
    }

    return equipmentService.getEquipment(id);
    
  } catch (error) {
    console.error('Error getting equipment:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'An error occurred while retrieving equipment');
  }
});
