/**
 * Cocktail Service
 *
 * Contains the business logic for cocktail operations.
 * Following DDD principles, this is the application service layer.
 */
import type { DocumentSnapshot } from 'firebase-admin/firestore';

import { type Equipment, EquipmentService } from '../equipment';
import { type Ingredient, IngredientService } from '../ingredient';
import { AbstractService } from '../shared/abstract.service';

import { getCocktailRepository } from './cocktail.repository';
import {
  CreateCocktailDto,
  UpdateCocktailDto,
  COCKTAIL_CATEGORIES,
  CocktailCategory,
  CocktailsSearchSchema,
  CocktailDocument,
  CocktailSearchDocument,
  Cocktail,
} from './cocktail.model';

class CocktailService extends AbstractService {
  readonly repository: ReturnType<typeof getCocktailRepository>;
  private readonly allowedCategories: Set<CocktailCategory> = new Set(
    Object.values(COCKTAIL_CATEGORIES)
  );

  readonly equipmentService:  EquipmentService;
  readonly ingredientService: IngredientService;

  constructor() {
    super();

    this.repository = getCocktailRepository();

    this.equipmentService = new EquipmentService();
    this.ingredientService = new IngredientService();
  }

  /**
   * Creates a new cocktail with validation
   */
  async createCocktail(data: CreateCocktailDto): Promise<Cocktail> {
    this.validateCocktailData(data);

    const normalized = this.normalizeCreateData(data);

    const cocktailDoc = await this.repository.create(normalized);

    const { equipments, ingredients } = await this.loadCocktailRelations(cocktailDoc);

    return this.toCocktail(cocktailDoc, equipments, ingredients);
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

    const { equipments, ingredients } = await this.loadCocktailRelations(cocktail);

    return this.toCocktail(cocktail, equipments, ingredients);
  }

  /**
   * Search all cocktails
   */
  async searchCocktails(searchSchema: CocktailsSearchSchema) {
    return this.repository.searchCocktails(searchSchema);
  }

  /**
   * Updates an existing cocktail
   */
  async updateCocktail(data: UpdateCocktailDto): Promise<Cocktail> {
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

    const { equipments, ingredients } = await this.loadCocktailRelations(updated);

    return this.toCocktail(updated, equipments, ingredients);
  }

  /**
   * Deletes a cocktail
   */
  async deleteCocktail(id: string): Promise<void> {
    if (!id || id.trim() === '') {
      throw new Error('Cocktail ID is required');
    }

    await this.repository.delete(id.trim());
  }

  async insertCocktailToElasticIndex(cocktailSnap: DocumentSnapshot<CocktailDocument>) {
    const { equipments, ingredients } = await this.loadCocktailRelations(cocktailSnap);

    const cocktailSearchDoc = this.toCocktailSearchDocument(cocktailSnap, equipments, ingredients);

    await this.repository.elastic.insertDocument<CocktailSearchDocument>('cocktails', cocktailSearchDoc);
  }

  private async loadCocktailRelations(cocktailSnap: DocumentSnapshot<CocktailDocument>) {
    const data = cocktailSnap.data();
        
    const [equipments, ingredients] =  await Promise.all([
      this.equipmentService.getEquipmentByIds(data?.equipments || []),
      this.ingredientService.getIngredientsByIds(data?.ingredients || []),
    ]);

    return {
      equipments,
      ingredients
    };
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
      abv: data.abv || null,
      image: this.normalizeImage(data.image),
    };

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

  private toCocktail(
    cocktailDoc: DocumentSnapshot<CocktailDocument>,
    equipments: Equipment[] = [],
    ingredients: Ingredient[] = []
  ): Cocktail {
    const cocktailData = cocktailDoc.data();

    return {
      id: cocktailDoc.id,
      title: cocktailData?.title || {}, 
      categories: cocktailData?.categories || [],
      description: cocktailData?.description || {},
      abv: cocktailData?.abv || 0,
      image: cocktailData?.image,
      preparationSteps: cocktailData?.preparationSteps || {},
      ingredients,
      equipments,
      updatedAt: cocktailData?.updatedAt.toDate().toISOString() || new Date().toISOString(),
      createdAt: cocktailData?.createdAt.toDate().toISOString() || new Date().toISOString(),
    };

  }

  private toCocktailSearchDocument(
    cocktailDoc: DocumentSnapshot<CocktailDocument>,
    equipmentSnapshots: Equipment[],
    ingredientSnapshots: Ingredient[]
  ): CocktailSearchDocument {
    const cocktail = this.toCocktail(cocktailDoc, equipmentSnapshots, ingredientSnapshots);
  
    const ingredients: CocktailSearchDocument['ingredients'] = cocktail.ingredients.map((ingredient) => {
      return {
        id: ingredient.id,
        title: ingredient?.title || {},
        category: ingredient.category,
        image: ingredient?.image,
      };
    });

    const equipments: CocktailSearchDocument['equipments'] = cocktail.equipments.map((equip) => {
      return {
        id: equip.id,
        title: equip?.title || {},
        image: equip?.image,
      };
    });
  

    return {
      id: cocktail.id,
      title: cocktail.title,
      categories: cocktail.categories,
      description: cocktail.description,
      abv: cocktail.abv,
      image: cocktail.image,
      ingredients,
      equipments,
      updatedAt: cocktail.updatedAt,
      createdAt: cocktail.createdAt,
    };
  }
}

let cocktailService: CocktailService;

export function getCocktailService(): CocktailService {
  if (!cocktailService) {
    cocktailService = new CocktailService();
  }

  return cocktailService;
}
