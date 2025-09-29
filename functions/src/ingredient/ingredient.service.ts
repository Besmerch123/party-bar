/**
 * Ingredient Service
 * 
 * Contains the business logic for ingredient operations.
 * Following DDD principles, this is the application service layer.
 */

import { IngredientRepository } from './ingredient.repository';
import { Ingredient, CreateIngredientDto, UpdateIngredientDto, INGREDIENT_CATEGORIES } from './ingredient.model';

export class IngredientService {
  private readonly repository = new IngredientRepository();

  /**
   * Creates a new ingredient with validation
   */
  async createIngredient(data: CreateIngredientDto): Promise<Ingredient> {
    // Validate input
    this.validateIngredientData(data);
    
    const image = this.normalizeImage(data.image);

    // Check for duplicate titles
    const exists = await this.repository.existsByTitle(data.title.trim());
    if (exists) {
      throw new Error('An ingredient with this title already exists');
    }

    // Create the ingredient
    return await this.repository.create({
      title: data.title.trim(),
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

    // Validate input if provided
    if (data.title !== undefined) {
      this.validateTitle(data.title);
    }
    if (data.category !== undefined) {
      this.validateCategory(data.category);
    }
    // Check for duplicate titles (excluding current ingredient)
    if (data.title) {
      const trimmedTitle = data.title.trim();
      const exists = await this.repository.existsByTitle(trimmedTitle, id);
      if (exists) {
        throw new Error('An ingredient with this title already exists');
      }
    }

    // Prepare update data
    const updateData: UpdateIngredientDto = {};
    if (data.title !== undefined) {
      updateData.title = data.title.trim();
    }
    if (data.category !== undefined) {
      updateData.category = data.category;
    }
    if (data.image !== undefined) {
      const image = this.normalizeImage(data.image);
      if (image !== undefined) {
        updateData.image = image;
      }
    }

    const updated = await this.repository.update(id.trim(), updateData);
    if (!updated) {
      throw new Error('Ingredient not found');
    }

    return updated;
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
    this.validateTitle(data.title);
    this.validateCategory(data.category);
    this.normalizeImage(data.image);
  }

  /**
   * Validates ingredient title
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
