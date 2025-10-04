/**
 * Ingredient Repository
 * 
 * Handles data persistence operations for ingredients using Firestore.
 * Following DDD principles, this abstracts the database layer.
 */

import { CollectionReference, getFirestore, Timestamp } from 'firebase-admin/firestore';

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
  async create(ingredientData: CreateIngredientDto): Promise<Ingredient> {
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
      title: ingredient.title,
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
  async update(id: string, updateData: UpdateIngredientDto): Promise<Ingredient | null> {
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
      updatedFields.title = updateData.title;
    }

    if (updateData.category !== undefined) {
      updatedFields.category = updateData.category;
    }

    if (updateData.image !== undefined) {
      updatedFields.image = updateData.image;
    }

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
   * Checks if an ingredient with the given title already exists in any locale
   */
  async existsByTitle(title: string, locale: string = 'en'): Promise<boolean> {
    const fieldPath = `title.${locale}`;
    const snapshot = await this.collection
      .where(fieldPath, '==', title.trim())
      .limit(1)
      .get();
    
    return !snapshot.empty;
  }
}
