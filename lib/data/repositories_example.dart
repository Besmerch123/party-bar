import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:party_bar/models/models.dart';

/// Example usage of the Document/Entity transformer pattern
///
/// This demonstrates how to:
/// 1. Fetch Firestore documents
/// 2. Transform them to domain entities with translated strings
/// 3. Use them in the UI layer

class CocktailRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CocktailTransformer _transformer = CocktailTransformer();

  /// Fetch a single cocktail by ID with translation
  Future<Cocktail?> getCocktail(
    String id, {
    SupportedLocale locale = SupportedLocale.en,
  }) async {
    try {
      final doc = await _firestore.collection('cocktails').doc(id).get();

      if (!doc.exists) return null;

      // Transform Firestore document to domain entity
      return _transformer.fromFirestore(doc, locale);
    } catch (e) {
      print('Error fetching cocktail: $e');
      return null;
    }
  }

  /// Fetch all cocktails with translation
  Future<List<Cocktail>> getAllCocktails({
    SupportedLocale locale = SupportedLocale.en,
  }) async {
    try {
      final snapshot = await _firestore.collection('cocktails').get();

      // Transform all documents to domain entities
      return snapshot.docs
          .map((doc) => _transformer.fromFirestore(doc, locale))
          .toList();
    } catch (e) {
      print('Error fetching cocktails: $e');
      return [];
    }
  }

  /// Fetch cocktails by category with translation
  Future<List<Cocktail>> getCocktailsByCategory(
    CocktailCategory category, {
    SupportedLocale locale = SupportedLocale.en,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('cocktails')
          .where('categories', arrayContains: category.name)
          .get();

      return snapshot.docs
          .map((doc) => _transformer.fromFirestore(doc, locale))
          .toList();
    } catch (e) {
      print('Error fetching cocktails by category: $e');
      return [];
    }
  }

  /// Stream cocktails in real-time with translation
  Stream<List<Cocktail>> streamCocktails({
    SupportedLocale locale = SupportedLocale.en,
  }) {
    return _firestore
        .collection('cocktails')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _transformer.fromFirestore(doc, locale))
              .toList(),
        );
  }
}

class IngredientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final IngredientTransformer _transformer = IngredientTransformer();

  /// Fetch a single ingredient by ID with translation
  Future<Ingredient?> getIngredient(
    String id, {
    SupportedLocale locale = SupportedLocale.en,
  }) async {
    try {
      final doc = await _firestore.collection('ingredients').doc(id).get();

      if (!doc.exists) return null;

      return _transformer.fromFirestore(doc, locale);
    } catch (e) {
      print('Error fetching ingredient: $e');
      return null;
    }
  }

  /// Fetch multiple ingredients by their document paths
  Future<List<Ingredient>> getIngredientsByPaths(
    List<String> paths, {
    SupportedLocale locale = SupportedLocale.en,
  }) async {
    try {
      final ingredients = <Ingredient>[];

      for (final path in paths) {
        // Extract ID from path like "ingredients/abc123"
        final id = path.split('/').last;
        final ingredient = await getIngredient(id, locale: locale);
        if (ingredient != null) {
          ingredients.add(ingredient);
        }
      }

      return ingredients;
    } catch (e) {
      print('Error fetching ingredients by paths: $e');
      return [];
    }
  }

  /// Fetch all ingredients with translation
  Future<List<Ingredient>> getAllIngredients({
    SupportedLocale locale = SupportedLocale.en,
  }) async {
    try {
      final snapshot = await _firestore.collection('ingredients').get();

      return snapshot.docs
          .map((doc) => _transformer.fromFirestore(doc, locale))
          .toList();
    } catch (e) {
      print('Error fetching ingredients: $e');
      return [];
    }
  }
}

class EquipmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EquipmentTransformer _transformer = EquipmentTransformer();

  /// Fetch a single equipment by ID with translation
  Future<Equipment?> getEquipment(
    String id, {
    SupportedLocale locale = SupportedLocale.en,
  }) async {
    try {
      final doc = await _firestore.collection('equipments').doc(id).get();

      if (!doc.exists) return null;

      return _transformer.fromFirestore(doc, locale);
    } catch (e) {
      print('Error fetching equipment: $e');
      return null;
    }
  }

  /// Fetch multiple equipment by their document paths
  Future<List<Equipment>> getEquipmentsByPaths(
    List<String> paths, {
    SupportedLocale locale = SupportedLocale.en,
  }) async {
    try {
      final equipments = <Equipment>[];

      for (final path in paths) {
        // Extract ID from path like "equipments/abc123"
        final id = path.split('/').last;
        final equipment = await getEquipment(id, locale: locale);
        if (equipment != null) {
          equipments.add(equipment);
        }
      }

      return equipments;
    } catch (e) {
      print('Error fetching equipments by paths: $e');
      return [];
    }
  }
}

/// Example widget usage
/// 
/// ```dart
/// class CocktailDetailScreen extends StatelessWidget {
///   final String cocktailId;
///   final SupportedLocale locale;
///   
///   Future<void> loadCocktail() async {
///     final repo = CocktailRepository();
///     final cocktail = await repo.getCocktail(cocktailId, locale: locale);
///     
///     if (cocktail != null) {
///       // Use translated fields directly
///       print(cocktail.title);        // Already translated!
///       print(cocktail.description);  // Already translated!
///       
///       // Load related ingredients
///       final ingredientRepo = IngredientRepository();
///       final ingredients = await ingredientRepo.getIngredientsByPaths(
///         cocktail.ingredients,
///         locale: locale,
///       );
///       
///       // Load related equipment
///       final equipmentRepo = EquipmentRepository();
///       final equipment = await equipmentRepo.getEquipmentsByPaths(
///         cocktail.equipments,
///         locale: locale,
///       );
///     }
///   }
/// }
/// ```
