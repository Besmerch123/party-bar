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
  COCKTAIL_METHODS,
  CocktailMethod,
  BASE_SPIRITS,
  BaseSpirit,
  FLAVOR_PROFILES,
  FlavorProfile,
  MEASURE_UNITS,
  IngredientMeasure,
  PourStep,
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

    if (data.prepTimeMinutes !== undefined) {
      updatePayload.prepTimeMinutes = this.validatePrepTime(data.prepTimeMinutes);
    }

    if (data.method !== undefined) {
      updatePayload.method = this.validateMethod(data.method);
    }

    if (data.baseSpirit !== undefined) {
      updatePayload.baseSpirit = this.validateBaseSpirit(data.baseSpirit);
    }

    if (data.flavor !== undefined) {
      updatePayload.flavor = this.validateFlavor(data.flavor);
    }

    if (data.popularity !== undefined) {
      updatePayload.popularity = this.validateScore(data.popularity, 'popularity');
    }

    if (data.seasonalScore !== undefined) {
      updatePayload.seasonalScore = this.validateScore(data.seasonalScore, 'seasonalScore');
    }

    if (data.measures !== undefined) {
      updatePayload.measures = this.validateMeasures(data.measures, updatePayload.ingredients);
    }

    if (data.pourSteps !== undefined) {
      updatePayload.pourSteps = this.validatePourSteps(data.pourSteps);
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
    this.validatePrepTime(data.prepTimeMinutes);
    this.validateMethod(data.method);
    this.validateBaseSpirit(data.baseSpirit);
    this.validateFlavor(data.flavor);
    this.validateScore(data.popularity, 'popularity');
    this.validateScore(data.seasonalScore, 'seasonalScore');
    this.validateMeasures(data.measures, data.ingredients);
    this.validatePourSteps(data.pourSteps);
  }

  /**
   * How long the drink takes. Drives the "under 3 minutes" effort filter, so a
   * zero or a fraction would quietly make a drink win every such search.
   */
  private validatePrepTime(value: number | null | undefined): number | null {
    if (value === null || value === undefined) {
      return null;
    }

    if (typeof value !== 'number' || !Number.isInteger(value) || value < 1 || value > 240) {
      throw new Error('prepTimeMinutes must be a whole number of minutes between 1 and 240, or null');
    }

    return value;
  }

  private validateMethod(value: CocktailMethod | null | undefined): CocktailMethod | null {
    return this.validateEnum(value, COCKTAIL_METHODS, 'method');
  }

  private validateBaseSpirit(value: BaseSpirit | null | undefined): BaseSpirit | null {
    return this.validateEnum(value, BASE_SPIRITS, 'baseSpirit');
  }

  private validateFlavor(value: FlavorProfile | null | undefined): FlavorProfile | null {
    return this.validateEnum(value, FLAVOR_PROFILES, 'flavor');
  }

  /**
   * These three are filter and sort keys on the device. An unrecognised value
   * does not fail loudly there -- it decodes to null and drops the drink out
   * of every filter that reads it -- so it has to fail here instead.
   */
  private validateEnum<T extends string>(
    value: T | null | undefined,
    allowedValues: Record<string, T>,
    field: string
  ): T | null {
    if (value === null || value === undefined) {
      return null;
    }

    const allowed = Object.values(allowedValues) as string[];
    if (typeof value !== 'string' || !allowed.includes(value)) {
      throw new Error(`Invalid ${field}: ${value}. Expected one of: ${allowed.join(', ')}`);
    }

    return value;
  }

  /**
   * Popularity and seasonal fit are editorial 0-100 scores, not counts.
   */
  private validateScore(value: number | null | undefined, field: string): number | null {
    if (value === null || value === undefined) {
      return null;
    }

    if (typeof value !== 'number' || !Number.isInteger(value) || value < 0 || value > 100) {
      throw new Error(`${field} must be a whole number between 0 and 100, or null`);
    }

    return value;
  }

  /**
   * Quantities, keyed by ingredient id.
   *
   * The key has to be an id the recipe actually references: a measure for an
   * ingredient the recipe does not list renders nowhere and, worse, silently
   * survives that ingredient being removed. When the caller is also changing
   * `ingredients` we check against the new list, which is why this takes it.
   */
  private validateMeasures(
    measures: Record<string, IngredientMeasure> | undefined,
    ingredients?: string[]
  ): Record<string, IngredientMeasure> | undefined {
    if (measures === undefined) {
      return undefined;
    }

    if (measures === null || typeof measures !== 'object' || Array.isArray(measures)) {
      throw new Error('measures must be an object keyed by ingredient id');
    }

    const allowedUnits = Object.values(MEASURE_UNITS) as string[];
    const knownIds = ingredients
      ? new Set(ingredients.map((reference) => this.normalizeId(reference)))
      : null;

    const normalized: Record<string, IngredientMeasure> = {};

    for (const [rawKey, measure] of Object.entries(measures)) {
      const ingredientId = this.normalizeId(rawKey);

      if (knownIds && !knownIds.has(ingredientId)) {
        throw new Error(`measures references an ingredient the recipe does not list: ${ingredientId}`);
      }

      if (!measure || typeof measure !== 'object') {
        throw new Error(`measures.${ingredientId} must be an object`);
      }

      if (typeof measure.amount !== 'number' || !Number.isFinite(measure.amount) || measure.amount < 0) {
        throw new Error(`measures.${ingredientId}.amount must be a non-negative number`);
      }

      if (typeof measure.unit !== 'string' || !allowedUnits.includes(measure.unit)) {
        throw new Error(
          `measures.${ingredientId}.unit is invalid: ${measure.unit}. Expected one of: ${allowedUnits.join(', ')}`
        );
      }

      if (measure.optional !== undefined && typeof measure.optional !== 'boolean') {
        throw new Error(`measures.${ingredientId}.optional must be a boolean`);
      }

      normalized[ingredientId] = {
        amount: measure.amount,
        unit: measure.unit,
        optional: measure.optional ?? false,
      };
    }

    return normalized;
  }

  /**
   * The guided pour. Absent for most of the catalogue -- "Make it now" falls
   * back to `preparationSteps` -- but a half-built step with an empty title
   * renders a blank screen mid-pour, so partial is worse than absent.
   */
  private validatePourSteps(pourSteps: PourStep[] | undefined): PourStep[] | undefined {
    if (pourSteps === undefined) {
      return undefined;
    }

    if (!Array.isArray(pourSteps)) {
      throw new Error('pourSteps must be an array');
    }

    return pourSteps.map((step, index) => {
      if (!step || typeof step !== 'object') {
        throw new Error(`pourSteps[${index}] must be an object`);
      }

      this.validateI18nField(step.title);

      if (step.body !== undefined && step.body !== null) {
        this.validateI18nField(step.body);
      }

      if (
        step.durationSeconds !== undefined
        && step.durationSeconds !== null
        && (typeof step.durationSeconds !== 'number'
          || !Number.isInteger(step.durationSeconds)
          || step.durationSeconds < 1
          || step.durationSeconds > 3600)
      ) {
        throw new Error(
          `pourSteps[${index}].durationSeconds must be a whole number of seconds between 1 and 3600, or null`
        );
      }

      return {
        title: this.normalizeI18nField(step.title),
        ...(step.body ? { body: this.normalizeI18nField(step.body) } : {}),
        durationSeconds: step.durationSeconds ?? null,
      };
    });
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
      pourSteps: this.validatePourSteps(data.pourSteps),
      abv: data.abv ?? null,
      prepTimeMinutes: data.prepTimeMinutes ?? null,
      method: data.method ?? null,
      baseSpirit: data.baseSpirit ?? null,
      flavor: data.flavor ?? null,
      popularity: data.popularity ?? null,
      seasonalScore: data.seasonalScore ?? null,
      measures: this.validateMeasures(data.measures, data.ingredients),
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
      abv: cocktailData?.abv ?? null,
      prepTimeMinutes: cocktailData?.prepTimeMinutes ?? null,
      method: cocktailData?.method ?? null,
      baseSpirit: cocktailData?.baseSpirit ?? null,
      flavor: cocktailData?.flavor ?? null,
      popularity: cocktailData?.popularity ?? null,
      seasonalScore: cocktailData?.seasonalScore ?? null,
      measures: cocktailData?.measures,
      image: cocktailData?.image,
      preparationSteps: cocktailData?.preparationSteps || {},
      pourSteps: cocktailData?.pourSteps,
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
        // The device's shelf is stored as slugs, so the shelf pre-filter has
        // to be able to match on one.
        slug: ingredient?.slug ?? null,
      };
    });

    const equipments: CocktailSearchDocument['equipments'] = cocktail.equipments.map((equip) => {
      return {
        id: equip.id,
        title: equip?.title || {},
        image: equip?.image,
        slug: equip?.slug ?? null,
      };
    });
  

    return {
      id: cocktail.id,
      title: cocktail.title,
      categories: cocktail.categories,
      description: cocktail.description,
      abv: cocktail.abv,
      prepTimeMinutes: cocktail.prepTimeMinutes,
      method: cocktail.method,
      baseSpirit: cocktail.baseSpirit,
      flavor: cocktail.flavor,
      popularity: cocktail.popularity,
      seasonalScore: cocktail.seasonalScore,
      measures: cocktail.measures,
      image: cocktail.image,
      ingredients,
      equipments,
      ingredientCount: ingredients.length,
      // Carried so a cocktail opened from search can show its recipe without a
      // second read -- and so "Make it now" has something to fall back to when
      // the drink has no pour steps.
      preparationSteps: cocktail.preparationSteps,
      pourSteps: cocktail.pourSteps,
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
