/**
 * Ingredient Repository
 * 
 * Handles data persistence operations for ingredients using Firestore.
 * Following DDD principles, this abstracts the database layer.
 */

import * as admin from 'firebase-admin';
import { Ingredient, CreateIngredientDto, UpdateIngredientDto } from './ingredient.model';

export class IngredientRepository {
  private readonly collection = admin.firestore().collection('ingredients');

  /**
   * Creates a new ingredient in Firestore
   */
  async create(ingredientData: CreateIngredientDto): Promise<Ingredient> {
    const now = new Date();
    const docRef = this.collection.doc();
    
    const ingredient: Ingredient = {
      id: docRef.id,
      ...ingredientData,
      createdAt: now,
      updatedAt: now,
    };

    await docRef.set({
      ...ingredient,
      createdAt: admin.firestore.Timestamp.fromDate(now),
      updatedAt: admin.firestore.Timestamp.fromDate(now),
    });

    return ingredient;
  }

  /**
   * Retrieves an ingredient by ID
   */
  async findById(id: string): Promise<Ingredient | null> {
    const doc = await this.collection.doc(id).get();
    
    if (!doc.exists) {
      return null;
    }

    const data = doc.data();
    return {
      id: doc.id,
      title: data?.title,
      category: data?.category,
      createdAt: data?.createdAt?.toDate(),
      updatedAt: data?.updatedAt?.toDate(),
    } as Ingredient;
  }

  /**
   * Retrieves all ingredients
   */
  async findAll(): Promise<Ingredient[]> {
    const snapshot = await this.collection.orderBy('title', 'asc').get();
    
    return snapshot.docs.map(doc => {
      const data = doc.data();
      return {
        id: doc.id,
        title: data.title,
        category: data.category,
        createdAt: data.createdAt?.toDate(),
        updatedAt: data.updatedAt?.toDate(),
      } as Ingredient;
    });
  }

  /**
   * Retrieves ingredients by category
   */
  async findByCategory(category: string): Promise<Ingredient[]> {
    const snapshot = await this.collection
      .where('category', '==', category)
      .orderBy('title', 'asc')
      .get();
    
    return snapshot.docs.map(doc => {
      const data = doc.data();
      return {
        id: doc.id,
        title: data.title,
        category: data.category,
        createdAt: data.createdAt?.toDate(),
        updatedAt: data.updatedAt?.toDate(),
      } as Ingredient;
    });
  }

  /**
   * Updates an existing ingredient
   */
  async update(id: string, updateData: UpdateIngredientDto): Promise<Ingredient | null> {
    const docRef = this.collection.doc(id);
    const doc = await docRef.get();
    
    if (!doc.exists) {
      return null;
    }

    const now = new Date();
    const updatedFields = {
      ...updateData,
      updatedAt: admin.firestore.Timestamp.fromDate(now),
    };

    await docRef.update(updatedFields);
    
    // Return the updated ingredient
    return await this.findById(id);
  }

  /**
   * Deletes an ingredient by ID
   */
  async delete(id: string): Promise<boolean> {
    const docRef = this.collection.doc(id);
    const doc = await docRef.get();
    
    if (!doc.exists) {
      return false;
    }

    await docRef.delete();
    return true;
  }

  /**
   * Checks if an ingredient with the given title already exists
   */
  async existsByTitle(title: string, excludeId?: string): Promise<boolean> {
    const query = this.collection.where('title', '==', title);
    
    const snapshot = await query.get();
    
    if (excludeId) {
      return snapshot.docs.some(doc => doc.id !== excludeId);
    }
    
    return !snapshot.empty;
  }
}
