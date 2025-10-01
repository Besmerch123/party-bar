/**
 * Ingredient Repository
 * 
 * Handles data persistence operations for ingredients using Firestore.
 * Following DDD principles, this abstracts the database layer.
 */

import { CollectionReference, getFirestore, Timestamp } from 'firebase-admin/firestore';

import { SupportedLocale } from '../shared/types';

import type { 
  Ingredient,
  CreateIngredientDto, 
  UpdateIngredientDto, 
  IngredientDocument
} from './ingredient.model';


export class IngredientRepository {
  private readonly collection = getFirestore().collection('ingredients') as CollectionReference<IngredientDocument>;

  /**
   * Creates a new ingredient in Firestore
   */
  async create(ingredientData: CreateIngredientDto, locale: SupportedLocale): Promise<Ingredient> {
    const now = new Date();
    const docRef = this.collection.doc();
    
    const ingredient: Ingredient = {
      id: docRef.id,
      title: ingredientData.title,
      category: ingredientData.category,
      image: ingredientData.image,
      createdAt: now,
      updatedAt: now,
    };

    const timestamp = Timestamp.fromDate(now);

    const firestoreData: IngredientDocument = {
      title: {
        [locale]: ingredient.title
      },
      category: ingredient.category,
      image: ingredient.image,
      createdAt: timestamp,
      updatedAt: timestamp,
    };

    await docRef.set(firestoreData);

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
      image: data?.image,
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
        image: data.image,
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
        image: data.image,
        createdAt: data.createdAt?.toDate(),
        updatedAt: data.updatedAt?.toDate(),
      } as Ingredient;
    });
  }

  /**
   * Updates an existing ingredient
   */
  async update(id: string, updateData: UpdateIngredientDto, locale: SupportedLocale): Promise<Ingredient | null> {
    const docRef = this.collection.doc(id);
    const doc = await docRef.get();
    
    if (!doc.exists) {
      return null;
    }

    const now = new Date();
    const updatedFields: Record<string, unknown> = {
      updatedAt: Timestamp.fromDate(now),
    };

    if (updateData.title !== undefined) {
      updatedFields.title = { [locale]: updateData.title };
    }

    if (updateData.category !== undefined) {
      updatedFields.category = updateData.category;
    }

    if (updateData.image !== undefined) {
      updatedFields.image = updateData.image;
    }

    await docRef.set(updatedFields, { merge: true });
    
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
