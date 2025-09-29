/**
 * Equipment Service
 * 
 * Contains the business logic for equipment operations.
 * Following DDD principles, this is the application service layer.
 */

import { EquipmentRepository } from './equipment.repository';
import { Equipment, CreateEquipmentDto, UpdateEquipmentDto } from './equipment.model';

export class EquipmentService {
  private readonly repository = new EquipmentRepository();

  /**
   * Creates a new equipment with validation
   */
  async createEquipment(data: CreateEquipmentDto): Promise<Equipment> {
    // Validate input
    this.validateEquipmentData(data);
    
    // Check for duplicate titles
    const exists = await this.repository.existsByTitle(data.title.trim());
    if (exists) {
      throw new Error('An equipment with this title already exists');
    }

    // Create the equipment
    return await this.repository.create({
      title: data.title.trim(),
    });
  }

  /**
   * Retrieves an equipment by ID
   */
  async getEquipment(id: string): Promise<Equipment> {
    if (!id || id.trim() === '') {
      throw new Error('Equipment ID is required');
    }

    const equipment = await this.repository.findById(id.trim());
    if (!equipment) {
      throw new Error('Equipment not found');
    }

    return equipment;
  }

  /**
   * Retrieves all equipment
   */
  async getAllEquipment(): Promise<Equipment[]> {
    return await this.repository.findAll();
  }

  /**
   * Updates an existing equipment
   */
  async updateEquipment(id: string, data: UpdateEquipmentDto): Promise<Equipment> {
    if (!id || id.trim() === '') {
      throw new Error('Equipment ID is required');
    }

    // Validate update data if provided
    if (data.title !== undefined) {
      this.validateTitle(data.title);
      data.title = data.title.trim();
    }

    // Check for duplicate titles if title is being updated
    if (data.title) {
      const exists = await this.repository.existsByTitle(data.title);
      if (exists) {
        // Check if it's the same equipment
        const existing = await this.repository.findById(id.trim());
        if (!existing || existing.title.toLowerCase() !== data.title.toLowerCase()) {
          throw new Error('An equipment with this title already exists');
        }
      }
    }

    const updatedEquipment = await this.repository.update(id.trim(), data);
    if (!updatedEquipment) {
      throw new Error('Equipment not found');
    }

    return updatedEquipment;
  }

  /**
   * Deletes an equipment
   */
  async deleteEquipment(id: string): Promise<void> {
    if (!id || id.trim() === '') {
      throw new Error('Equipment ID is required');
    }

    const deleted = await this.repository.delete(id.trim());
    if (!deleted) {
      throw new Error('Equipment not found');
    }
  }

  /**
   * Validates equipment data
   */
  private validateEquipmentData(data: CreateEquipmentDto): void {
    this.validateTitle(data.title);
  }

  /**
   * Validates equipment title
   */
  private validateTitle(title: string): void {
    if (!title || typeof title !== 'string') {
      throw new Error('Title is required and must be a string');
    }

    const trimmedTitle = title.trim();
    if (trimmedTitle.length === 0) {
      throw new Error('Title cannot be empty');
    }

    if (trimmedTitle.length < 2) {
      throw new Error('Title must be at least 2 characters long');
    }

    if (trimmedTitle.length > 100) {
      throw new Error('Title cannot exceed 100 characters');
    }
  }
}
