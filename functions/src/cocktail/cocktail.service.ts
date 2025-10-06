/**
 * Cocktail Service
 *
 * Contains the business logic for cocktail operations.
 * Following DDD principles, this is the application service layer.
 */

import { I18nField } from '../shared/types';
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

    // Check for duplicate titles in all locales
    for (const locale of Object.keys(normalized.title)) {
      const titleValue = normalized.title[locale as keyof typeof normalized.title];
      if (titleValue) {
        const exists = await this.repository.existsByTitle(titleValue, locale);
        if (exists) {
          throw new Error(`A cocktail with this title already exists in locale: ${locale}`);
        }
      }
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
      this.validateI18nField(data.title, 'title');
      const normalizedTitle = this.normalizeI18nField(data.title);
      
      // Check for duplicate titles in all locales
      const existing = await this.repository.findById(id.trim());
      for (const locale of Object.keys(normalizedTitle)) {
        const titleValue = normalizedTitle[locale as keyof typeof normalizedTitle];
        if (titleValue) {
          const exists = await this.repository.existsByTitle(titleValue, locale);
          if (exists) {
            // Check if it's the same cocktail
            if (!existing || existing.title[locale as keyof typeof existing.title]?.toLowerCase() !== titleValue.toLowerCase()) {
              throw new Error(`A cocktail with this title already exists in locale: ${locale}`);
            }
          }
        }
      }
      updatePayload.title = normalizedTitle;
    }

    if (data.description !== undefined) {
      this.validateI18nField(data.description, 'description');
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
    this.validateI18nField(data.title, 'title');
    this.validateI18nField(data.description, 'description');
    this.validateReferenceArray(data.ingredients, 'ingredients');
    this.validateReferenceArray(data.equipments, 'equipments');
    this.validateCategories(data.categories);
    this.validateAbv(data.abv);
    this.validateI18nArrayField(data.preparationSteps, 'preparationSteps');
  }

  /**
   * Validates I18n field (translatable field)
   */
  private validateI18nField(field: I18nField, fieldName: 'title' | 'description'): void {
    if (!field || typeof field !== 'object') {
      throw new Error(`${fieldName} is required and must be an object with locale keys`);
    }

    const locales = Object.keys(field);
    if (locales.length === 0) {
      throw new Error(`${fieldName} must have at least one locale`);
    }

    for (const locale of locales) {
      const value = field[locale as keyof typeof field];
      if (value !== undefined) {
        this.validateFieldValue(value, locale, fieldName);
      }
    }
  }

  /**
   * Validates a single field value for a specific locale
   */
  private validateFieldValue(value: string, locale: string, fieldName: 'title' | 'description'): void {
    if (typeof value !== 'string') {
      throw new Error(`${fieldName} for locale '${locale}' must be a string`);
    }

    const trimmedValue = value.trim();
    if (trimmedValue.length === 0) {
      throw new Error(`${fieldName} for locale '${locale}' cannot be empty`);
    }

    if (fieldName === 'title') {
      if (trimmedValue.length < 2) {
        throw new Error(`Title for locale '${locale}' must be at least 2 characters long`);
      }
      if (trimmedValue.length > 150) {
        throw new Error(`Title for locale '${locale}' cannot exceed 150 characters`);
      }
    } else if (fieldName === 'description') {
      if (trimmedValue.length < 10) {
        throw new Error(`Description for locale '${locale}' must be at least 10 characters long`);
      }
      if (trimmedValue.length > 5000) {
        throw new Error(`Description for locale '${locale}' cannot exceed 5000 characters`);
      }
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

    return normalized;
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
