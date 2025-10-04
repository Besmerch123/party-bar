/**
 * Equipment Service
 * 
 * Contains the business logic for equipment operations.
 * Following DDD principles, this is the application service layer.
 */

import { EquipmentRepository } from './equipment.repository';
import { Equipment, CreateEquipmentDto, UpdateEquipmentDto } from './equipment.model';
import { I18nField } from '../shared/types';

export class EquipmentService {
  private readonly repository = new EquipmentRepository();

  /**
   * Creates a new equipment with validation
   */
  async createEquipment(data: CreateEquipmentDto): Promise<Equipment> {
    // Validate input
    this.validateEquipmentData(data);
    
    const image = this.normalizeImage(data.image);
    const normalizedTitle = this.normalizeI18nField(data.title);

    // Check for duplicate titles in all locales
    for (const locale of Object.keys(normalizedTitle)) {
      const titleValue = normalizedTitle[locale as keyof typeof normalizedTitle];
      if (titleValue) {
        const exists = await this.repository.existsByTitle(titleValue, locale);
        if (exists) {
          throw new Error(`An equipment with this title already exists in locale: ${locale}`);
        }
      }
    }

    // Create the equipment
    return await this.repository.create({
      title: normalizedTitle,
      image,
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
      this.validateI18nField(data.title);
    }

    // Check for duplicate titles if title is being updated
    if (data.title) {
      const normalizedTitle = this.normalizeI18nField(data.title);
      const existing = await this.repository.findById(id.trim());
      
      for (const locale of Object.keys(normalizedTitle)) {
        const titleValue = normalizedTitle[locale as keyof typeof normalizedTitle];
        if (titleValue) {
          const exists = await this.repository.existsByTitle(titleValue, locale);
          if (exists) {
            // Check if it's the same equipment
            if (!existing || existing.title[locale as keyof typeof existing.title]?.toLowerCase() !== titleValue.toLowerCase()) {
              throw new Error(`An equipment with this title already exists in locale: ${locale}`);
            }
          }
        }
      }
    }

    const updatePayload: UpdateEquipmentDto = {};
    if (data.title !== undefined) {
      updatePayload.title = this.normalizeI18nField(data.title);
    }
    if (data.image !== undefined) {
      const image = this.normalizeImage(data.image);
      if (image !== undefined) {
        updatePayload.image = image;
      }
    }

    const updatedEquipment = await this.repository.update(id.trim(), updatePayload);
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

  /**
   * Validates I18n field (translatable field)
   */
  private validateI18nField(field: I18nField): void {
    if (!field || typeof field !== 'object') {
      throw new Error('Title is required and must be an object with locale keys');
    }

    const locales = Object.keys(field);
    if (locales.length === 0) {
      throw new Error('Title must have at least one locale');
    }

    for (const locale of locales) {
      const value = field[locale as keyof typeof field];
      if (value !== undefined) {
        this.validateTitleValue(value, locale);
      }
    }
  }

  /**
   * Validates a single title value for a specific locale
   */
  private validateTitleValue(title: string, locale: string): void {
    if (typeof title !== 'string') {
      throw new Error(`Title for locale '${locale}' must be a string`);
    }

    const trimmedTitle = title.trim();
    if (trimmedTitle.length === 0) {
      throw new Error(`Title for locale '${locale}' cannot be empty`);
    }

    if (trimmedTitle.length < 2) {
      throw new Error(`Title for locale '${locale}' must be at least 2 characters long`);
    }

    if (trimmedTitle.length > 100) {
      throw new Error(`Title for locale '${locale}' cannot exceed 100 characters`);
    }
  }

  /**
   * Normalizes I18n field by trimming all locale values
   */
  private normalizeI18nField(field: I18nField): I18nField {
    const normalized: I18nField = {};
    for (const locale of Object.keys(field)) {
      const value = field[locale as keyof typeof field];
      if (value !== undefined && typeof value === 'string') {
        normalized[locale as keyof typeof normalized] = value.trim();
      }
    }
    return normalized;
  }

  /**
   * Validates and normalizes the optional image path
   */
  private normalizeImage(image: string | undefined): string | undefined {
    if (image === undefined) {
      return undefined;
    }

    if (typeof image !== 'string') {
      throw new Error('Image path must be a string');
    }

    const trimmedImage = image.trim();

    if (trimmedImage.length === 0) {
      throw new Error('Image path cannot be empty');
    }

    if (trimmedImage.length > 2048) {
      throw new Error('Image path cannot exceed 2048 characters');
    }

    return trimmedImage;
  }
}
