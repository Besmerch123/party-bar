# Ingredient Domain

This is the Ingredient domain following Domain-Driven Design (DDD) principles for the Party Bar cocktail recipes app.

## Structure

```
src/ingredient/
├── ingredient.model.ts      # Domain models and DTOs
├── ingredient.repository.ts # Data access layer
├── ingredient.service.ts    # Business logic layer
├── ingredient.functions.ts  # Firebase Cloud Functions (re-exports endpoints)
├── ingredient.test.ts      # Test examples
├── index.ts               # Domain exports
└── endpoints/             # Individual endpoint files
    ├── create-ingredient.ts
    ├── get-ingredient.ts
    ├── get-all-ingredients.ts
    ├── get-ingredients-by-category.ts
    ├── update-ingredient.ts
    ├── delete-ingredient.ts
    ├── get-ingredient-categories.ts
    └── index.ts           # Endpoints exports
```

## Domain Model

The `Ingredient` is the core entity representing a building block for cocktails:

- **ID**: Unique identifier (Firebase document ID)
- **Title**: The name of the ingredient
- **Category**: Type of ingredient (spirit, mixer, garnish, etc.)
- **Timestamps**: Created/updated dates

## Available Categories

```typescript
SPIRIT, LIQUEUR, MIXER, SYRUP, BITTERS, GARNISH, FRUIT, HERB, SPICE, OTHER;
```

## Endpoints Organization

Each Cloud Function is organized in its own file within the `endpoints/` folder:

- **`create-ingredient.ts`** - Creates new ingredients
- **`get-ingredient.ts`** - Retrieves ingredient by ID
- **`get-all-ingredients.ts`** - Lists all ingredients
- **`get-ingredients-by-category.ts`** - Filters ingredients by category
- **`update-ingredient.ts`** - Updates existing ingredients
- **`delete-ingredient.ts`** - Removes ingredients
- **`get-ingredient-categories.ts`** - Returns available categories

This organization provides:

- **Better maintainability** - Each endpoint is self-contained
- **Easier testing** - Individual endpoints can be tested in isolation
- **Clear responsibility** - Each file has a single, clear purpose
- **Scalability** - Easy to add new endpoints without cluttering

## Cloud Functions (API Endpoints)

All functions require user authentication and use Firebase callable functions:

### `createIngredient`

Creates a new ingredient.

```typescript
// Request
{ title: string, category: string }

// Response
{ success: true, data: Ingredient }
```

### `getIngredient`

Retrieves an ingredient by ID.

```typescript
// Request
{ id: string }

// Response
{ success: true, data: Ingredient }
```

### `getAllIngredients`

Retrieves all ingredients ordered by title.

```typescript
// Request
{}

// Response
{ success: true, data: Ingredient[] }
```

### `getIngredientsByCategory`

Retrieves ingredients filtered by category.

```typescript
// Request
{ category: string }

// Response
{ success: true, data: Ingredient[] }
```

### `updateIngredient`

Updates an existing ingredient.

```typescript
// Request
{ id: string, title?: string, category?: string }

// Response
{ success: true, data: Ingredient }
```

### `deleteIngredient`

Deletes an ingredient.

```typescript
// Request
{ id: string }

// Response
{ success: true, message: string }
```

### `getIngredientCategories`

Gets all available ingredient categories.

```typescript
// Request
{}

// Response
{ success: true, data: string[] }
```

## Usage Example

### From Flutter/Dart Client

```dart
import 'package:cloud_functions/cloud_functions.dart';

// Create an ingredient
final result = await FirebaseFunctions.instance
    .httpsCallable('createIngredient')
    .call({
      'title': 'Vodka',
      'category': 'spirit'
    });

// Get all ingredients
final ingredients = await FirebaseFunctions.instance
    .httpsCallable('getAllIngredients')
    .call();
```

### From Web Client

```javascript
import { getFunctions, httpsCallable } from "firebase/functions";

const functions = getFunctions();

// Create an ingredient
const createIngredient = httpsCallable(functions, "createIngredient");
const result = await createIngredient({
  title: "Vodka",
  category: "spirit",
});

// Get all ingredients
const getAllIngredients = httpsCallable(functions, "getAllIngredients");
const ingredients = await getAllIngredients();
```

## Business Rules

1. **Title Validation**: Must be 2-100 characters, unique across all ingredients
2. **Category Validation**: Required string, max 50 characters
3. **Authentication**: All operations require user authentication
4. **Timestamps**: Automatically managed by the system
5. **Case Handling**: Titles are trimmed, categories are lowercased

## Error Handling

All functions return structured errors:

- `unauthenticated`: User must be logged in
- `invalid-argument`: Missing or invalid parameters
- `internal`: Business logic errors (duplicate titles, not found, etc.)

## Future Enhancements

- Add ingredient images/photos
- Support for ingredient alternatives/substitutions
- Ingredient availability/seasonality
- Nutritional information
- Allergen information
- Supplier/brand information
- Price tracking
