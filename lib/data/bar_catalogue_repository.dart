import '../models/bar_item.dart';
import 'cocktail_repository.dart';

/// Where the search screen's full catalogue comes from.
///
/// [kShelfStarters] are always on offer — the empty shelf and an offline
/// phone both need *something* to search — but the rest of what a bar can
/// hold lives in Firestore, behind this seam so [BarProvider] never has to
/// reach for it directly and tests never have to reach for Firestore.
abstract class BarCatalogueSource {
  Future<List<BarCatalogueEntry>> load();
}

/// Ingredients and equipment, flattened into one searchable catalogue.
class FirestoreBarCatalogue implements BarCatalogueSource {
  FirestoreBarCatalogue({
    IngredientRepository? ingredients,
    EquipmentRepository? equipment,
  }) : _ingredients = ingredients ?? IngredientRepository(),
       _equipment = equipment ?? EquipmentRepository();

  final IngredientRepository _ingredients;
  final EquipmentRepository _equipment;

  @override
  Future<List<BarCatalogueEntry>> load() async {
    final ingredients = await _ingredients.getAllIngredients();
    final equipment = await _equipment.getAllEquipment();

    return [
      ...ingredients.map(BarCatalogueEntry.fromIngredient),
      ...equipment.map(BarCatalogueEntry.fromEquipment),
    ];
  }
}
