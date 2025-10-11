/**
 * Equipment Service
 * 
 * Contains the business logic for equipment operations.
 * Following DDD principles, this is the application service layer.
 */

import { EquipmentRepository } from './equipment.repository';

import { AbstractService } from '../shared/abstract.service';

import { Equipment, CreateEquipmentDto, UpdateEquipmentDto } from './equipment.model';

export class EquipmentService extends AbstractService {
  private readonly repository = new EquipmentRepository();

  /**
   * Creates a new equipment with validation
   */
  async createEquipment(data: CreateEquipmentDto) {
    // Validate input
    this.validateEquipmentData(data);
    
    const image = this.normalizeImage(data.image);
    const normalizedTitle = this.normalizeI18nField(data.title);

    // Create the equipment
    return this.repository.create({
      title: normalizedTitle,
      image,
    });
  }

  /**
   * Retrieves an equipment by ID
   */
  async getEquipment(id: string) {
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
   * @todo Implement pagination and filtering
   */
  async getAllEquipment(): Promise<Equipment[]> {
    return [];
  }

  async getEquipmentByIds(ids: string[]) {
    if (!Array.isArray(ids) || ids.length === 0) {
      return [];
    }

    const trimmedIds = ids
      .map(id => {
        const trimmed = id.trim();
        // Extract ID from path format "equipment/<id>" or use as-is
        return trimmed.replace('equipment/', '');
      })
      .filter(id => id !== '');

    if (trimmedIds.length === 0) {
      return [];
    }
    
    return this.repository.findByIds(trimmedIds);
  }

  /**
   * Updates an existing equipment
   */
  async updateEquipment(data: UpdateEquipmentDto) {
    // Validate update data if provided
    if (data.title !== undefined) {
      this.validateI18nField(data.title);
    }

    const updatePayload: UpdateEquipmentDto = {
      ...data
    };
    if (data.title !== undefined) {
      updatePayload.title = this.normalizeI18nField(data.title);
    }
    if (data.image !== undefined) {
      const image = this.normalizeImage(data.image);
      if (image !== undefined) {
        updatePayload.image = image;
      }
    }

    const updatedEquipment = await this.repository.update(updatePayload);

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
    this.validateI18nField(data.title);
    this.normalizeImage(data.image);
  }
}
