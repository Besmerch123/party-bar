import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared_types.dart';

/// Common ingredient categories for validation
enum IngredientCategory {
  spirit,
  liqueur,
  mixer,
  syrup,
  bitters,
  garnish,
  fruit,
  herb,
  spice,
  other,
}

/// Ingredient Domain Model (UI/Business Logic Layer)
///
/// Represents a basic ingredient used in cocktail recipes.
/// This is a clean domain entity with translated strings for the UI layer.
/// Following DDD principles, this is the core entity of the Ingredient domain.
class Ingredient {
  /// Unique identifier (Firebase document ID)
  final String id;

  /// The name/title of the ingredient (already translated)
  final I18nField title;

  /// Category of the ingredient (e.g., "spirit", "mixer", "garnish", "liqueur")
  final IngredientCategory category;

  /// Google Cloud Storage path or URL to the ingredient image
  final String? image;

  const Ingredient({
    required this.id,
    required this.title,
    required this.category,
    this.image,
  });

  Ingredient copyWith({
    String? id,
    I18nField? title,
    IngredientCategory? category,
    String? image,
  }) {
    return Ingredient(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      image: image ?? this.image,
    );
  }
}

/// Firestore Document representation of an Ingredient
///
/// Uses I18nField for title to support multiple languages
/// Timestamps are stored as Firestore Timestamps
class IngredientDocument {
  /// I18n field containing translations for the ingredient title
  final I18nField title;

  /// Category of the ingredient
  final IngredientCategory category;

  /// Google Cloud Storage path or URL to the ingredient image
  final String? image;

  /// Firestore Timestamp when the ingredient was created
  final Timestamp createdAt;

  /// Firestore Timestamp when the ingredient was last updated
  final Timestamp updatedAt;

  const IngredientDocument({
    required this.title,
    required this.category,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert Firestore document to IngredientDocument
  factory IngredientDocument.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IngredientDocument.fromMap(data);
  }

  factory IngredientDocument.fromMap(Map<String, dynamic> map) {
    return IngredientDocument(
      title: Map<String, String>.from(map['title'] ?? {}),
      category: IngredientCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => IngredientCategory.other,
      ),
      image: map['image'],
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
    );
  }
}

/// Transformer to convert between IngredientDocument and Ingredient entity
class IngredientTransformer
    extends FirestoreTransformer<IngredientDocument, Ingredient> {
  @override
  Ingredient fromDocument(
    IngredientDocument document,
    String id,
    SupportedLocale locale,
  ) {
    return Ingredient(
      id: id,
      title: document.title,
      category: document.category,
      image: document.image,
    );
  }

  @override
  IngredientDocument toDocument(Ingredient entity) {
    // When creating/updating, you'd typically provide the I18n fields
    // This is a simplified version
    throw UnimplementedError(
      'Use CreateIngredientDto or UpdateIngredientDto for writes',
    );
  }

  /// Convert Firestore DocumentSnapshot directly to Ingredient entity
  Ingredient fromFirestore(
    DocumentSnapshot<IngredientDocument> doc,
    SupportedLocale locale,
  ) {
    final document = doc.data()!;
    return fromDocument(document, doc.id, locale);
  }
}
