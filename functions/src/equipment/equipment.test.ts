/**
 * Equipment Domain Tests
 * 
 * Basic test examples for the equipment functionality.
 * You can expand these with a proper testing framework later.
 */

import { EquipmentService } from './equipment.service';
import { CreateEquipmentDto } from './equipment.model';

// Example usage (for testing locally)
export async function testEquipmentOperations() {
  const equipmentService = new EquipmentService();

  try {
    console.log('=== Equipment Domain Test ===');

    // Test 1: Create equipment
    console.log('\n1. Creating equipment...');
    const newEquipment: CreateEquipmentDto = {
      title: 'Boston Shaker',
    };

    const createdEquipment = await equipmentService.createEquipment(newEquipment);
    console.log('Created:', createdEquipment);

    // Test 2: Get equipment by ID
    console.log('\n2. Getting equipment by ID...');
    const retrievedEquipment = await equipmentService.getEquipment(createdEquipment.id);
    console.log('Retrieved:', retrievedEquipment);

    // Test 3: Get all equipment
    console.log('\n3. Getting all equipment...');
    const allEquipment = await equipmentService.getAllEquipment();
    console.log('All equipment:', allEquipment);

    // Test 4: Update equipment
    console.log('\n4. Updating equipment...');
    const updatedEquipment = await equipmentService.updateEquipment(createdEquipment.id, {
      title: 'Professional Boston Shaker',
    });
    console.log('Updated:', updatedEquipment);

    // Test 5: Delete equipment
    console.log('\n5. Deleting equipment...');
    await equipmentService.deleteEquipment(createdEquipment.id);
    console.log('Equipment deleted successfully');

    console.log('\n=== All tests completed ===');
  } catch (error) {
    console.error('Test failed:', error);
  }
}

// Uncomment to run tests locally
// testEquipmentOperations();
