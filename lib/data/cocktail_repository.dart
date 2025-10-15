import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:party_bar/models/models.dart';

/// Repository for managing cocktail data from Firestore
class CocktailRepository {
  final CocktailTransformer _transformer = CocktailTransformer();

  final CollectionReference<CocktailDocument> _collection = FirebaseFirestore
      .instance
      .collection('cocktails')
      .withConverter<CocktailDocument>(
        fromFirestore: (snapshot, _) =>
            CocktailDocument.fromMap(snapshot.data()!),
        toFirestore: (doc, _) => {}, // Not used for reading
      );

  final IngredientRepository _ingredientRepo = IngredientRepository();
  final EquipmentRepository _equipmentRepo = EquipmentRepository();

  /// Fetch all cocktail documents (untranslated)
  /// Use this to fetch once and translate on-demand when locale changes
  Future<List<(String id, CocktailDocument doc)>>
  getAllCocktailDocuments() async {
    try {
      final snapshot = await _collection.get();

      return snapshot.docs.map((doc) => (doc.id, doc.data())).toList();
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
      final snapshot = await _collection.get();

      return snapshot.docs
          .map((doc) => _transformer.fromFirestore(doc, locale))
          .toList();
    } catch (e) {
      print('Error fetching cocktails: $e');
      return [];
    }
  }

  /// Stream cocktail documents in real-time (untranslated)
  /// Use this to stream once and translate on-demand when locale changes
  Stream<List<(String id, CocktailDocument doc)>> streamCocktailDocuments() {
    return _collection.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => (doc.id, doc.data())).toList(),
    );
  }

  /// Fetch a single cocktail document by ID (untranslated)
  /// Use this to fetch once and translate on-demand when locale changes
  Future<(String id, CocktailDocument doc)?> getCocktailDocument(
    String id,
  ) async {
    try {
      final doc = await _collection.doc(id).get();

      if (!doc.exists) return null;

      return (doc.id, doc.data()!);
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
      final doc = await _collection.doc(id).get();

      if (!doc.exists) return null;

      final docData = doc.data();

      final relations = await _locadCocktailRelations(docData!);

      return _transformer.fromFirestoreWithRelations(doc, relations, locale);
    } catch (e) {
      print('Error fetching cocktail: $e');
      return null;
    }
  }

  Future<CocktailRelations> _locadCocktailRelations(
    CocktailDocument cocktailDoc,
  ) async {
    final ingredients = await _ingredientRepo.getIngredientsByPaths(
      cocktailDoc.ingredients,
    );
    final equipments = await _equipmentRepo.getEquipmentsByPaths(
      cocktailDoc.equipments,
    );

    return CocktailRelations(ingredients: ingredients, equipments: equipments);
  }
}

/// Repository for managing ingredient data from Firestore
class IngredientRepository {
  final CollectionReference<IngredientDocument> _collection = FirebaseFirestore
      .instance
      .collection('ingredients')
      .withConverter<IngredientDocument>(
        fromFirestore: (snapshot, _) =>
            IngredientDocument.fromMap(snapshot.data()!),
        toFirestore: (doc, _) => {}, // Not used for reading
      );
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
        final doc = await _collection.doc(id).get();

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
  final CollectionReference<EquipmentDocument> _collection = FirebaseFirestore
      .instance
      .collection('equipment')
      .withConverter<EquipmentDocument>(
        fromFirestore: (snapshot, _) =>
            EquipmentDocument.fromMap(snapshot.data()!),
        toFirestore: (doc, _) => {}, // Not used for reading
      );
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
        final doc = await _collection.doc(id).get();

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
