/**
 * Ingredient Service
 * 
 * Contains the business logic for ingredient operations.
 * Following DDD principles, this is the application service layer.
 */

import { IngredientRepository } from './ingredient.repository';

import { AbstractService } from '../shared/abstract.service';

import { Ingredient, CreateIngredientDto, UpdateIngredientDto } from './ingredient.model';

export class IngredientService extends AbstractService {
  private readonly repository = new IngredientRepository();

  /**
   * Creates a new ingredient with validation
   */
  async createIngredient(data: CreateIngredientDto) {
    // Validate input
    this.validateIngredientData(data);
    
    const image = this.normalizeImage(data.image);
    const normalizedTitle = this.normalizeI18nField(data.title);


    // Create the ingredient
    return this.repository.create({
      title: normalizedTitle,
      category: data.category,
      image,
    });
  }

  /**
   * Retrieves an ingredient by ID
   */
  async getIngredient(id: string) {
    if (!id || id.trim() === '') {
      throw new Error('Ingredient ID is required');
    }

    const ingredient = await this.repository.findById(id.trim());

    if (!ingredient) {
      throw new Error('Ingredient not found');
    }

    return ingredient;
  }

  async getIngredientByIds(ids: string[]) {
    if (!Array.isArray(ids) || ids.length === 0) {
      return [];
    }

    const trimmedIds = ids
      .map(id => {
        const trimmed = id.trim();
        // Extract ID from path format "ingredients/<id>" or use as-is
        return trimmed.replace('ingredients/', '');
      })
      .filter(id => id !== '');

    if (trimmedIds.length === 0) {
      return [];
    }
    
    return this.repository.findByIds(trimmedIds);
  }

  /**
   * Retrieves all ingredients
   * @todo Implement pagination and filtering
   */
  async getAllIngredients(): Promise<Ingredient[]> {
    return [];
  }

  /**
   * Updates an existing ingredient
   */
  async updateIngredient(data: UpdateIngredientDto) {
    if (!data.id || data.id.trim() === '') {
      throw new Error('Ingredient ID is required');
    }

    // Validate update data if provided
    if (data.title !== undefined) {
      this.validateI18nField(data.title);
    }
    if (data.category !== undefined) {
      this.validateCategory(data.category);
    }

    const updatePayload: UpdateIngredientDto = {
      ...data
    };
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

    const updatedIngredient = await this.repository.update(updatePayload);
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
   * Validates ingredient data
   */
  private validateIngredientData(data: CreateIngredientDto): void {
    this.validateI18nField(data.title);
    this.validateCategory(data.category);
    this.normalizeImage(data.image);
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
}
