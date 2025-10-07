/**
 * Equipment Repository
 * 
 * Handles data persistence operations for equipment using Firestore.
 * Following DDD principles, this abstracts the database layer.
 */

import { firestore } from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';
import { Equipment, CreateEquipmentDto, UpdateEquipmentDto } from './equipment.model';

export class EquipmentRepository {
  private readonly collection = firestore().collection('equipment');

  /**
   * Creates a new equipment in Firestore
   */
  async create(equipmentData: CreateEquipmentDto): Promise<Equipment> {
    const now = new Date();
    const docRef = this.collection.doc();
    
    const equipment: Equipment = {
      id: docRef.id,
      title: equipmentData.title,
      image: equipmentData.image,
      createdAt: now,
      updatedAt: now,
    };

    const firestoreData: Record<string, unknown> = {
      id: equipment.id,
      title: equipment.title,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    };

    if (equipment.image !== undefined) {
      firestoreData.image = equipment.image;
    }

    await docRef.set(firestoreData);

    return equipment;
  }

  /**
   * Retrieves an equipment by ID
   */
  async findById(id: string): Promise<Equipment | null> {
    const doc = await this.collection.doc(id).get();
    
    if (!doc.exists) {
      return null;
    }

    const data = doc.data();
    const equipment: Equipment = {
      id: doc.id,
      title: data?.title || {},
      createdAt: data?.createdAt?.toDate(),
      updatedAt: data?.updatedAt?.toDate(),
    };

    if (data?.image !== undefined) {
      equipment.image = data.image;
    }

    return equipment;
  }

  /**
   * Retrieves all equipment
   */
  async findAll(): Promise<Equipment[]> {
    const snapshot = await this.collection.orderBy('title.en', 'asc').get();
    
    return snapshot.docs.map(doc => {
      const data = doc.data();
      const equipment: Equipment = {
        id: doc.id,
        title: data.title || {},
        createdAt: data.createdAt?.toDate(),
        updatedAt: data.updatedAt?.toDate(),
      };

      if (data.image !== undefined) {
        equipment.image = data.image;
      }

      return equipment;
    });
  }



  /**
   * Updates an existing equipment
   */
  async update(id: string, updateData: UpdateEquipmentDto): Promise<Equipment | null> {
    const docRef = this.collection.doc(id);
    const doc = await docRef.get();
    
    if (!doc.exists) {
      return null;
    }

    const updatedFields: Record<string, unknown> = {
      updatedAt: Timestamp.now(),
    };

    if (updateData.title !== undefined) {
      updatedFields.title = updateData.title;
    }

    if (updateData.image !== undefined) {
      updatedFields.image = updateData.image;
    }

    await docRef.update(updatedFields);
    
    // Return the updated equipment
    return await this.findById(id);
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

  /**
   * Checks if an equipment with the given title already exists in any locale
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
