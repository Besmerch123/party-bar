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

/**
 * How the drink is put together. Explore surfaces this as the "stirred" /
 * "built" line under a card, and the "no shaker needed" effort filter reads it
 * rather than guessing from the equipment list.
 */
export const COCKTAIL_METHODS = {
  BUILT: 'built',
  STIRRED: 'stirred',
  SHAKEN: 'shaken',
  BLENDED: 'blended',
  LAYERED: 'layered',
} as const;

export type CocktailMethod = typeof COCKTAIL_METHODS[keyof typeof COCKTAIL_METHODS];

/**
 * The bottle a drink is built around. Denormalized from the ingredient list so
 * "browse by spirit" and the base-spirit filter are a single term query.
 */
export const BASE_SPIRITS = {
  GIN: 'gin',
  VODKA: 'vodka',
  RUM: 'rum',
  WHISKY: 'whisky',
  TEQUILA: 'tequila',
  BRANDY: 'brandy',
  ZERO_PROOF: 'zeroProof',
  OTHER: 'other',
} as const;

export type BaseSpirit = typeof BASE_SPIRITS[keyof typeof BASE_SPIRITS];

/**
 * Editorial taste note. Pairs with the method in the detail eyebrow --
 * "CITRUS / SHAKEN".
 */
export const FLAVOR_PROFILES = {
  CITRUS: 'citrus',
  BITTER: 'bitter',
  SWEET: 'sweet',
  HERBAL: 'herbal',
  SPICY: 'spicy',
  FRUITY: 'fruity',
  DRY: 'dry',
  CREAMY: 'creamy',
} as const;

export type FlavorProfile = typeof FLAVOR_PROFILES[keyof typeof FLAVOR_PROFILES];

export const MEASURE_UNITS = {
  ML: 'ml',
  CL: 'cl',
  OZ: 'oz',
  DASH: 'dash',
  BARSPOON: 'barspoon',
  PIECE: 'piece',
  SPLASH: 'splash',
  TOP_UP: 'topUp',
} as const;

export type MeasureUnit = typeof MEASURE_UNITS[keyof typeof MEASURE_UNITS];

/**
 * How much of one ingredient the recipe wants.
 *
 * Kept beside `ingredients` rather than inside it: the ingredient list stays a
 * plain array of references (order, identity, Elastic term queries), and this
 * map -- keyed by ingredient id -- carries the quantity the recipe card shows.
 * An ingredient with no entry here renders without a measure.
 */
export interface IngredientMeasure {
  amount: number;
  unit: MeasureUnit;
  /** Garnishes and top-ups that do not count against "makeable with my bar". */
  optional?: boolean;
}

/**
 * One screen of the hands-busy guided pour.
 *
 * `preparationSteps` stays the readable recipe text; this is the same recipe
 * broken into the units a person actually performs, with the timer the step
 * needs. Cocktails without it fall back to `preparationSteps`.
 */
export interface PourStep {
  /** The instruction itself -- "Shake hard for 12 seconds". */
  title: I18nField;

  /** The detail under it. Optional; many steps do not need one. */
  body?: I18nField;

  /** Runs a countdown on the step when set. */
  durationSeconds?: number | null;
}

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

  /** How long the drink takes to make, in minutes. Drives the "under 3 minutes" filter. */
  prepTimeMinutes?: number | null;

  /** Build technique. Drives the "no shaker needed" filter and the card meta line. */
  method?: CocktailMethod | null;

  /** The bottle the drink is built around, for browse-by-spirit and the spirit filter. */
  baseSpirit?: BaseSpirit | null;

  /** Editorial taste note shown beside the method on the detail screen. */
  flavor?: FlavorProfile | null;

  /**
   * Rolling popularity score used by the "popular" sort and the "popular this
   * week" list on the empty search screen. Higher is more popular.
   */
  popularity?: number | null;

  /**
   * How well the drink fits the current season, for the "seasonal" sort.
   * Populated editorially rather than derived from the date.
   */
  seasonalScore?: number | null;

  /** Quantities, keyed by ingredient id. See {@link IngredientMeasure}. */
  measures?: Record<string, IngredientMeasure>;

  /** Step-by-step preparation instructions */
  preparationSteps: I18nArrayField;

  /** The guided "make it now" breakdown. Falls back to `preparationSteps` when absent. */
  pourSteps?: PourStep[];

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
  prepTimeMinutes?: number | null;
  method?: CocktailMethod | null;
  baseSpirit?: BaseSpirit | null;
  flavor?: FlavorProfile | null;
  popularity?: number | null;
  seasonalScore?: number | null;
  measures?: Record<string, IngredientMeasure>;
  preparationSteps: I18nArrayField;
  pourSteps?: PourStep[];
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
  prepTimeMinutes?: number | null;
  method?: CocktailMethod | null;
  baseSpirit?: BaseSpirit | null;
  flavor?: FlavorProfile | null;
  popularity?: number | null;
  seasonalScore?: number | null;
  measures?: Record<string, IngredientMeasure>;
  preparationSteps?: I18nArrayField;
  pourSteps?: PourStep[];
  image?: string | null;
}

export interface CocktailSearchDocument extends ElasticDocument, Omit<Cocktail, 'preparationSteps' | 'ingredients' | 'equipments'> {
  ingredients: IngredientSearchDocument[];
  equipments: EquipmentSearchDocument[];

  /**
   * Denormalized `ingredients.length`, so the "three ingredients max" filter is
   * a range query rather than a script.
   */
  ingredientCount: number;
}


/**
 * How Explore orders a result set. `relevance` is the Elastic score and is what
 * a text query falls back to; the rest are the three the sort control offers.
 */
export const COCKTAIL_SORTS = {
  RELEVANCE: 'relevance',
  MAKEABLE: 'makeable',
  POPULAR: 'popular',
  SEASONAL: 'seasonal',
} as const;

export type CocktailSort = typeof COCKTAIL_SORTS[keyof typeof COCKTAIL_SORTS];

export type CocktailsSearchSchema = {
  query?: string;
  filters?: {
    categories?: CocktailCategory[];
    ingredients?: string[]; // ingredient IDs
    equipments?: string[]; // equipment IDs
    abvRange?: { min: number; max: number }; // abv percentage range

    /** Base spirits to keep. Empty or absent means every spirit. */
    baseSpirits?: BaseSpirit[];

    /** Build techniques to keep. */
    methods?: CocktailMethod[];

    /** Techniques to drop -- how "no shaker needed" is expressed. */
    excludeMethods?: CocktailMethod[];

    /** Equipment the drink must NOT need. */
    excludeEquipments?: string[]; // equipment IDs

    /** Upper bound on `prepTimeMinutes` -- the "under 3 minutes" filter. */
    maxPrepMinutes?: number;

    /** Upper bound on the ingredient count -- the "three ingredients max" filter. */
    maxIngredients?: number;

    /**
     * The shelf, as ingredient IDs. Sent even when `makeableOnly` is false so
     * the backend can score makeable-first without filtering anything out.
     */
    availableIngredients?: string[];

    /** Keep only drinks every non-optional ingredient of which is on the shelf. */
    makeableOnly?: boolean;
  },
  sort?: CocktailSort,
  pagination?: PaginationParams
};

