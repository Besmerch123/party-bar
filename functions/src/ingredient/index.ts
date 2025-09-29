/**
 * Ingredient Domain Index
 * 
 * Exports all ingredient-related components for easy importing.
 */

// Models and Types
export * from './ingredient.model';

// Repository
export { IngredientRepository } from './ingredient.repository';

// Service
export { IngredientService } from './ingredient.service';

// Cloud Functions
export * from './ingredient.functions';
