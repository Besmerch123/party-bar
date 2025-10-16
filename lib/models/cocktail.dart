import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared_types.dart';
import './ingredient.dart';
import './equipment.dart';

/// Common cocktail categories for validation
enum CocktailCategory {
  classic,
  signature,
  seasonal,
  frozen,
  mocktail,
  shot,
  long,
  punch,
  tiki,
  highball,
  lowball,
}

class CocktailRelations {
  final List<Ingredient> ingredients;
  final List<Equipment> equipments;

  const CocktailRelations({
    required this.ingredients,
    required this.equipments,
  });
}

/// Cocktail Domain Model (UI/Business Logic Layer)
///
/// Represents a cocktail composed of ingredients and prepared with equipment.
/// This is a clean domain entity with translated strings for the UI layer.
/// Following DDD principles, this is the core entity of the Cocktail domain.
class Cocktail extends CocktailRelations {
  /// Unique identifier (Firebase document ID)
  final String id;

  /// Human-readable name/title of the cocktail (already translated)
  final I18nField title;

  /// Detailed description, preparation notes, history, etc. (already translated)
  final I18nField description;

  /// URL to an image representing the cocktail
  final String image;

  /// Categorization tags to aid discovery
  final List<CocktailCategory> categories;

  final I18nArrayField? preparationSteps;

  const Cocktail({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.categories,
    this.preparationSteps,
    required super.ingredients,
    required super.equipments,
  });

  factory Cocktail.fromDocumentWithRelations(
    DocumentSnapshot<CocktailDocument> doc,
    CocktailRelations relations,
    SupportedLocale locale,
  ) {
    final data = doc.data()!;
    return Cocktail(
      id: doc.id,
      title: data.title,
      description: data.description,
      image: data.image,
      ingredients: relations.ingredients,
      equipments: relations.equipments,
      categories: data.categories,
      preparationSteps: data.preparationSteps,
    );
  }
}

/// Firestore Document representation of a Cocktail
///
/// Uses I18nField for title and description to support multiple languages
/// Timestamps are stored as Firestore Timestamps
class CocktailDocument {
  /// I18n field containing translations for the cocktail title
  final I18nField title;

  /// I18n field containing translations for the cocktail description
  final I18nField description;

  /// URL to an image representing the cocktail
  final String image;

  /// Firestore document paths referencing ingredient records
  final List<String> ingredients;

  /// Firestore document paths referencing equipment records
  final List<String> equipments;

  /// Categorization tags to aid discovery
  final List<CocktailCategory> categories;

  final I18nArrayField? preparationSteps;

  /// Firestore Timestamp when the cocktail was created
  final Timestamp createdAt;

  /// Firestore Timestamp when the cocktail was last updated
  final Timestamp updatedAt;

  const CocktailDocument({
    required this.title,
    required this.description,
    required this.image,
    required this.ingredients,
    required this.equipments,
    required this.categories,
    required this.preparationSteps,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert Firestore document to CocktailDocument
  factory CocktailDocument.fromFirestore(
    DocumentSnapshot<CocktailDocument> doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return CocktailDocument.fromMap(data);
  }

  factory CocktailDocument.fromMap(Map<String, dynamic> map) {
    return CocktailDocument(
      title: Map<String, String>.from(map['title'] ?? {}),
      description: Map<String, String>.from(map['description'] ?? {}),
      image: map['image'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      equipments: List<String>.from(map['equipments'] ?? []),
      categories:
          (map['categories'] as List<dynamic>?)
              ?.map(
                (e) => CocktailCategory.values.firstWhere(
                  (c) => c.name == e,
                  orElse: () => CocktailCategory.classic,
                ),
              )
              .toList() ??
          [],
      preparationSteps: map['preparationSteps'] != null
          ? (map['preparationSteps'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, List<String>.from(value as List)),
            )
          : null,
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
    );
  }
}

/// Extension to convert CocktailDocument to entity with specific locale
/// This allows on-demand translation without re-querying Firestore
extension CocktailDocumentEntity on CocktailDocument {
  /// Convert this document to a Cocktail entity with the given locale
  Cocktail toEntity(String id, SupportedLocale locale) {
    return Cocktail(
      id: id,
      title: title,
      description: description,
      image: image,
      ingredients: [],
      equipments: [],
      categories: categories,
      preparationSteps: preparationSteps,
    );
  }
}

/// Transformer to convert between CocktailDocument and Cocktail entity
/// @deprecated Use CocktailDocumentEntity extension instead for better performance
class CocktailTransformer
    extends FirestoreTransformer<CocktailDocument, Cocktail> {
  @override
  Cocktail fromDocument(
    CocktailDocument document,
    String id,
    SupportedLocale locale,
  ) {
    return document.toEntity(id, locale);
  }

  @override
  CocktailDocument toDocument(Cocktail entity) {
    // When creating/updating, you'd typically provide the I18n fields
    // This is a simplified version
    throw UnimplementedError(
      'Use CreateCocktailDto or UpdateCocktailDto for writes',
    );
  }

  Cocktail fromFirestore(
    DocumentSnapshot<CocktailDocument> doc,
    SupportedLocale locale,
  ) {
    final document = doc.data()!;
    return fromDocument(document, doc.id, locale);
  }

  /// Convert Firestore DocumentSnapshot directly to Cocktail entity
  Cocktail fromFirestoreWithRelations(
    DocumentSnapshot<CocktailDocument> doc,
    CocktailRelations relations,
    SupportedLocale locale,
  ) {
    return Cocktail.fromDocumentWithRelations(doc, relations, locale);
  }
}
