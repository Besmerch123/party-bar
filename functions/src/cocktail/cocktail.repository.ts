/**
 * Cocktail Repository
 *
 * Handles data persistence operations for cocktails using Firestore.
 * Following DDD principles, this abstracts the database layer.
 */

import * as admin from 'firebase-admin';
import { Cocktail, CreateCocktailDto, UpdateCocktailDto } from './cocktail.model';

export class CocktailRepository {
  private readonly collection = admin.firestore().collection('cocktails');

  /**
   * Creates a new cocktail in Firestore
   */
  async create(cocktailData: CreateCocktailDto): Promise<Cocktail> {
    const now = new Date();
    const docRef = this.collection.doc();

    const cocktail: Cocktail = {
      id: docRef.id,
      title: cocktailData.title,
      description: cocktailData.description,
      ingredients: cocktailData.ingredients,
      equipments: cocktailData.equipments,
      categories: cocktailData.categories,
      createdAt: now,
      updatedAt: now,
    };

    const firestoreData: Record<string, unknown> = {
      id: cocktail.id,
      title: cocktail.title,
      description: cocktail.description,
      ingredients: cocktail.ingredients,
      equipments: cocktail.equipments,
      categories: cocktail.categories,
      createdAt: admin.firestore.Timestamp.fromDate(now),
      updatedAt: admin.firestore.Timestamp.fromDate(now),
    };

    await docRef.set(firestoreData);

    return cocktail;
  }

  /**
   * Retrieves a cocktail by ID
   */
  async findById(id: string): Promise<Cocktail | null> {
    const doc = await this.collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    const data = doc.data();
    return {
      id: doc.id,
      title: data?.title,
      description: data?.description,
      ingredients: data?.ingredients ?? [],
      equipments: data?.equipments ?? [],
      categories: data?.categories ?? [],
      createdAt: data?.createdAt?.toDate(),
      updatedAt: data?.updatedAt?.toDate(),
    } as Cocktail;
  }

  /**
   * Retrieves all cocktails ordered by title
   */
  async findAll(): Promise<Cocktail[]> {
    const snapshot = await this.collection.orderBy('title', 'asc').get();

    return snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        title: data.title,
        description: data.description,
        ingredients: data.ingredients ?? [],
        equipments: data.equipments ?? [],
        categories: data.categories ?? [],
        createdAt: data.createdAt?.toDate(),
        updatedAt: data.updatedAt?.toDate(),
      } as Cocktail;
    });
  }

  /**
   * Retrieves cocktails by category
   */
  async findByCategory(category: string): Promise<Cocktail[]> {
    const snapshot = await this.collection
      .where('categories', 'array-contains', category)
      .orderBy('title', 'asc')
      .get();

    return snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        title: data.title,
        description: data.description,
        ingredients: data.ingredients ?? [],
        equipments: data.equipments ?? [],
        categories: data.categories ?? [],
        createdAt: data.createdAt?.toDate(),
        updatedAt: data.updatedAt?.toDate(),
      } as Cocktail;
    });
  }

  /**
   * Updates an existing cocktail
   */
  async update(id: string, updateData: UpdateCocktailDto): Promise<Cocktail | null> {
    const docRef = this.collection.doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return null;
    }

    const now = new Date();
    const updatedFields: Record<string, unknown> = {
      updatedAt: admin.firestore.Timestamp.fromDate(now),
    };

    if (updateData.title !== undefined) {
      updatedFields.title = updateData.title;
    }

    if (updateData.description !== undefined) {
      updatedFields.description = updateData.description;
    }

    if (updateData.ingredients !== undefined) {
      updatedFields.ingredients = updateData.ingredients;
    }

    if (updateData.equipments !== undefined) {
      updatedFields.equipments = updateData.equipments;
    }

    if (updateData.categories !== undefined) {
      updatedFields.categories = updateData.categories;
    }

    await docRef.update(updatedFields);

    return await this.findById(id);
  }

  /**
   * Deletes a cocktail by ID
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
   * Checks if a cocktail with the given title already exists
   */
  async existsByTitle(title: string, excludeId?: string): Promise<boolean> {
    const snapshot = await this.collection.where('title', '==', title).get();

    if (excludeId) {
      return snapshot.docs.some((doc) => doc.id !== excludeId);
    }

    return !snapshot.empty;
  }
}
