/**
 * Equipment Service
 * 
 * Contains the business logic for equipment operations.
 * Following DDD principles, this is the application service layer.
 */

import { EquipmentRepository } from './equipment.repository';

import { AbstractService } from '../shared/abstract.service';

import { Equipment, CreateEquipmentDto, UpdateEquipmentDto, EquipmentDocument, EQUIPMENT_KINDS, EquipmentKind } from './equipment.model';
import { DocumentSnapshot } from 'firebase-admin/firestore';

export class EquipmentService extends AbstractService {
  private readonly repository = new EquipmentRepository();

  /**
   * Creates a new equipment with validation
   */
  async createEquipment(data: CreateEquipmentDto): Promise<Equipment> {
    // Validate input
    this.validateEquipmentData(data);
    
    const image = this.normalizeImage(data.image);
    const normalizedTitle = this.normalizeI18nField(data.title);

    // Create the equipment
    const created = await this.repository.create({
      title: normalizedTitle,
      image,
      slug: this.normalizeSlug(data.slug),
      kind: this.normalizeKind(data.kind),
    });

    return this.docSnapshotToEquipment(created);
  }

  /**
   * Retrieves an equipment by ID
   */
  async getEquipment(id: string): Promise<Equipment> {
    if (!id || id.trim() === '') {
      throw new Error('Equipment ID is required');
    }

    const equipment = await this.repository.findById(id.trim());

    if (!equipment) {
      throw new Error('Equipment not found');
    }

    return this.docSnapshotToEquipment(equipment);
  }

  /**
   * Retrieves all equipment
   */
  async getAllEquipment(): Promise<Equipment[]> {
    const equipment = await this.repository.findAll();
    return equipment.map(doc => this.docSnapshotToEquipment(doc));
  }

  async getEquipmentByIds(ids: string[]): Promise<Equipment[]> {
    if (!Array.isArray(ids) || ids.length === 0) {
      return [];
    }

    const normalizedIds = ids.map(id => this.normalizeId(id));

    if (normalizedIds.length === 0) {
      return [];
    }
    
    const equipment = await this.repository.findByIds(normalizedIds);
  
    return equipment.map(doc => this.docSnapshotToEquipment(doc));
  }

  /**
   * Updates an existing equipment
   */
  async updateEquipment(data: UpdateEquipmentDto): Promise<Equipment> {
    // Validate update data if provided
    if (data.title !== undefined) {
      this.validateI18nField(data.title);
    }

    const updatePayload: UpdateEquipmentDto = {
      ...data
    };
    if (data.title !== undefined) {
      updatePayload.title = this.normalizeI18nField(data.title);
    }
    if (data.image !== undefined) {
      const image = this.normalizeImage(data.image);
      if (image !== undefined) {
        updatePayload.image = image;
      }
    }
    if (data.slug !== undefined) {
      updatePayload.slug = this.normalizeSlug(data.slug);
    }
    if (data.kind !== undefined) {
      updatePayload.kind = this.normalizeKind(data.kind);
    }

    const updatedEquipment = await this.repository.update(updatePayload);

    if (!updatedEquipment) {
      throw new Error('Equipment not found');
    }

    return this.docSnapshotToEquipment(updatedEquipment);
  }

  /**
   * Deletes an equipment
   */
  async deleteEquipment(id: string): Promise<void> {
    if (!id || id.trim() === '') {
      throw new Error('Equipment ID is required');
    }

    const deleted = await this.repository.delete(id.trim());

    if (!deleted) {
      throw new Error('Equipment not found');
    }
  }

  /**
   * Validates equipment data
   */
  private validateEquipmentData(data: CreateEquipmentDto): void {
    this.validateI18nField(data.title);
    this.normalizeImage(data.image);
  }

  /**
   * The stable human key the on-device shelf is stored as -- "boston_shaker"
   * is a document id, "bostonShaker" is the key a shelf collected during
   * onboarding carries.
   */
  private normalizeSlug(slug: string | null | undefined): string | null {
    if (slug === null || slug === undefined) {
      return null;
    }

    if (typeof slug !== 'string') {
      throw new Error('Slug must be a string');
    }

    const trimmed = slug.trim();
    if (trimmed.length === 0) {
      return null;
    }

    if (!/^[a-zA-Z][a-zA-Z0-9]*$/.test(trimmed)) {
      throw new Error(`Invalid slug: ${slug}. Expected a camelCase key such as "bostonShaker"`);
    }

    return trimmed;
  }

  /**
   * Tool, glassware or ice. The app groups the shelf by this, so an unknown
   * value would quietly file a jigger with the ice.
   */
  private normalizeKind(kind: EquipmentKind | null | undefined): EquipmentKind {
    if (kind === null || kind === undefined) {
      return EQUIPMENT_KINDS.TOOL;
    }

    const allowed = Object.values(EQUIPMENT_KINDS) as string[];
    if (typeof kind !== 'string' || !allowed.includes(kind)) {
      throw new Error(`Invalid equipment kind: ${kind}. Expected one of: ${allowed.join(', ')}`);
    }

    return kind;
  }

  private docSnapshotToEquipment(doc: DocumentSnapshot<EquipmentDocument>): Equipment {
    const data = doc.data();
    if (!data) {
      throw new Error('Document data is undefined');
    }

    return { 
      ...data,
      id: doc.id,
      createdAt: data.createdAt.toDate().toString(),
      updatedAt: data.updatedAt.toDate().toString() 
    };
  }
}
