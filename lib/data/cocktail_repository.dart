import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:party_bar/models/models.dart';

/// Repository for managing cocktail data from Firestore
class CocktailRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CocktailTransformer _transformer = CocktailTransformer();

  /// Fetch all cocktail documents (untranslated)
  /// Use this to fetch once and translate on-demand when locale changes
  Future<List<(String id, CocktailDocument doc)>>
  getAllCocktailDocuments() async {
    try {
      final snapshot = await _firestore.collection('cocktails').get();

      return snapshot.docs
          .map((doc) => (doc.id, CocktailDocument.fromFirestore(doc)))
          .toList();
    } catch (e) {
      print('Error fetching cocktail documents: $e');
      return [];
    }
  }

  /// Fetch all cocktails with translation
  /// @deprecated Use getAllCocktailDocuments() and translate on-demand for better performance
  Future<List<Cocktail>> getAllCocktails({
    SupportedLocale locale = SupportedLocale.en,
  }) async {
    try {
      final snapshot = await _firestore.collection('cocktails').get();

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

  /// Stream cocktail documents in real-time (untranslated)
  /// Use this to stream once and translate on-demand when locale changes
  Stream<List<(String id, CocktailDocument doc)>> streamCocktailDocuments() {
    return _firestore
        .collection('cocktails')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => (doc.id, CocktailDocument.fromFirestore(doc)))
              .toList(),
        );
  }

  /// Stream cocktails in real-time with translation
  /// @deprecated Use streamCocktailDocuments() and translate on-demand for better performance
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

  /// Fetch a single cocktail document by ID (untranslated)
  /// Use this to fetch once and translate on-demand when locale changes
  Future<(String id, CocktailDocument doc)?> getCocktailDocument(
    String id,
  ) async {
    try {
      final doc = await _firestore.collection('cocktails').doc(id).get();

      if (!doc.exists) return null;

      return (doc.id, CocktailDocument.fromFirestore(doc));
    } catch (e) {
      print('Error fetching cocktail document: $e');
      return null;
    }
  }

  /// Fetch a single cocktail by ID with translation
  /// @deprecated Use getCocktailDocument() and translate on-demand for better performance
  Future<Cocktail?> getCocktail(
    String id, {
    SupportedLocale locale = SupportedLocale.en,
  }) async {
    try {
      final doc = await _firestore.collection('cocktails').doc(id).get();

      if (!doc.exists) return null;

      return _transformer.fromFirestore(doc, locale);
    } catch (e) {
      print('Error fetching cocktail: $e');
      return null;
    }
  }
}

/// Repository for managing ingredient data from Firestore
class IngredientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final IngredientTransformer _transformer = IngredientTransformer();

  /// Fetch multiple ingredients by their document paths
  Future<List<Ingredient>> getIngredientsByPaths(
    List<String> paths, {
    SupportedLocale locale = SupportedLocale.en,
  }) async {
    try {
      final ingredients = <Ingredient>[];

      for (final path in paths) {
        final id = path.split('/').last;
        final doc = await _firestore.collection('ingredients').doc(id).get();

        if (doc.exists) {
          ingredients.add(_transformer.fromFirestore(doc, locale));
        }
      }

      return ingredients;
    } catch (e) {
      print('Error fetching ingredients by paths: $e');
      return [];
    }
  }
}

/// Repository for managing equipment data from Firestore
class EquipmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EquipmentTransformer _transformer = EquipmentTransformer();

  /// Fetch multiple equipment by their document paths
  Future<List<Equipment>> getEquipmentsByPaths(
    List<String> paths, {
    SupportedLocale locale = SupportedLocale.en,
  }) async {
    try {
      final equipments = <Equipment>[];

      for (final path in paths) {
        final id = path.split('/').last;
        final doc = await _firestore.collection('equipments').doc(id).get();

        if (doc.exists) {
          equipments.add(_transformer.fromFirestore(doc, locale));
        }
      }

      return equipments;
    } catch (e) {
      print('Error fetching equipments by paths: $e');
      return [];
    }
  }
}
