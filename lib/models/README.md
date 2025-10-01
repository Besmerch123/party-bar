# Model Architecture: Document/Entity Pattern with I18n

This document explains the architecture pattern used for data models in the PartyBar Flutter app, matching the TypeScript backend structure.

## 🏗️ Architecture Overview

We use a **Document/Entity separation pattern** to handle:
1. **Firestore-specific types** (Timestamp, I18n fields)
2. **Clean domain entities** for UI/business logic
3. **Automatic translation** based on user locale

## 📦 Key Components

### 1. **Shared Types** (`shared_types.dart`)

Core types and utilities used across all models:

```dart
// Supported locales
enum SupportedLocale { en, uk }

// I18n field type
typedef I18nField = Map<String, String>;

// Extension for easy translation
extension I18nFieldExtension on I18nField {
  String translate(SupportedLocale locale) { ... }
}

// Base transformer class
abstract class FirestoreTransformer<TDocument, TEntity> { ... }
```

### 2. **Document Models** (Firestore Layer)

These match the **exact structure** stored in Firestore:

- **`CocktailDocument`** - Firestore representation
  - `title: I18nField` - `{"en": "Mojito", "uk": "Мохіто"}`
  - `description: I18nField` - Multi-language descriptions
  - `createdAt: Timestamp` - Firestore Timestamp type
  - `updatedAt: Timestamp` - Firestore Timestamp type

- **`IngredientDocument`** - Firestore representation
  - `title: I18nField` - `{"en": "Rum", "uk": "Ром"}`
  - `createdAt: Timestamp`
  - `updatedAt: Timestamp`

- **`EquipmentDocument`** - Firestore representation
  - `title: I18nField` - `{"en": "Shaker", "uk": "Шейкер"}`
  - `createdAt: Timestamp`
  - `updatedAt: Timestamp`

### 3. **Domain Entities** (UI/Business Logic Layer)

These are **clean, translated entities** used throughout your app:

- **`Cocktail`** - UI-ready entity
  - `title: String` - Already translated (e.g., "Mojito" or "Мохіто")
  - `description: String` - Already translated
  - `createdAt: DateTime?` - Standard Dart DateTime
  - `updatedAt: DateTime?` - Standard Dart DateTime

- **`Ingredient`** - UI-ready entity
  - `title: String` - Already translated
  - `createdAt: DateTime?`
  - `updatedAt: DateTime?`

- **`Equipment`** - UI-ready entity
  - `title: String` - Already translated
  - `createdAt: DateTime?`
  - `updatedAt: DateTime?`

### 4. **Transformers** (Conversion Layer)

Transformers handle the conversion between Document and Entity:

```dart
class CocktailTransformer {
  // Convert Firestore document → Domain entity
  Cocktail fromDocument(
    CocktailDocument document,
    String id,
    SupportedLocale locale,
  ) {
    return Cocktail(
      id: id,
      title: document.title.translate(locale),     // 🌍 Translation happens here
      description: document.description.translate(locale),
      // ...
    );
  }
  
  // Helper: Convert DocumentSnapshot → Domain entity directly
  Cocktail fromFirestore(DocumentSnapshot doc, SupportedLocale locale) {
    final document = CocktailDocument.fromFirestore(doc);
    return fromDocument(document, doc.id, locale);
  }
}
```

## 🎯 Usage Examples

### Basic Usage

```dart
// 1. Initialize transformer and repository
final transformer = CocktailTransformer();
final firestore = FirebaseFirestore.instance;

// 2. Fetch Firestore document
final doc = await firestore.collection('cocktails').doc('abc123').get();

// 3. Transform to domain entity (English)
final cocktailEN = transformer.fromFirestore(doc, SupportedLocale.en);
print(cocktailEN.title); // "Mojito"

// 4. Transform to domain entity (Ukrainian)
final cocktailUK = transformer.fromFirestore(doc, SupportedLocale.uk);
print(cocktailUK.title); // "Мохіто"
```

### Repository Pattern

