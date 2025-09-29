/**
 * Get All Equipment Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { EquipmentService } from '../equipment.service';

const equipmentService = new EquipmentService();

/**
 * Retrieves all equipment ordered by title
 */
export const getAllEquipment = onCall(async (request) => {
  try {
    // Basic auth check (you may want to add proper authentication later)
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const equipment = await equipmentService.getAllEquipment();
    
    return {
      success: true,
      data: equipment,
    };
  } catch (error) {
    console.error('Error getting all equipment:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'An error occurred while retrieving equipment');
  }
});
