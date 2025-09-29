/**
 * Cocktail Service
 *
 * Contains the business logic for cocktail operations.
 * Following DDD principles, this is the application service layer.
 */

import { CocktailRepository } from './cocktail.repository';
import {
  Cocktail,
  CreateCocktailDto,
  UpdateCocktailDto,
  COCKTAIL_CATEGORIES,
  CocktailCategory,
} from './cocktail.model';

export class CocktailService {
  private readonly repository = new CocktailRepository();
  private readonly allowedCategories: Set<CocktailCategory> = new Set(
    Object.values(COCKTAIL_CATEGORIES)
  );

  /**
   * Creates a new cocktail with validation
   */
  async createCocktail(data: CreateCocktailDto): Promise<Cocktail> {
    this.validateCocktailData(data);

    const normalized = this.normalizeCreateData(data);

    const exists = await this.repository.existsByTitle(normalized.title);
    if (exists) {
      throw new Error('A cocktail with this title already exists');
    }

    return await this.repository.create(normalized);
  }

  /**
   * Retrieves a cocktail by ID
   */
  async getCocktail(id: string): Promise<Cocktail> {
    if (!id || id.trim() === '') {
      throw new Error('Cocktail ID is required');
    }

    const cocktail = await this.repository.findById(id.trim());
    if (!cocktail) {
      throw new Error('Cocktail not found');
    }

    return cocktail;
  }

  /**
   * Retrieves all cocktails
   */
  async getAllCocktails(): Promise<Cocktail[]> {
    return await this.repository.findAll();
  }

  /**
   * Retrieves cocktails by category
   */
  async getCocktailsByCategory(category: string): Promise<Cocktail[]> {
    if (!category || category.trim() === '') {
      throw new Error('Category is required');
    }

    return await this.repository.findByCategory(category.trim().toLowerCase());
  }

  /**
   * Updates an existing cocktail
   */
  async updateCocktail(id: string, data: UpdateCocktailDto): Promise<Cocktail> {
    if (!id || id.trim() === '') {
      throw new Error('Cocktail ID is required');
    }

    const updatePayload: UpdateCocktailDto = {};

    if (data.title !== undefined) {
      this.validateTitle(data.title);
      const trimmedTitle = data.title.trim();
      const exists = await this.repository.existsByTitle(trimmedTitle, id.trim());
      if (exists) {
        throw new Error('A cocktail with this title already exists');
      }
      updatePayload.title = trimmedTitle;
    }

    if (data.description !== undefined) {
      this.validateDescription(data.description);
      updatePayload.description = data.description.trim();
    }

    if (data.ingredients !== undefined) {
      this.validateReferenceArray(data.ingredients, 'ingredients');
      updatePayload.ingredients = this.normalizeReferenceArray(data.ingredients);
    }

    if (data.equipments !== undefined) {
      this.validateReferenceArray(data.equipments, 'equipments');
      updatePayload.equipments = this.normalizeReferenceArray(data.equipments);
    }

    if (data.categories !== undefined) {
      this.validateCategories(data.categories);
      updatePayload.categories = this.normalizeCategories(data.categories);
    }

    const updated = await this.repository.update(id.trim(), updatePayload);
    if (!updated) {
      throw new Error('Cocktail not found');
    }

    return updated;
  }

  /**
   * Deletes a cocktail
   */
  async deleteCocktail(id: string): Promise<void> {
    if (!id || id.trim() === '') {
      throw new Error('Cocktail ID is required');
    }

    const deleted = await this.repository.delete(id.trim());
    if (!deleted) {
      throw new Error('Cocktail not found');
    }
  }

  /**
   * Gets all available cocktail categories
   */
  getAvailableCategories(): string[] {
    return Array.from(this.allowedCategories.values());
  }

  private validateCocktailData(data: CreateCocktailDto): void {
    this.validateTitle(data.title);
    this.validateDescription(data.description);
    this.validateReferenceArray(data.ingredients, 'ingredients');
    this.validateReferenceArray(data.equipments, 'equipments');
    this.validateCategories(data.categories);
  }

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

    if (trimmedTitle.length > 150) {
      throw new Error('Title cannot exceed 150 characters');
    }
  }

  private validateDescription(description: string): void {
    if (!description || typeof description !== 'string') {
      throw new Error('Description is required and must be a string');
    }

    const trimmedDescription = description.trim();
    if (trimmedDescription.length === 0) {
      throw new Error('Description cannot be empty');
    }

    if (trimmedDescription.length < 10) {
      throw new Error('Description must be at least 10 characters long');
    }

    if (trimmedDescription.length > 5000) {
      throw new Error('Description cannot exceed 5000 characters');
    }
  }

  private validateReferenceArray(values: unknown, field: 'ingredients' | 'equipments'): void {
    if (!Array.isArray(values)) {
      throw new Error(`${field} must be an array of document paths`);
    }

    if (values.length === 0) {
      throw new Error(`${field} cannot be empty`);
    }

    values.forEach((value, index) => {
      if (typeof value !== 'string') {
        throw new Error(`${field}[${index}] must be a string path`);
      }

      const trimmed = value.trim();
      if (trimmed.length === 0) {
        throw new Error(`${field}[${index}] cannot be empty`);
      }

      if (trimmed.length > 2048) {
        throw new Error(`${field}[${index}] cannot exceed 2048 characters`);
      }
    });
  }

  private validateCategories(categories: unknown): void {
    if (!Array.isArray(categories)) {
      throw new Error('Categories must be an array');
    }

    if (categories.length === 0) {
      throw new Error('Categories cannot be empty');
    }

    categories.forEach((category, index) => {
      if (typeof category !== 'string') {
        throw new Error(`categories[${index}] must be a string`);
      }

      const normalized = category.trim().toLowerCase() as CocktailCategory;

      if (normalized.length === 0) {
        throw new Error(`categories[${index}] cannot be empty`);
      }

      if (!this.allowedCategories.has(normalized)) {
        throw new Error(`Invalid cocktail category: ${category}`);
      }
    });
  }

  private normalizeCreateData(data: CreateCocktailDto): CreateCocktailDto {
    return {
      title: data.title.trim(),
      description: data.description.trim(),
      ingredients: this.normalizeReferenceArray(data.ingredients),
      equipments: this.normalizeReferenceArray(data.equipments),
      categories: this.normalizeCategories(data.categories),
    };
  }

  private normalizeReferenceArray(values: string[]): string[] {
    const unique = new Set(values.map((value) => value.trim()));
    return Array.from(unique.values());
  }

  private normalizeCategories(categories: CocktailCategory[]): CocktailCategory[] {
    const unique = new Set(
      categories.map((category) => category.trim().toLowerCase() as CocktailCategory)
    );
    return Array.from(unique.values());
  }
}
