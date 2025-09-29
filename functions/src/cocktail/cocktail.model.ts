/**
 * Cocktail Domain Model
 * 
 * Represents a cocktail composed of ingredients and prepared with equipment.
 * Following DDD principles, this is the core entity of the Cocktail domain.
 */

export const COCKTAIL_CATEGORIES = {
  CLASSIC: 'classic',
  SIGNATURE: 'signature',
  SEASONAL: 'seasonal',
  FROZEN: 'frozen',
  MOCKTAIL: 'mocktail',
  SHOT: 'shot',
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
  title: string;

  /** Detailed description, preparation notes, history, etc. */
  description: string;

  /** Firestore document paths referencing ingredient records */
  ingredients: string[];

  /** Firestore document paths referencing equipment records */
  equipments: string[];

  /** Categorization tags to aid discovery */
  categories: CocktailCategory[];

  /** Timestamp when the cocktail was created */
  createdAt?: Date;

  /** Timestamp when the cocktail was last updated */
  updatedAt?: Date;
}

export interface CreateCocktailDto {
  title: string;
  description: string;
  ingredients: string[];
  equipments: string[];
  categories: CocktailCategory[];
}

export interface UpdateCocktailDto {
  title?: string;
  description?: string;
  ingredients?: string[];
  equipments?: string[];
  categories?: CocktailCategory[];
}
