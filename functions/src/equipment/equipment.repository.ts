/**
 * Equipment Repository
 * 
 * Handles data persistence operations for equipment using Firestore.
 * Following DDD principles, this abstracts the database layer.
 */

import { firestore } from 'firebase-admin';
import { CollectionReference, DocumentSnapshot, Timestamp, FieldPath } from 'firebase-admin/firestore';

import { AbstractRepository } from '../shared/abstract.repository';

import { EquipmentDocument, CreateEquipmentDto, UpdateEquipmentDto } from './equipment.model';

export class EquipmentRepository extends AbstractRepository {
  readonly collection = firestore().collection('equipment') as CollectionReference<EquipmentDocument>;

  /**
   * Creates a new equipment in Firestore
   */
  async create(equipmentData: CreateEquipmentDto): Promise<DocumentSnapshot<EquipmentDocument>> {
    const englishTitle = equipmentData.title['en'];

    if (!englishTitle) {
      throw new Error('English title is required to create equipment');
    }

    const slug = await this.getSafeSlug(englishTitle);
    const docRef = this.collection.doc(slug);

    const timestamp = Timestamp.now();
    const equipmentDoc: EquipmentDocument = {
      title: equipmentData.title,
      image: equipmentData.image,
      createdAt: timestamp,
      updatedAt: timestamp,
    };

    await docRef.set(equipmentDoc, { merge: true });

    const equipment = await docRef.get();

    return equipment;
  }

  /**
   * Retrieves an equipment by ID
   */
  async findById(id: string): Promise<DocumentSnapshot<EquipmentDocument> | null> {
    const doc = await this.collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return doc;
  }

  /**
   * Retrieves multiple equipment by their IDs
   */
  async findByIds(ids: string[]): Promise<DocumentSnapshot<EquipmentDocument>[]> {
    if (ids.length === 0) {
      return [];
    }

    const snapshot = await this.collection.where(FieldPath.documentId(), 'in', ids).get();

    return snapshot.docs;
  }

  /**
   * Updates an existing equipment
   */
  async update({ id, ...updateData }: UpdateEquipmentDto): Promise<DocumentSnapshot<EquipmentDocument>> {
    const docRef = this.collection.doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new Error(`Equipment ${id} not found`);
    }

    await docRef.update({ ...updateData, 
      updatedAt: Timestamp.now()
    });

    const updatedDoc = await docRef.get();

    return updatedDoc;
  }

  /**
   * Deletes an equipment by ID
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
