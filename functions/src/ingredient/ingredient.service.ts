/**
 * Ingredient Service
 * 
 * Contains the business logic for ingredient operations.
 * Following DDD principles, this is the application service layer.
 */

import { IngredientRepository } from './ingredient.repository';
import { Ingredient, CreateIngredientDto, UpdateIngredientDto, INGREDIENT_CATEGORIES } from './ingredient.model';
import { I18nField } from '../shared/types';

export class IngredientService {
  private readonly repository = new IngredientRepository();

  /**
   * Creates a new ingredient with validation
   */
  async createIngredient(data: CreateIngredientDto): Promise<Ingredient> {
    // Validate input
    this.validateIngredientData(data);
    
    const image = this.normalizeImage(data.image);
    const normalizedTitle = this.normalizeI18nField(data.title);

    // Check for duplicate titles in all locales
    for (const locale of Object.keys(normalizedTitle)) {
      const titleValue = normalizedTitle[locale as keyof typeof normalizedTitle];
      if (titleValue) {
        const exists = await this.repository.existsByTitle(titleValue, locale);
        if (exists) {
          throw new Error(`An ingredient with this title already exists in locale: ${locale}`);
        }
      }
    }

    // Create the ingredient
    return await this.repository.create({
      title: normalizedTitle,
      category: data.category,
      image,
    });
  }

  /**
   * Retrieves an ingredient by ID
   */
  async getIngredient(id: string): Promise<Ingredient> {
    if (!id || id.trim() === '') {
      throw new Error('Ingredient ID is required');
    }

    const ingredient = await this.repository.findById(id.trim());
    if (!ingredient) {
      throw new Error('Ingredient not found');
    }

    return ingredient;
  }

  /**
   * Retrieves all ingredients
   */
  async getAllIngredients(): Promise<Ingredient[]> {
    return await this.repository.findAll();
  }

  /**
   * Retrieves ingredients by category
   */
  async getIngredientsByCategory(category: string): Promise<Ingredient[]> {
    if (!category || category.trim() === '') {
      throw new Error('Category is required');
    }

    return await this.repository.findByCategory(category.toLowerCase());
  }

  /**
   * Updates an existing ingredient
   */
  async updateIngredient(id: string, data: UpdateIngredientDto): Promise<Ingredient> {
    if (!id || id.trim() === '') {
      throw new Error('Ingredient ID is required');
    }

    // Validate update data if provided
    if (data.title !== undefined) {
      this.validateI18nField(data.title);
    }
    if (data.category !== undefined) {
      this.validateCategory(data.category);
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
            // Check if it's the same ingredient
            if (!existing || existing.title[locale as keyof typeof existing.title]?.toLowerCase() !== titleValue.toLowerCase()) {
              throw new Error(`An ingredient with this title already exists in locale: ${locale}`);
            }
          }
        }
      }
    }

    const updatePayload: UpdateIngredientDto = {};
    if (data.title !== undefined) {
      updatePayload.title = this.normalizeI18nField(data.title);
    }
    if (data.category !== undefined) {
      updatePayload.category = data.category;
    }
    if (data.image !== undefined) {
      const image = this.normalizeImage(data.image);
      if (image !== undefined) {
        updatePayload.image = image;
      }
    }

    const updatedIngredient = await this.repository.update(id.trim(), updatePayload);
    if (!updatedIngredient) {
      throw new Error('Ingredient not found');
    }

    return updatedIngredient;
  }

  /**
   * Deletes an ingredient
   */
  async deleteIngredient(id: string): Promise<void> {
    if (!id || id.trim() === '') {
      throw new Error('Ingredient ID is required');
    }

    const deleted = await this.repository.delete(id.trim());
    if (!deleted) {
      throw new Error('Ingredient not found');
    }
  }

  /**
   * Gets all available ingredient categories
   */
  getAvailableCategories(): string[] {
    return Object.values(INGREDIENT_CATEGORIES);
  }

  /**
   * Validates ingredient data
   */
  private validateIngredientData(data: CreateIngredientDto): void {
    this.validateI18nField(data.title);
    this.validateCategory(data.category);
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
   * Validates ingredient category
   */
  private validateCategory(category: string): void {
    if (!category || typeof category !== 'string') {
      throw new Error('Category is required and must be a string');
    }

    const trimmedCategory = category.trim().toLowerCase();
    if (trimmedCategory.length === 0) {
      throw new Error('Category cannot be empty');
    }

    // For now we allow any string, but could validate against INGREDIENT_CATEGORIES if needed
    if (trimmedCategory.length > 50) {
      throw new Error('Category cannot exceed 50 characters');
    }
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
