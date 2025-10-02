import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared_types.dart';

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

/// Cocktail Domain Model (UI/Business Logic Layer)
///
/// Represents a cocktail composed of ingredients and prepared with equipment.
/// This is a clean domain entity with translated strings for the UI layer.
/// Following DDD principles, this is the core entity of the Cocktail domain.
class Cocktail {
  /// Unique identifier (Firebase document ID)
  final String id;

  /// Human-readable name/title of the cocktail (already translated)
  final String title;

  /// Detailed description, preparation notes, history, etc. (already translated)
  final String description;

  /// Firestore document paths referencing ingredient records
  final List<String> ingredients;

  /// Firestore document paths referencing equipment records
  final List<String> equipments;

  /// Categorization tags to aid discovery
  final List<CocktailCategory> categories;

  /// Timestamp when the cocktail was created
  final DateTime? createdAt;

  /// Timestamp when the cocktail was last updated
  final DateTime? updatedAt;

  const Cocktail({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.equipments,
    required this.categories,
    this.createdAt,
    this.updatedAt,
  });

  Cocktail copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? ingredients,
    List<String>? equipments,
    List<CocktailCategory>? categories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cocktail(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      equipments: equipments ?? this.equipments,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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

  /// Firestore document paths referencing ingredient records
  final List<String> ingredients;

  /// Firestore document paths referencing equipment records
  final List<String> equipments;

  /// Categorization tags to aid discovery
  final List<CocktailCategory> categories;

  /// Firestore Timestamp when the cocktail was created
  final Timestamp createdAt;

  /// Firestore Timestamp when the cocktail was last updated
  final Timestamp updatedAt;

  const CocktailDocument({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.equipments,
    required this.categories,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert Firestore document to CocktailDocument
  factory CocktailDocument.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CocktailDocument.fromMap(data);
  }

  factory CocktailDocument.fromMap(Map<String, dynamic> map) {
    return CocktailDocument(
      title: Map<String, String>.from(map['title'] ?? {}),
      description: Map<String, String>.from(map['description'] ?? {}),
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
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'equipments': equipments,
      'categories': categories.map((c) => c.name).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

/// Extension to convert CocktailDocument to entity with specific locale
/// This allows on-demand translation without re-querying Firestore
extension CocktailDocumentEntity on CocktailDocument {
  /// Convert this document to a Cocktail entity with the given locale
  Cocktail toEntity(String id, SupportedLocale locale) {
    return Cocktail(
      id: id,
      title: title.translate(locale),
      description: description.translate(locale),
      ingredients: ingredients,
      equipments: equipments,
      categories: categories,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt.toDate(),
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

  /// Convert Firestore DocumentSnapshot directly to Cocktail entity
  Cocktail fromFirestore(DocumentSnapshot doc, SupportedLocale locale) {
    final document = CocktailDocument.fromFirestore(doc);
    return fromDocument(document, doc.id, locale);
  }
}

/// Data transfer object for creating a new cocktail
/// Excludes ID and timestamps as they are generated by the system
class CreateCocktailDto {
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> equipments;
  final List<CocktailCategory> categories;

  const CreateCocktailDto({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.equipments,
    required this.categories,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'equipments': equipments,
      'categories': categories.map((c) => c.name).toList(),
    };
  }
}

/// Data transfer object for updating an existing cocktail
/// All fields are optional to support partial updates
class UpdateCocktailDto {
  final String? title;
  final String? description;
  final List<String>? ingredients;
  final List<String>? equipments;
  final List<CocktailCategory>? categories;

  const UpdateCocktailDto({
    this.title,
    this.description,
    this.ingredients,
    this.equipments,
    this.categories,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (ingredients != null) map['ingredients'] = ingredients;
    if (equipments != null) map['equipments'] = equipments;
    if (categories != null) {
      map['categories'] = categories!.map((c) => c.name).toList();
    }
    return map;
  }
}
