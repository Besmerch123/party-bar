/**
 * Cocktail Repository
 *
 * Handles data persistence operations for cocktails using Firestore.
 * Following DDD principles, this abstracts the database layer.
 */

import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';
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
      abv: cocktailData.abv,
      preparationSteps: cocktailData.preparationSteps,
      image: cocktailData.image,
      createdAt: now,
      updatedAt: now,
    };

    const timestamp = Timestamp.fromDate(now);
    const firestoreData: Record<string, unknown> = {
      title: cocktail.title,
      description: cocktail.description,
      ingredients: cocktail.ingredients,
      equipments: cocktail.equipments,
      categories: cocktail.categories,
      preparationSteps: cocktail.preparationSteps,
      createdAt: timestamp,
      updatedAt: timestamp,
    };

    if (cocktailData.abv !== undefined) {
      firestoreData.abv = cocktailData.abv;
    }

    if (cocktailData.image !== undefined) {
      firestoreData.image = cocktailData.image;
    }

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
      abv: data?.abv,
      preparationSteps: data?.preparationSteps ?? {},
      image: data?.image,
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
        abv: data.abv,
        preparationSteps: data.preparationSteps ?? {},
        image: data.image,
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
        abv: data.abv,
        preparationSteps: data.preparationSteps ?? {},
        image: data.image,
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
      updatedAt: Timestamp.fromDate(now),
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

    if (updateData.abv !== undefined) {
      updatedFields.abv = updateData.abv;
    }

    if (updateData.preparationSteps !== undefined) {
      updatedFields.preparationSteps = updateData.preparationSteps;
    }

    if (updateData.image !== undefined) {
      updatedFields.image = updateData.image;
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
   * Checks if a cocktail with the given title already exists in any locale
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
