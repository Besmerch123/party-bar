import 'package:cloud_functions/cloud_functions.dart';

/// Service for interacting with Elasticsearch through Firebase Cloud Functions
class ElasticService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Search cocktails using Elasticsearch
  ///
  /// Accepts filter payload and returns list of cocktail IDs that match the search criteria
  ///
  /// [query] - Optional text search query
  /// [filters] - Optional filters for categories, ingredients, equipment, and ABV range
  /// [pagination] - Optional pagination parameters
  ///
  /// Returns a [CocktailSearchResult] containing matched cocktail IDs and pagination metadata
  Future<CocktailSearchResult> searchCocktails({
    String? query,
    CocktailSearchFilters? filters,
    PaginationParams? pagination,
  }) async {
    try {
      // Build the search payload
      final Map<String, dynamic> searchPayload = {};

      if (query != null && query.isNotEmpty) {
        searchPayload['query'] = query;
      }

      if (filters != null) {
        final filtersMap = <String, dynamic>{};

        if (filters.categories != null && filters.categories!.isNotEmpty) {
          filtersMap['categories'] = filters.categories;
        }

        if (filters.ingredients != null && filters.ingredients!.isNotEmpty) {
          filtersMap['ingredients'] = filters.ingredients;
        }

        if (filters.equipments != null && filters.equipments!.isNotEmpty) {
          filtersMap['equipments'] = filters.equipments;
        }

        if (filters.abvRange != null) {
          filtersMap['abvRange'] = {
            'min': filters.abvRange!.min,
            'max': filters.abvRange!.max,
          };
        }

        if (filtersMap.isNotEmpty) {
          searchPayload['filters'] = filtersMap;
        }
      }

      if (pagination != null) {
        searchPayload['pagination'] = {
          'page': pagination.page,
          'pageSize': pagination.pageSize,
        };
      }

      // Call the Firebase Cloud Function
      final callable = _functions.httpsCallable('searchCocktails');
      final result = await callable.call(searchPayload);

      // Parse the response
      final data = result.data as Map<String, dynamic>;

      return CocktailSearchResult.fromJson(data);
    } catch (e) {
      print('Error searching cocktails via Elasticsearch: $e');
      rethrow;
    }
  }
}

/// Search result containing cocktail IDs and pagination metadata
class CocktailSearchResult {
  final List<String> cocktailIds;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const CocktailSearchResult({
    required this.cocktailIds,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory CocktailSearchResult.fromJson(Map<String, dynamic> json) {
    // Extract IDs from items array
    final items = json['items'] as List<dynamic>? ?? [];
    final cocktailIds = items
        .map((item) => (item as Map<String, dynamic>)['id'] as String)
        .toList();

    return CocktailSearchResult(
      cocktailIds: cocktailIds,
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      totalPages: json['totalPages'] as int? ?? 1,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
    );
  }
}

/// Filters for cocktail search
class CocktailSearchFilters {
  final List<String>? categories;
  final List<String>? ingredients; // ingredient IDs
  final List<String>? equipments; // equipment IDs
  final AbvRange? abvRange;

  const CocktailSearchFilters({
    this.categories,
    this.ingredients,
    this.equipments,
    this.abvRange,
  });
}

/// ABV (Alcohol by Volume) range filter
class AbvRange {
  final double min;
  final double max;

  const AbvRange({required this.min, required this.max});
}

/// Pagination parameters
class PaginationParams {
  final int page;
  final int pageSize;

  const PaginationParams({this.page = 1, this.pageSize = 20});
}
