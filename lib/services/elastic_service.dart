import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:party_bar/models/cocktail.dart';
import 'package:party_bar/models/ingredient.dart';
import 'package:party_bar/models/equipment.dart';
import 'package:party_bar/models/shared_types.dart';

/// Service for interacting with Elasticsearch through Firebase Cloud Functions
class ElasticService {
  final FirebaseFunctions _functions;
  final Duration cacheDuration;
  late final Box<String> _cacheBox;
  bool _initialized = false;

  ElasticService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance,
      cacheDuration = const Duration(hours: 12);

  /// Initialize the cache store (call this once during app startup)
  Future<void> initialize() async {
    if (_initialized) return;

    final cacheDir = await getApplicationDocumentsDirectory();
    Hive.init('${cacheDir.path}/elastic_cache');

    _cacheBox = await Hive.openBox<String>('elastic_search_cache');
    _initialized = true;
  }

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
    // Ensure the service is initialized
    if (!_initialized) {
      await initialize();
    }

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

      // Generate cache key based on the payload (excluding locale since it's not in the payload)
      final cacheKey = _generateCacheKey(searchPayload);

      // Try to get from cache first
      final cachedData = _getCachedResult(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }

      // Cache miss - call Firebase Cloud Function
      final callable = _functions.httpsCallable('searchCocktails');
      final result = await callable.call(searchPayload);

      // Parse the response - Firebase returns Object? types, need to convert properly
      final data = Map<String, dynamic>.from(result.data as Map);
      final searchResult = CocktailSearchResult.fromJson(data);

      // Store in cache for future requests
      _cacheResult(cacheKey, searchResult);

      return searchResult;
    } catch (e) {
      print('Error searching cocktails via Elasticsearch: $e');
      rethrow;
    }
  }

  /// Generate a consistent cache key from the search payload
  String _generateCacheKey(Map<String, dynamic> payload) {
    // Sort the payload to ensure consistent keys for the same parameters
    final sortedPayload = _sortMapRecursively(payload);
    return jsonEncode(sortedPayload);
  }

  /// Recursively sort map entries to ensure consistent JSON encoding
  Map<String, dynamic> _sortMapRecursively(Map<String, dynamic> map) {
    final sortedMap = <String, dynamic>{};
    final sortedKeys = map.keys.toList()..sort();

    for (final key in sortedKeys) {
      final value = map[key];
      if (value is Map<String, dynamic>) {
        sortedMap[key] = _sortMapRecursively(value);
      } else {
        sortedMap[key] = value;
      }
    }

    return sortedMap;
  }

  /// Get cached result if available and not expired
  CocktailSearchResult? _getCachedResult(String cacheKey) {
    final cachedJson = _cacheBox.get(cacheKey);
    if (cachedJson == null) return null;

    try {
      final cached = jsonDecode(cachedJson) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cached['timestamp'] as String);

      // Check if cache is expired
      if (DateTime.now().difference(timestamp) > cacheDuration) {
        _cacheBox.delete(cacheKey);
        return null;
      }

      return CocktailSearchResult.fromJson(
        cached['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      // If there's any error parsing cache, delete it
      _cacheBox.delete(cacheKey);
      return null;
    }
  }

  /// Cache the search result
  void _cacheResult(String cacheKey, CocktailSearchResult result) {
    try {
      final cacheData = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': {
          'items': result.cocktails
              .map((cocktail) => _serializeCocktail(cocktail))
              .toList(),
          'total': result.total,
          'page': result.page,
          'pageSize': result.pageSize,
          'totalPages': result.totalPages,
          'hasNextPage': result.hasNextPage,
          'hasPreviousPage': result.hasPreviousPage,
        },
      };

      _cacheBox.put(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      print('Error caching search result: $e');
      // Don't throw - caching failure shouldn't break the app
    }
  }

  /// Serialize a Cocktail object for caching
  Map<String, dynamic> _serializeCocktail(Cocktail cocktail) {
    return {
      'id': cocktail.id,
      'title': cocktail.title,
      'description': cocktail.description,
      'image': cocktail.image,
      'categories': cocktail.categories.map((c) => c.name).toList(),
      'preparationSteps': cocktail.preparationSteps,
      'ingredients': cocktail.ingredients
          .map(
            (ingredient) => {
              'id': ingredient.id,
              'title': ingredient.title,
              'category': ingredient.category.name,
              'image': ingredient.image,
            },
          )
          .toList(),
      'equipments': cocktail.equipments
          .map(
            (equipment) => {
              'id': equipment.id,
              'title': equipment.title,
              'image': equipment.image,
            },
          )
          .toList(),
    };
  }

  /// Clear the cache manually if needed
  Future<void> clearCache() async {
    if (!_initialized) return;

    await _cacheBox.clear();
  }
}

/// Search result containing cocktails and pagination metadata
class CocktailSearchResult {
  final List<Cocktail> cocktails;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const CocktailSearchResult({
    required this.cocktails,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory CocktailSearchResult.fromJson(Map<String, dynamic> json) {
    // Extract cocktail objects from items array
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final cocktails = itemsList.map((item) {
      // Handle Firebase's Object? type conversion
      final itemMap = Map<String, dynamic>.from(item as Map);
      return _parseCocktailFromElastic(itemMap);
    }).toList();

    return CocktailSearchResult(
      cocktails: cocktails,
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
    );
  }

  /// Parse a Cocktail object from Elasticsearch result
  static Cocktail _parseCocktailFromElastic(Map<String, dynamic> data) {
    // Parse ingredients
    final ingredientsList = data['ingredients'] as List<dynamic>? ?? [];
    final ingredients = ingredientsList.map((item) {
      final ingredientMap = Map<String, dynamic>.from(item as Map);
      return Ingredient(
        id: ingredientMap['id'] as String,
        title: Map<String, String>.from(ingredientMap['title'] as Map? ?? {}),
        category: IngredientCategory.values.firstWhere(
          (e) => e.name == ingredientMap['category'],
          orElse: () => IngredientCategory.other,
        ),
        image: ingredientMap['image'] as String?,
      );
    }).toList();

    // Parse equipments
    final equipmentsList = data['equipments'] as List<dynamic>? ?? [];
    final equipments = equipmentsList.map((item) {
      final equipmentMap = Map<String, dynamic>.from(item as Map);
      return Equipment(
        id: equipmentMap['id'] as String,
        title: Map<String, String>.from(equipmentMap['title'] as Map? ?? {}),
        image: equipmentMap['image'] as String?,
      );
    }).toList();

    // Parse categories
    final categoriesList = data['categories'] as List<dynamic>? ?? [];
    final categories = categoriesList.map((cat) {
      return CocktailCategory.values.firstWhere(
        (c) => c.name == cat,
        orElse: () => CocktailCategory.classic,
      );
    }).toList();

    // Parse preparation steps if present
    I18nArrayField? preparationSteps;
    if (data['preparationSteps'] != null) {
      preparationSteps = (data['preparationSteps'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, List<String>.from(value as List)),
      );
    }

    return Cocktail(
      id: data['id'] as String,
      title: Map<String, String>.from(data['title'] as Map? ?? {}),
      description: Map<String, String>.from(data['description'] as Map? ?? {}),
      image: data['image'] as String? ?? '',
      categories: categories,
      preparationSteps: preparationSteps,
      ingredients: ingredients,
      equipments: equipments,
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
