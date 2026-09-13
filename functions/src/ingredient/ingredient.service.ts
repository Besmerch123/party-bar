/**
 * Ingredient Service
 * 
 * Contains the business logic for ingredient operations.
 * Following DDD principles, this is the application service layer.
 */

import { IngredientRepository } from './ingredient.repository';

import { AbstractService } from '../shared/abstract.service';

import { Ingredient, CreateIngredientDto, UpdateIngredientDto, IngredientDocument, INGREDIENT_CATEGORIES, IngredientCategory } from './ingredient.model';
import { DocumentSnapshot } from 'firebase-admin/firestore';

export class IngredientService extends AbstractService {
  private readonly repository = new IngredientRepository();

  /**
   * Creates a new ingredient with validation
   */
  async createIngredient(data: CreateIngredientDto): Promise<Ingredient> {
    // Validate input
    this.validateIngredientData(data);
    
    const image = this.normalizeImage(data.image);
    const normalizedTitle = this.normalizeI18nField(data.title);


    // Create the ingredient
    const created = await this.repository.create({
      title: normalizedTitle,
      category: data.category,
      image,
      slug: this.normalizeSlug(data.slug),
    });

    return this.docSnapshotToIngredient(created);
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

    return this.docSnapshotToIngredient(ingredient);
  }

  async getIngredientsByIds(ids: string[]): Promise<Ingredient[]>  {
    if (!Array.isArray(ids) || ids.length === 0) {
      return [];
    }

    const normalizedIds = ids.map(id => this.normalizeId(id));

    if (normalizedIds.length === 0) {
      return [];
    }
    
    const ingredients = await this.repository.findByIds(normalizedIds);

    return ingredients.map(this.docSnapshotToIngredient);
  }

  /**
   * Retrieves all ingredients
   * @todo Implement pagination and filtering
   */
  async getAllIngredients(): Promise<Ingredient[]> {
    return [];
  }

  /**
   * Retrieves ingredients by category
   */
  async getIngredientsByCategory(category: string): Promise<Ingredient[]> {
    if (!category || category.trim() === '') {
      throw new Error('Category is required');
    }

    const ingredients = await this.repository.findByCategory(category.trim());
    return ingredients.map(this.docSnapshotToIngredient);
  }

  /**
   * Updates an existing ingredient
   */
  async updateIngredient(data: UpdateIngredientDto): Promise<Ingredient> {
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
    if (data.slug !== undefined) {
      updatePayload.slug = this.normalizeSlug(data.slug);
    }
    if (data.unlocks !== undefined) {
      updatePayload.unlocks = this.validateCount(data.unlocks, 'unlocks');
    }
    if (data.cocktailCount !== undefined) {
      updatePayload.cocktailCount = this.validateCount(data.cocktailCount, 'cocktailCount');
    }

    const updatedIngredient = await this.repository.update(updatePayload);
    if (!updatedIngredient) {
      throw new Error('Ingredient not found');
    }

    return this.docSnapshotToIngredient(updatedIngredient);
  }

  /**
   * Deletes an ingredient
   */
  async deleteIngredient(id: string): Promise<void> {
    if (!id || id.trim() === '') {
      throw new Error('Ingredient ID is required');
    }

    await this.repository.delete(id.trim());
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
   * Validates ingredient category against the known set.
   *
   * Anything outside it decodes to `other` on the device, so accepting a typo
   * here miscategorises the ingredient silently rather than failing the write.
   */
  private validateCategory(category: string): void {
    if (!category || typeof category !== 'string') {
      throw new Error('Category is required and must be a string');
    }

    const trimmedCategory = category.trim().toLowerCase() as IngredientCategory;
    if (trimmedCategory.length === 0) {
      throw new Error('Category cannot be empty');
    }

    const allowed = Object.values(INGREDIENT_CATEGORIES) as string[];
    if (!allowed.includes(trimmedCategory)) {
      throw new Error(`Invalid ingredient category: ${category}. Expected one of: ${allowed.join(', ')}`);
    }
  }

  /**
   * The stable human key the on-device shelf is stored as -- "sweetVermouth",
   * not the kebab-case document id. Null clears it.
   */
  private normalizeSlug(slug: string | null | undefined): string | null {
    if (slug === null || slug === undefined) {
      return null;
    }

    if (typeof slug !== 'string') {
      throw new Error('Slug must be a string');
    }

    const trimmed = slug.trim();
    if (trimmed.length === 0) {
      return null;
    }

    if (!/^[a-zA-Z][a-zA-Z0-9]*$/.test(trimmed)) {
      throw new Error(`Invalid slug: ${slug}. Expected a camelCase key such as "sweetVermouth"`);
    }

    return trimmed;
  }

  /**
   * Guards the derived figures. They are written by the catalogue recount
   * rather than typed in, but a hand-run update should still not store a
   * negative or fractional count.
   */
  private validateCount(value: number | null, field: string): number | null {
    if (value === null) {
      return null;
    }

    if (typeof value !== 'number' || !Number.isInteger(value) || value < 0) {
      throw new Error(`${field} must be a non-negative integer or null`);
    }

    return value;
  }

  private docSnapshotToIngredient(doc: DocumentSnapshot<IngredientDocument>): Ingredient {
    const data = doc.data()!;

    return { 
      ...data, 
      id: doc.id,
      updatedAt: data?.updatedAt.toDate().toString(),
      createdAt: data?.createdAt.toDate().toString()
    };
  }
}
