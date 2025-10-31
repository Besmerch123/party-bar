import '../data/cocktail_repository.dart';
import '../models/models.dart';
import 'elastic_service.dart';

/// Service class for handling Cocktail-related business logic.
/// Database operations are delegated to CocktailRepository.
class CocktailService {
  final CocktailRepository _repository = CocktailRepository();

  /// Fetch multiple cocktails by their IDs
  /// Returns only the cocktails that were successfully fetched
  /// Uses batch query for optimal performance (no relations loaded)
  Future<List<Cocktail>> getCocktailsByIds(List<String> cocktailIds) async {
    if (cocktailIds.isEmpty) return [];

    try {
      return await _repository.getCocktailsByIds(cocktailIds);
    } catch (e) {
      print('Error fetching cocktails by IDs: $e');
      rethrow;
    }
  }

  /// Fetch a single cocktail by ID
  Future<Cocktail?> getCocktailById(String id) async {
    try {
      return await _repository.getCocktail(id);
    } catch (e) {
      print('Error fetching cocktail by ID: $e');
      rethrow;
    }
  }

  /// Search cocktails using filters
  Future<CocktailSearchResultWithData> searchCocktails({
    String? query,
    CocktailSearchFilters? filters,
    PaginationParams? pagination,
  }) async {
    try {
      return await _repository.searchCocktails(
        query: query,
        filters: filters,
        pagination: pagination,
      );
    } catch (e) {
      print('Error searching cocktails: $e');
      rethrow;
    }
  }

  /// Clear cocktail cache
  Future<void> clearCache() async {
    try {
      await _repository.clearCache();
    } catch (e) {
      print('Error clearing cocktail cache: $e');
      rethrow;
    }
  }
}
