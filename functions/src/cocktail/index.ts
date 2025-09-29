/**
 * Cocktail Domain Index
 *
 * Exports all cocktail-related components for easy importing.
 */

// Models and Types
export * from './cocktail.model';

// Repository
export { CocktailRepository } from './cocktail.repository';

// Service
export { CocktailService } from './cocktail.service';

// Cloud Functions
export * from './endpoints';
