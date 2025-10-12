/**
 * Ingredient Service
 * 
 * Contains the business logic for ingredient operations.
 * Following DDD principles, this is the application service layer.
 */

import { IngredientRepository } from './ingredient.repository';

import { AbstractService } from '../shared/abstract.service';

import { Ingredient, CreateIngredientDto, UpdateIngredientDto, IngredientDocument } from './ingredient.model';
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