```dart
class CocktailRepository {
  final _transformer = CocktailTransformer();
  final _firestore = FirebaseFirestore.instance;

  Future<Cocktail?> getCocktail(String id, {SupportedLocale locale = SupportedLocale.en}) async {
    final doc = await _firestore.collection('cocktails').doc(id).get();
    if (!doc.exists) return null;
    
    return _transformer.fromFirestore(doc, locale);
  }

  Future<List<Cocktail>> getAllCocktails({SupportedLocale locale = SupportedLocale.en}) async {
    final snapshot = await _firestore.collection('cocktails').get();
    
    return snapshot.docs
        .map((doc) => _transformer.fromFirestore(doc, locale))
        .toList();
  }

  Stream<List<Cocktail>> streamCocktails({SupportedLocale locale = SupportedLocale.en}) {
    return _firestore.collection('cocktails').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => _transformer.fromFirestore(doc, locale))
          .toList(),
    );
  }
}
```

### Widget Usage with Provider

```dart
class CocktailListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = SupportedLocale.en; // Or get from LocaleProvider
    final repository = CocktailRepository();

    return FutureBuilder<List<Cocktail>>(
      future: repository.getAllCocktails(locale: locale),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        
        final cocktails = snapshot.data!;
        
        return ListView.builder(
          itemCount: cocktails.length,
          itemBuilder: (context, index) {
            final cocktail = cocktails[index];
            
            // Use translated fields directly!
            return ListTile(
              title: Text(cocktail.title),        // Already translated ✅
              subtitle: Text(cocktail.description), // Already translated ✅
            );
          },
        );
      },
    );
  }
}
```

### Loading Related Entities

```dart
Future<void> loadCocktailWithDetails(String cocktailId, SupportedLocale locale) async {
  // Load cocktail
  final cocktailRepo = CocktailRepository();
  final cocktail = await cocktailRepo.getCocktail(cocktailId, locale: locale);
  
  if (cocktail != null) {
    // Load ingredients by their document paths
    final ingredientRepo = IngredientRepository();
    final ingredients = await ingredientRepo.getIngredientsByPaths(
      cocktail.ingredients,  // ["ingredients/id1", "ingredients/id2"]
      locale: locale,
    );
    
    // Load equipment by their document paths
    final equipmentRepo = EquipmentRepository();
    final equipment = await equipmentRepo.getEquipmentsByPaths(
      cocktail.equipments,  // ["equipments/id1", "equipments/id2"]
      locale: locale,
    );
    
    // All entities are translated and ready to use!
    print('Cocktail: ${cocktail.title}');
    for (final ing in ingredients) {
      print('  - ${ing.title}');  // Translated
    }
    for (final eq in equipment) {
      print('  - ${eq.title}');   // Translated
    }
  }
}
```

## 🔄 Data Flow

```
┌─────────────────┐
│   Firestore     │  Document with I18n fields
│   Database      │  { title: { en: "...", uk: "..." } }
└────────┬────────┘
         │ fetch
         ▼
┌─────────────────┐
│ Document Model  │  CocktailDocument/IngredientDocument
│ (Firebase layer)│  Contains I18nField, Timestamp
└────────┬────────┘
         │ transform with locale
         ▼
┌─────────────────┐
│ Domain Entity   │  Cocktail/Ingredient
│ (UI layer)      │  Contains String (translated), DateTime
└────────┬────────┘
         │ use directly
         ▼
┌─────────────────┐
│   UI Widgets    │  Text(cocktail.title)
│                 │  No translation needed!
└─────────────────┘
```

## ✨ Benefits

1. **Type Safety** - Firestore types (Timestamp) separate from app types (DateTime)
2. **Clean UI Code** - No translation logic in widgets
3. **Single Source of Truth** - Translation happens once at the data layer
4. **Testable** - Easy to mock transformers and test with different locales
5. **Matches Backend** - Same structure as TypeScript backend
6. **Flexible** - Easy to add new locales or change translation strategy

## 🌍 Adding New Locales

1. Add to enum:
```dart
enum SupportedLocale {
  en,
  uk,
  es,  // 👈 Add new locale
}
```

2. Ensure backend includes translations:
```typescript
{
  title: {
    en: "Mojito",
    uk: "Мохіто",
    es: "Mojito"  // 👈 Add in backend
  }
}
```

3. Use in app:
```dart
final cocktail = await repo.getCocktail('id', locale: SupportedLocale.es);
```

## 📝 Notes

- **Document Models** should match your TypeScript `*Document` interfaces exactly
- **Domain Entities** are what you use in your UI code
- **Transformers** handle all conversion and translation logic
- Always pass `locale` parameter when fetching data
- Consider creating a `LocaleProvider` to manage current locale globally
