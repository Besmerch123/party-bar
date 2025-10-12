/**
 * Cocktail Domain Model
 * 
 * Represents a cocktail composed of ingredients and prepared with equipment.
 * Following DDD principles, this is the core entity of the Cocktail domain.
 */

import { Timestamp } from 'firebase-admin/firestore';
import type { Ingredient, IngredientSearchDocument } from '../ingredient/ingredient.model';
import type { Equipment, EquipmentSearchDocument } from '../equipment/equipment.model';
import type { ElasticDocument } from '../elastic/elastic.types';
import type { I18nField, I18nArrayField, PaginationParams } from '../shared/types';

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
  description?: I18nField;

  /** Firestore document paths referencing ingredient records */
  ingredients: Ingredient[];

  /** Firestore document paths referencing equipment records */
  equipments: Equipment[];

  /** Categorization tags to aid discovery */
  categories: CocktailCategory[];

  /** Alcohol by volume percentage (0-100), optional */
  abv?: number | null;

  /** Step-by-step preparation instructions */
  preparationSteps: I18nArrayField;

  /** URL or path to the cocktail image */
  image?: string | null;

  /** Timestamp when the cocktail was created */
  createdAt?: string;

  /** Timestamp when the cocktail was last updated */
  updatedAt?: string;
}

export interface CocktailDocument extends Omit<Cocktail, 'id' |'createdAt' | 'updatedAt' | 'ingredients' | 'equipments'> {
  /** Firestore document paths referencing ingredient records */
  ingredients: string[];

  /** Firestore document paths referencing equipment records */
  equipments: string[];
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface CreateCocktailDto {
  title: I18nField;
  description: I18nField;
  ingredients: string[];
  equipments: string[];
  categories: CocktailCategory[];
  abv?: number | null;
  preparationSteps: I18nArrayField;
  image?: string | null;
}

export interface UpdateCocktailDto {
  id: string;
  title?: I18nField;
  description?: I18nField;
  ingredients?: string[];
  equipments?: string[];
  categories?: CocktailCategory[];
  abv?: number | null;
  preparationSteps?: I18nArrayField;
  image?: string | null;
}

export interface CocktailSearchDocument extends ElasticDocument, Omit<Cocktail, 'preparationSteps' | 'ingredients' | 'equipments'> {
  ingredients: IngredientSearchDocument[];
  equipments: EquipmentSearchDocument[];
}


export type CocktailsSearchSchema = {
  query?: string;
  filters?: {
    categories?: CocktailCategory[];
    ingredients?: string[]; // ingredient IDs
    equipments?: string[]; // equipment IDs
    abvRange?: { min: number; max: number }; // abv percentage range
  },
  pagination?: PaginationParams
};

