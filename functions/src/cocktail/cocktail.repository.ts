/**
 * Cocktail Repository
 *
 * Handles data persistence operations for cocktails using Firestore.
 * Following DDD principles, this abstracts the database layer.
 */

import { firestore } from 'firebase-admin';
import { CollectionReference, DocumentSnapshot, Timestamp } from 'firebase-admin/firestore';

import { AbstractRepository } from '../shared/abstract.repository';

import { CocktailDocument, CreateCocktailDto, UpdateCocktailDto } from './cocktail.model';



export class CocktailRepository extends AbstractRepository {
  readonly collection = firestore().collection('cocktails') as CollectionReference<CocktailDocument>;

  /**
   * Creates a new cocktail in Firestore
   */
  async create(cocktailData: CreateCocktailDto): Promise<CocktailDocument> {
    const englishTitle = cocktailData.title['en'];

    if (!englishTitle) {
      throw new Error('English title is required to create a cocktail');
    }

    const slug = await this.getSafeSlug(englishTitle);
    const docRef = this.collection.doc(slug);

    const timestamp = Timestamp.now();
    const cocktailDoc: CocktailDocument = {
      title: cocktailData.title,
      description: cocktailData.description,
      ingredients: cocktailData.ingredients,
      equipments: cocktailData.equipments,
      categories: cocktailData.categories,
      abv: cocktailData.abv,
      image: cocktailData.image,
      preparationSteps: cocktailData.preparationSteps,
      createdAt: timestamp,
      updatedAt: timestamp,
    };

    await docRef.set(cocktailDoc);

    return cocktailDoc;
  }

  /**
   * Retrieves a cocktail by ID
   */
  async findById(id: string): Promise<DocumentSnapshot<CocktailDocument> | null> {
    const doc = await this.collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return doc; 
  }

  /**
   * Updates an existing cocktail
   */
  async update({ id, ...updateData }: UpdateCocktailDto): Promise<DocumentSnapshot<CocktailDocument> | null> {
    const docRef = this.collection.doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new Error(`Cocktail ${id} not found`);
    }

    await docRef.update({ ...updateData, 
      updatedAt: Timestamp.now()
    });

    return this.findById(id);
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
}
