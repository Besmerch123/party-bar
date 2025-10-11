import { CollectionReference } from 'firebase-admin/firestore';

export abstract class AbstractRepository {
  abstract collection: CollectionReference;

  protected async getSafeSlug(englishTitle: string): Promise<string> {
    const baseSlug = this.createSlug(englishTitle);
    let slug = baseSlug;
    let counter = 1;

    while (true) {
      const docRef = await this.collection.doc(slug).get();
      
      if (!docRef.exists) {
        return slug;
      }
      
      slug = `${baseSlug}-${counter}`;
      counter++;
    }
  }

  private createSlug(input: string, maxLength: number = 60): string {
    return input
      .normalize('NFD')
      .replace(/\p{Diacritic}+/gu, '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/(^-|-$)/g, '')
      .slice(0, maxLength);
  }
}
