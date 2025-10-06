/**
 * Cocktail Domain Model
 * 
 * Represents a cocktail composed of ingredients and prepared with equipment.
 * Following DDD principles, this is the core entity of the Cocktail domain.
 */

import { Timestamp } from 'firebase-admin/firestore';
import { I18nField, I18nArrayField } from '../shared/types';

export const COCKTAIL_CATEGORIES = {
  CLASSIC: 'classic',
  SIGNATURE: 'signature',
  SEASONAL: 'seasonal',
  FROZEN: 'frozen',
  MOCKTAIL: 'mocktail',
  SHOT: 'shot',
  LONG: 'long',
  PUNCH: 'punch',
  TIKI: 'tiki',
  HIGHBALL: 'highball',
  LOWBALL: 'lowball',
} as const;

export type CocktailCategory = typeof COCKTAIL_CATEGORIES[keyof typeof COCKTAIL_CATEGORIES];

export interface Cocktail {
  /** Unique identifier (Firebase document ID) */
  id: string;

  /** Human-readable name/title of the cocktail */
  title: I18nField;

  /** Detailed description, preparation notes, history, etc. */
  description: I18nField;

  /** Firestore document paths referencing ingredient records */
  ingredients: string[];

  /** Firestore document paths referencing equipment records */
  equipments: string[];

  /** Categorization tags to aid discovery */
  categories: CocktailCategory[];

  /** Alcohol by volume percentage (0-100), optional */
  abv?: number;

  /** Step-by-step preparation instructions */
  preparationSteps: I18nArrayField;

  /** Timestamp when the cocktail was created */
  createdAt?: Date;

  /** Timestamp when the cocktail was last updated */
  updatedAt?: Date;
}

export interface CocktailDocument extends Omit<Cocktail, 'id' |'createdAt' | 'updatedAt'> {
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface CreateCocktailDto {
  title: I18nField;
  description: I18nField;
  ingredients: string[];
  equipments: string[];
  categories: CocktailCategory[];
  abv?: number;
  preparationSteps: I18nArrayField;
}

export interface UpdateCocktailDto {
  id?: string;
  title?: I18nField;
  description?: I18nField;
  ingredients?: string[];
  equipments?: string[];
  categories?: CocktailCategory[];
  abv?: number;
  preparationSteps?: I18nArrayField;
}
