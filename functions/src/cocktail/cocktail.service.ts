/**
 * Cocktail Service
 *
 * Contains the business logic for cocktail operations.
 * Following DDD principles, this is the application service layer.
 */

import { AbstractService } from '../shared/abstract.service';

import { CocktailRepository } from './cocktail.repository';
import {
  Cocktail,
  CreateCocktailDto,
  UpdateCocktailDto,
  COCKTAIL_CATEGORIES,
  CocktailCategory,
} from './cocktail.model';

export class CocktailService extends AbstractService {
  private readonly repository = new CocktailRepository();
  private readonly allowedCategories: Set<CocktailCategory> = new Set(
    Object.values(COCKTAIL_CATEGORIES)
  );

  /**
   * Creates a new cocktail with validation
   */
  async createCocktail(data: CreateCocktailDto) {
    this.validateCocktailData(data);

    const normalized = this.normalizeCreateData(data);

    return this.repository.create(normalized);
  }

  /**
   * Retrieves a cocktail by ID
   */
  async getCocktail(id: string) {
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
   * @todo Implement pagination and filtering
   */
  async getAllCocktails(): Promise<Cocktail[]> {
    return [];
  }

  /**
   * Updates an existing cocktail
   */
  async updateCocktail(data: UpdateCocktailDto) {
    const updatePayload: UpdateCocktailDto = {
      ...data
    };

    if (data.description !== undefined) {
      this.validateI18nField(data.description);
      updatePayload.description = this.normalizeI18nField(data.description);
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

    if (data.abv !== undefined) {
      this.validateAbv(data.abv);
      updatePayload.abv = data.abv;
    }

    if (data.preparationSteps !== undefined) {
      this.validateI18nArrayField(data.preparationSteps, 'preparationSteps');
      updatePayload.preparationSteps = this.normalizeI18nArrayField(data.preparationSteps);
    }

    if (data.image !== undefined) {
      this.normalizeImage(data.image);
      updatePayload.image = data.image;
    }

    const updated = await this.repository.update(updatePayload);
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

  private validateCocktailData(data: CreateCocktailDto): void {
    this.validateI18nField(data.title);
    this.validateI18nField(data.description);
    this.validateReferenceArray(data.ingredients, 'ingredients');
    this.validateReferenceArray(data.equipments, 'equipments');
    this.validateCategories(data.categories);
    this.validateAbv(data.abv);
    this.validateI18nArrayField(data.preparationSteps, 'preparationSteps');
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

  /**
   * Validates ABV (Alcohol by Volume) percentage
   */
  private validateAbv(abv: unknown): void {
    if (abv === undefined || abv === null) {
      return; // ABV is optional
    }

    if (typeof abv !== 'number') {
      throw new Error('ABV must be a number');
    }

    if (isNaN(abv)) {
      throw new Error('ABV must be a valid number');
    }

    if (abv < 0 || abv > 100) {
      throw new Error('ABV must be between 0 and 100');
    }
  }

  /**
   * Validates I18n array field (translatable array field)
   */
  private validateI18nArrayField(field: unknown, fieldName: string): void {
    if (!field || typeof field !== 'object') {
      throw new Error(`${fieldName} is required and must be an object with locale keys`);
    }

    const locales = Object.keys(field);
    if (locales.length === 0) {
      throw new Error(`${fieldName} must have at least one locale`);
    }

    for (const locale of locales) {
      const value = (field as Record<string, unknown>)[locale];
      if (value !== undefined) {
        this.validateArrayFieldValue(value, locale, fieldName);
      }
    }
  }

  /**
   * Validates a single array field value for a specific locale
   */
  private validateArrayFieldValue(value: unknown, locale: string, fieldName: string): void {
    if (!Array.isArray(value)) {
      throw new Error(`${fieldName} for locale '${locale}' must be an array of strings`);
    }

    if (value.length === 0) {
      throw new Error(`${fieldName} for locale '${locale}' cannot be empty`);
    }

    value.forEach((item, index) => {
      if (typeof item !== 'string') {
        throw new Error(`${fieldName}[${index}] for locale '${locale}' must be a string`);
      }

      const trimmed = item.trim();
      if (trimmed.length === 0) {
        throw new Error(`${fieldName}[${index}] for locale '${locale}' cannot be empty`);
      }

      if (trimmed.length > 1000) {
        throw new Error(`${fieldName}[${index}] for locale '${locale}' cannot exceed 1000 characters`);
      }
    });
  }

  private normalizeCreateData(data: CreateCocktailDto): CreateCocktailDto {
    const normalized: CreateCocktailDto = {
      title: this.normalizeI18nField(data.title),
      description: this.normalizeI18nField(data.description),
      ingredients: this.normalizeReferenceArray(data.ingredients),
      equipments: this.normalizeReferenceArray(data.equipments),
      categories: this.normalizeCategories(data.categories),
      preparationSteps: this.normalizeI18nArrayField(data.preparationSteps),
    };

    if (data.abv !== undefined) {
      normalized.abv = data.abv;
    }

    if (data.image !== undefined) {
      normalized.image = data.image && typeof data.image === 'string' && data.image.trim().length > 0 
        ? data.image.trim() 
        : null;
    }

    return normalized;
  }

  /**
   * Normalizes I18n array field by trimming all values in each locale's array
   */
  private normalizeI18nArrayField(field: Record<string, string[]>): Record<string, string[]> {
    const normalized: Record<string, string[]> = {};
    for (const locale of Object.keys(field)) {
      const value = field[locale];
      if (value !== undefined && Array.isArray(value)) {
        normalized[locale] = value.map((item) => item.trim());
      }
    }
    return normalized;
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
