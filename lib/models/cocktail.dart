import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared_types.dart';
import './ingredient.dart';
import './equipment.dart';
import './recipe.dart';

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

  /// Alcohol by volume, 0-100. Null until the catalogue is backfilled.
  final double? abv;

  /// How long the drink takes to make. Drives the "under 3 minutes" filter and
  /// the meta line under a card.
  final int? prepTimeMinutes;

  /// Build technique. What "no shaker needed" actually filters on.
  final CocktailMethod? method;

  /// The bottle the drink is built around.
  final BaseSpirit? baseSpirit;

  /// Editorial taste note, shown beside [method] on the detail screen.
  final FlavorProfile? flavor;

  /// Rolling popularity score. Higher is more popular; null sorts last.
  final int? popularity;

  /// How well the drink fits the season, for the seasonal sort.
  final int? seasonalScore;

  /// Quantities, keyed by ingredient id. See [IngredientMeasure].
  final Map<String, IngredientMeasure> measures;

  /// The guided pour. Empty when the drink has not been broken into steps yet;
  /// "Make it now" then falls back to [preparationSteps].
  final List<PourStep> pourSteps;

  const Cocktail({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.categories,
    this.preparationSteps,
    this.abv,
    this.prepTimeMinutes,
    this.method,
    this.baseSpirit,
    this.flavor,
    this.popularity,
    this.seasonalScore,
    this.measures = const {},
    this.pourSteps = const [],
    required super.ingredients,
    required super.equipments,
  });

  /// The measure for [ingredientId], or null when the recipe does not state one.
  IngredientMeasure? measureFor(String ingredientId) => measures[ingredientId];

  /// Ingredients that actually gate making the drink — garnishes and top-ups
  /// marked optional do not.
  List<Ingredient> get requiredIngredients => ingredients
      .where((ingredient) => measures[ingredient.id]?.optional != true)
      .toList(growable: false);

  factory Cocktail.fromDocumentWithRelations(
    DocumentSnapshot<CocktailDocument> doc,
    CocktailRelations relations,
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
      abv: data.abv,
      prepTimeMinutes: data.prepTimeMinutes,
      method: data.method,
      baseSpirit: data.baseSpirit,
      flavor: data.flavor,
      popularity: data.popularity,
      seasonalScore: data.seasonalScore,
      measures: data.measures,
      pourSteps: data.pourSteps,
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

  /// See [Cocktail.abv].
  final double? abv;

  /// See [Cocktail.prepTimeMinutes].
  final int? prepTimeMinutes;

  /// See [Cocktail.method].
  final CocktailMethod? method;

  /// See [Cocktail.baseSpirit].
  final BaseSpirit? baseSpirit;

  /// See [Cocktail.flavor].
  final FlavorProfile? flavor;

  /// See [Cocktail.popularity].
  final int? popularity;

  /// See [Cocktail.seasonalScore].
  final int? seasonalScore;

  /// See [Cocktail.measures].
  final Map<String, IngredientMeasure> measures;

  /// See [Cocktail.pourSteps].
  final List<PourStep> pourSteps;

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
    this.abv,
    this.prepTimeMinutes,
    this.method,
    this.baseSpirit,
    this.flavor,
    this.popularity,
    this.seasonalScore,
    this.measures = const {},
    this.pourSteps = const [],
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
      abv: (map['abv'] as num?)?.toDouble(),
      prepTimeMinutes: (map['prepTimeMinutes'] as num?)?.toInt(),
      method: enumByName(CocktailMethod.values, map['method']),
      baseSpirit: enumByName(BaseSpirit.values, map['baseSpirit']),
      flavor: enumByName(FlavorProfile.values, map['flavor']),
      popularity: (map['popularity'] as num?)?.toInt(),
      seasonalScore: (map['seasonalScore'] as num?)?.toInt(),
      measures: parseMeasures(map['measures']),
      pourSteps: parsePourSteps(map['pourSteps']),
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
      abv: abv,
      prepTimeMinutes: prepTimeMinutes,
      method: method,
      baseSpirit: baseSpirit,
      flavor: flavor,
      popularity: popularity,
      seasonalScore: seasonalScore,
      measures: measures,
      pourSteps: pourSteps,
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
  ) {
    return Cocktail.fromDocumentWithRelations(doc, relations);
  }
}


/// Reads the `measures` map off a document, tolerating an absent or malformed
/// field — a drink with no stated quantities is still a drink.
Map<String, IngredientMeasure> parseMeasures(Object? raw) {
  if (raw is! Map) return const {};

  final parsed = <String, IngredientMeasure>{};
  raw.forEach((key, value) {
    if (key is String && value is Map) {
      parsed[key] = IngredientMeasure.fromMap(Map<String, dynamic>.from(value));
    }
  });
  return parsed;
}

/// Reads the guided-pour breakdown off a document. Absent for most of the
/// catalogue, which is why every caller has to have a fallback.
List<PourStep> parsePourSteps(Object? raw) {
  if (raw is! List) return const [];

  return raw
      .whereType<Map>()
      .map((step) => PourStep.fromMap(Map<String, dynamic>.from(step)))
      .toList(growable: false);
}
