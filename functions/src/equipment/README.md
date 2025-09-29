# Equipment Domain

This is the Equipment domain following Domain-Driven Design (DDD) principles for the Party Bar cocktail recipes app.

## Structure

```
src/equipment/
├── equipment.model.ts       # Domain models and DTOs
├── equipment.repository.ts  # Data access layer
├── equipment.service.ts     # Business logic layer
├── equipment.functions.ts   # Firebase Cloud Functions (re-exports endpoints)
├── equipment.test.ts       # Test examples
├── index.ts               # Domain exports
└── endpoints/             # Individual endpoint files
    ├── create-equipment.ts
    ├── get-equipment.ts
    ├── get-all-equipment.ts
    ├── update-equipment.ts
    ├── delete-equipment.ts
    └── index.ts           # Endpoints exports
```

## Domain Model

The `Equipment` is the core entity representing tools and equipment needed for cocktail preparation:

- **ID**: Unique identifier (Firebase document ID)
- **Title**: The name of the equipment
- **Image**: Optional Google Cloud Storage path or public URL
- **Timestamps**: Created/updated dates

## Endpoints Organization

Each endpoint is in its own file for better maintainability and follows a consistent pattern:

- Authentication check
- Input validation  
- Business logic delegation to service
- Standardized response format
- Error handling with proper HTTP status codes

## Cloud Functions (API Endpoints)

### `createEquipment`

Creates a new equipment.

```typescript
// Request
{ title: string }

// Response
{ success: true, data: Equipment }
```

### `getEquipment`

Retrieves an equipment by ID.

```typescript
// Request
{ id: string }

// Response
{ success: true, data: Equipment }
```

### `getAllEquipment`

Retrieves all equipment ordered by title.

```typescript
// Request
{}

// Response
{ success: true, data: Equipment[] }
```

### `updateEquipment`

Updates an existing equipment.

```typescript
// Request
{ id: string, title?: string }

// Response
{ success: true, data: Equipment }
```

### `deleteEquipment`

Deletes an equipment by ID.

```typescript
// Request
{ id: string }

// Response
{ success: true, message: string }
```

## Usage Example

### From Flutter/Dart Client

```dart
import 'package:cloud_functions/cloud_functions.dart';

// Create equipment
final result = await FirebaseFunctions.instance
    .httpsCallable('createEquipment')
    .call({
      'title': 'Boston Shaker'
    });

// Get all equipment
final equipment = await FirebaseFunctions.instance
    .httpsCallable('getAllEquipment')
    .call();
```

### From Web Client

```javascript
import { getFunctions, httpsCallable } from "firebase/functions";

const functions = getFunctions();

// Create equipment
const createEquipment = httpsCallable(functions, "createEquipment");
const result = await createEquipment({
  title: "Boston Shaker",
});

// Get all equipment
const getAllEquipment = httpsCallable(functions, "getAllEquipment");
const equipment = await getAllEquipment();
```

## Business Rules

1. **Title Validation**: Must be 2-100 characters, unique across all equipment
2. **Authentication**: All operations require user authentication
3. **Timestamps**: Automatically managed by the system
4. **Case Handling**: Titles are trimmed for consistency

## Error Handling

All functions return structured errors:

- `unauthenticated`: User must be logged in
- `invalid-argument`: Missing or invalid parameters
- `internal`: Business logic errors (duplicate titles, not found, etc.)

## Future Enhancements

- Support for equipment descriptions
- Equipment categories or types
- Equipment availability status
- Equipment rental/ownership tracking
- Equipment maintenance schedules
- Equipment alternatives/substitutions
