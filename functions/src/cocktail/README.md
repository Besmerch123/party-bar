````markdown
# Cocktail Domain

This is the Cocktail domain following Domain-Driven Design (DDD) principles for the Party Bar cocktail recipes app.

## Structure

```
src/cocktail/
├── cocktail.model.ts       # Domain models and DTOs
├── cocktail.repository.ts  # Data access layer
├── cocktail.service.ts     # Business logic layer
├── cocktail.test.ts        # Test examples
├── index.ts                # Domain exports
└── endpoints/              # Individual endpoint files
    ├── create-cocktail.ts
    ├── get-cocktail.ts
    ├── get-all-cocktails.ts
    ├── get-cocktails-by-category.ts
    ├── update-cocktail.ts
    ├── delete-cocktail.ts
    ├── get-cocktail-categories.ts
    └── index.ts            # Endpoints exports
```

## Domain Model

A `Cocktail` models a completed drink recipe composed from previously defined ingredients and equipment:

- **ID**: Unique identifier (Firebase document ID)
- **Title**: Human-friendly cocktail name
- **Description**: Preparation notes, garnish instructions, story, etc.
- **Ingredients**: Array of Firestore document paths referencing ingredient entities
- **Equipment**: Array of Firestore document paths referencing equipment entities
- **Categories**: Tags to aid discovery (classic, signature, mocktail, ...)
- **Timestamps**: Created/updated dates managed by the system

## Available Categories

```typescript
CLASSIC, SIGNATURE, SEASONAL, FROZEN, MOCKTAIL, SHOT, PUNCH, TIKI, HIGHBALL, LOWBALL;
```

You can extend or trim this list later; validation logic will automatically respect the updated `COCKTAIL_CATEGORIES` constant.

## Endpoints Organization

Each Cloud Function lives in its own file within the `endpoints/` folder:

- **`create-cocktail.ts`** – Creates new cocktails
- **`get-cocktail.ts`** – Retrieves a cocktail by ID
- **`get-all-cocktails.ts`** – Lists all cocktails ordered by title
- **`get-cocktails-by-category.ts`** – Filters cocktails by category
- **`update-cocktail.ts`** – Updates existing cocktail details
- **`delete-cocktail.ts`** – Removes cocktails
- **`get-cocktail-categories.ts`** – Returns available category values

This mirrors the ingredient and equipment domains, keeping the codebase easy to navigate and extend.

## Cloud Functions (API Endpoints)

All functions require user authentication and use Firebase callable functions:

### `createCocktail`

```typescript
// Request
{ title: string, description: string, ingredients: string[], equipments: string[], categories: string[] }

// Response
{ success: true, data: Cocktail }
```

### `getCocktail`

```typescript
// Request
{ id: string }

// Response
{ success: true, data: Cocktail }
```

### `getAllCocktails`

```typescript
// Request
{}

// Response
{ success: true, data: Cocktail[] }
```

### `getCocktailsByCategory`

```typescript
// Request
{ category: string }

// Response
{ success: true, data: Cocktail[] }
```

### `updateCocktail`

```typescript
// Request
{ id: string, title?: string, description?: string, ingredients?: string[], equipments?: string[], categories?: string[] }

// Response
{ success: true, data: Cocktail }
```

### `deleteCocktail`

```typescript
// Request
{ id: string }

// Response
{ success: true, message: string }
```

### `getCocktailCategories`

```typescript
// Request
{}

// Response
{ success: true, data: string[] }
```

## Business Rules

1. **Title Validation** – Required, 2–150 chars, unique per cocktail
2. **Description Validation** – Required, 10–5000 chars
3. **Ingredient References** – Non-empty array of trimmed Firestore document paths
4. **Equipment References** – Non-empty array of trimmed Firestore document paths
5. **Category Validation** – Non-empty array; each value must match `COCKTAIL_CATEGORIES`
6. **Authentication** – All operations require authenticated callers
7. **Timestamps** – Automatically managed on create/update

## Future Enhancements

- Support for cocktail images and glassware metadata
- Difficulty ratings or preparation time estimates
- Variant/seasonal relationships between cocktails
- Public vs private recipe flags
- Batch operations for publishing curated menus

````
