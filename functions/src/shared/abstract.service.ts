import { I18nField } from './types';

export abstract class AbstractService {
  /**
   * Validates and normalizes the optional image path
   */
  protected normalizeImage(image: string | null | undefined ): string | undefined {
    if (!image) {
      return undefined;
    }

    if (typeof image !== 'string') {
      throw new Error('Image path must be a string');
    }

    const trimmedImage = image.trim();

    if (trimmedImage.length === 0) {
      throw new Error('Image path cannot be empty');
    }

    if (trimmedImage.length > 2048) {
      throw new Error('Image path cannot exceed 2048 characters');
    }

    return trimmedImage;
  }

  /**
   * Validates I18n field (translatable field)
   */
  protected validateI18nField(field: I18nField): void {
    if (!field || typeof field !== 'object') {
      throw new Error('Title is required and must be an object with locale keys');
    }

    const locales = Object.keys(field);
    if (locales.length === 0) {
      throw new Error('Title must have at least one locale');
    }

    for (const locale of locales) {
      const value = field[locale as keyof typeof field];
      if (value !== undefined) {
        this.validateStringValue(value, locale);
      }
    }
  }

  /**
   * Normalizes I18n field by trimming all locale values
   */
  protected normalizeI18nField(field: I18nField): I18nField {
    const normalized: I18nField = {};
    for (const locale of Object.keys(field)) {
      const value = field[locale as keyof typeof field];
      if (value !== undefined && typeof value === 'string') {
        normalized[locale as keyof typeof normalized] = value.trim();
      }
    }
    return normalized;
  }

  /**
   * Validates a single title value for a specific locale
   */
  private validateStringValue(title: string, locale: string): void {
    if (typeof title !== 'string') {
      throw new Error(`Title for locale '${locale}' must be a string`);
    }

    const trimmedTitle = title.trim();
    if (trimmedTitle.length === 0) {
      throw new Error(`Title for locale '${locale}' cannot be empty`);
    }

    if (trimmedTitle.length < 2) {
      throw new Error(`Title for locale '${locale}' must be at least 2 characters long`);
    }
  }
}
