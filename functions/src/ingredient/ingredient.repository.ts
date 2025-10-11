/**
 * Ingredient Repository
 * 
 * Handles data persistence operations for ingredients using Firestore.
 * Following DDD principles, this abstracts the database layer.
 */

import { firestore } from 'firebase-admin';
import { CollectionReference, DocumentSnapshot, Timestamp } from 'firebase-admin/firestore';

import { AbstractRepository } from '../shared/abstract.repository';

import { IngredientDocument, CreateIngredientDto, UpdateIngredientDto } from './ingredient.model';


export class IngredientRepository extends AbstractRepository {
  readonly collection = firestore().collection('ingredients') as CollectionReference<IngredientDocument>;

  /**
   * Creates a new ingredient in Firestore
   */
  async create(ingredientData: CreateIngredientDto): Promise<IngredientDocument> {
    const englishTitle = ingredientData.title['en'];

    if (!englishTitle) {
      throw new Error('English title is required to create an ingredient');
    }

    const slug = await this.getSafeSlug(englishTitle);
    const docRef = this.collection.doc(slug);

    const timestamp = Timestamp.now();
    const ingredientDoc: IngredientDocument = {
      title: ingredientData.title,
      category: ingredientData.category,
      image: ingredientData.image,
      createdAt: timestamp,
      updatedAt: timestamp,
    };

    await docRef.set(ingredientDoc);

    return ingredientDoc;
  }

  /**
   * Retrieves an ingredient by ID
   */
  async findById(id: string): Promise<DocumentSnapshot<IngredientDocument> | null> {
    const doc = await this.collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return doc; 
  }

  /**
   * Retrieves multiple ingredients by their IDs
   */
  async findByIds(ids: string[]): Promise<DocumentSnapshot<IngredientDocument>[]> {
    if (ids.length === 0) {
      return [];
    }

    const snapshot = await this.collection.where(firestore.FieldPath.documentId(), 'in', ids).get();

    return snapshot.docs;
  }

  /**
   * Updates an existing ingredient
   */
  async update({ id, ...updateData }: UpdateIngredientDto): Promise<DocumentSnapshot<IngredientDocument> | null> {
    const docRef = this.collection.doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new Error(`Ingredient ${id} not found`);
    }

    await docRef.update({ ...updateData, 
      updatedAt: Timestamp.now()
    });

    return this.findById(id);
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
}
