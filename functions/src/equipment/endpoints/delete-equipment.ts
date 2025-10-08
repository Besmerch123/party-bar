/**
 * Delete Equipment Endpoint
 */

import { onCall, HttpsError } from 'firebase-functions/https';
import { EquipmentService } from '../equipment.service';

const equipmentService = new EquipmentService();

/**
 * Deletes an equipment by ID
 */
export const deleteEquipment = onCall(async (request) => {
  try {
    // Basic auth check (you may want to add proper authentication later)
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { id } = request.data;
    
    if (!id) {
      throw new HttpsError('invalid-argument', 'Equipment ID is required');
    }

    await equipmentService.deleteEquipment(id);
    
    return {
      success: true,
      message: 'Equipment deleted successfully',
    };
  } catch (error) {
    console.error('Error deleting equipment:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', error instanceof Error ? error.message : 'An error occurred while deleting equipment');
  }
});
