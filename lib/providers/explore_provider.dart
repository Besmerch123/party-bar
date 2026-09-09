import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/cocktail_repository.dart';
import '../models/bar.dart';
import '../models/cocktail.dart';
import '../models/explore.dart';
import '../services/elastic_service.dart';

/// The wire name of the technique "no shaker needed" drops.
const _shakenMethodName = 'shaken';

/// One search state, shared by the feed, the search overlay and the results
/// screen — they are three views of the same query, not three screens.
///
/// Search itself stays on Elastic. The facets the design added (spirit,
/// effort, makeable) are sent along in the payload so the backend can start
/// honouring them, but they are also applied here on the way out: the shelf is
/// a device-side fact, and a filter that only half works is worse than one
/// that works slowly.
class ExploreProvider extends ChangeNotifier {
  ExploreProvider({CocktailRepository? repository})
    : _repository = repository ?? CocktailRepository();

  final CocktailRepository _repository;

  static const _recentKey = 'explore_recent_searches';
  static const _recentLimit = 8;

  /// Deep enough that the client-side facets have something to cut into, and
  /// still one round trip.
  static const _pageSize = 60;

  /// How long to sit on a keystroke before spending a query.
  static const debounce = Duration(milliseconds: 350);

  Timer? _debounceTimer;
  int _requestId = 0;

  String _query = '';
  ExploreFilters _filters = ExploreFilters.empty;
  ExploreSort _sort = ExploreSort.popular;
  bool _sortTouched = false;

  List<Cocktail> _fetched = const [];
  List<Cocktail> _results = const [];
  int _catalogueTotal = 0;
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;

  Set<String> _shelf = const {};
  List<String> _recentSearches = const [];
  List<Cocktail> _popular = const [];

  String get query => _query;
  ExploreFilters get filters => _filters;
  ExploreSort get sort => _sort;

  /// What survived the filters, in display order.
  List<Cocktail> get results => _results;

  /// Everything the query returned before the facets cut into it. Zero-results
  /// answers out of this: the near-misses are drinks the query did match.
  List<Cocktail> get fetched => _fetched;

  /// How large the catalogue is, for "14 of 212 drinks match your shelf".
  int get catalogueTotal => _catalogueTotal;

  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;
  bool get isEmpty => _hasLoaded && !_isLoading && _results.isEmpty;

  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  List<Cocktail> get popular => _popular;

  /// Drinks the shelf can pour, out of what was fetched.
  int get makeableCount => _fetched
      .where((cocktail) => makeabilityOf(cocktail, _shelf).isMakeable)
      .length;

  /// The drinks one bottle away, best bottle first.
  List<NearMiss> get nearMissSuggestions => nearMisses(_fetched, _shelf);

  /// Drinks that survive everything except the makeable filter — the "you can
  /// still pour these" consolation on a zero-results screen.
  List<Cocktail> get pourableFallback => sortCocktails(
    _fetched
        .where((cocktail) => makeabilityOf(cocktail, _shelf).isMakeable)
        .toList(growable: false),
    ExploreSort.popular,
    _shelf,
  );

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList(_recentKey) ?? const [];
    notifyListeners();
  }

  /// Keeps the shelf in step with [BarProvider].
  ///
  /// The shelf changes the ordering and the makeable filter but never the
  /// query, so this re-derives without going back to the network.
  void syncShelf(Set<String> shelf) {
    if (setEquals(_shelf, shelf)) return;

    final wasEmpty = _shelf.isEmpty;
    _shelf = shelf;

    // A first bottle is what makes makeable-first meaningful — adopt it unless
    // the sort has been chosen by hand.
    if (!_sortTouched && wasEmpty != shelf.isEmpty) {
      _sort = defaultSortFor(hasShelf: shelf.isNotEmpty);
    }

    _applyFacets();
    notifyListeners();
  }

  /// Types into the search field. Coalesces keystrokes; [immediate] is for
  /// submitting, tapping a suggestion or restoring a recent search.
  void setQuery(String value, {bool immediate = false}) {
    final trimmed = value.trim();
    if (trimmed == _query && _hasLoaded && immediate) return;

    _query = trimmed;
    notifyListeners();

    _debounceTimer?.cancel();
    if (immediate) {
      unawaited(load());
    } else {
      _debounceTimer = Timer(debounce, () => unawaited(load()));
    }
  }

  void setFilters(ExploreFilters filters) {
    _filters = filters;
    // Only the makeable filter changes what the backend would return; the rest
    // are cuts into a set already in hand.
    _applyFacets();
    notifyListeners();
  }

  void removeFilter(ExploreFilterTag tag) => setFilters(_filters.without(tag));

  void clearFilters() => setFilters(ExploreFilters.empty);

  void setSort(ExploreSort sort) {
    _sortTouched = true;
    _sort = sort;
    _applyFacets();
    notifyListeners();
  }

  /// How many drinks the sheet's "Show N drinks" button would reveal, without
  /// committing to [filters] yet.
  int previewCount(ExploreFilters filters) => _fetched
      .where((cocktail) => filters.allows(cocktail, _shelf))
      .length;

  Future<void> load({bool force = false}) async {
    final requestId = ++_requestId;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (force) await _repository.clearCache();

      final result = await _repository.searchCocktails(
        query: _query.isEmpty ? null : _query,
        filters: _searchFilters(),
        pagination: const PaginationParams(pageSize: _pageSize),
        sort: _sortOrder,
      );

      // A slower earlier query must not overwrite a newer one.
      if (requestId != _requestId) return;

      _fetched = result.cocktails;
      if (_query.isEmpty && _filters.isEmpty) _catalogueTotal = result.total;
      _hasLoaded = true;
      _applyFacets();
    } catch (e) {
      if (requestId != _requestId) return;
      _error = e.toString();
    } finally {
      if (requestId == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// The "popular this week" list on the empty search screen. Fetched once.
  Future<void> loadPopular() async {
    if (_popular.isNotEmpty) return;

    try {
      final result = await _repository.searchCocktails(
        pagination: const PaginationParams(pageSize: 12),
        sort: CocktailSortOrder.popular,
      );
      _popular = sortCocktails(
        result.cocktails,
        ExploreSort.popular,
        _shelf,
      ).take(3).toList(growable: false);
      notifyListeners();
    } catch (_) {
      // The list is a courtesy; a failure here must not take the screen down.
    }
  }

  Future<void> refresh() => load(force: true);

  /// Remembers a query that was actually submitted. Typing alone does not
  /// count — the recent list is things you looked for, not things you almost
  /// looked for.
  Future<void> rememberSearch(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    final next = [trimmed, ..._recentSearches.where((it) => it != trimmed)]
        .take(_recentLimit)
        .toList(growable: false);
    if (listEquals(next, _recentSearches)) return;

    _recentSearches = next;
    notifyListeners();
    await _persistRecent();
  }

  Future<void> removeRecentSearch(String value) async {
    final next = _recentSearches
        .where((it) => it != value)
        .toList(growable: false);
    if (listEquals(next, _recentSearches)) return;

    _recentSearches = next;
    notifyListeners();
    await _persistRecent();
  }

  Future<void> clearRecentSearches() async {
    if (_recentSearches.isEmpty) return;
    _recentSearches = const [];
    notifyListeners();
    await _persistRecent();
  }

  /// The payload sent on. Everything the backend can already answer plus the
  /// facets it will grow into; the shelf rides along even when the makeable
  /// filter is off so a future backend can score makeable-first server side.
  CocktailSearchFilters _searchFilters() {
    return CocktailSearchFilters(
      baseSpirits: _filters.spirits
          .map((spirit) => spirit.name)
          .toList(growable: false),
      excludeMethods: _filters.noShaker
          ? const [_shakenMethodName]
          : const [],
      maxPrepMinutes: _filters.underThreeMinutes ? kQuickPrepMinutes : null,
      maxIngredients: _filters.threeIngredientsMax
          ? kShortIngredientCount
          : null,
      availableIngredients: _shelf.toList(growable: false),
      makeableOnly: _filters.makeableOnly,
    );
  }

  CocktailSortOrder get _sortOrder => switch (_sort) {
    ExploreSort.makeable => CocktailSortOrder.makeable,
    ExploreSort.popular => CocktailSortOrder.popular,
    ExploreSort.seasonal => CocktailSortOrder.seasonal,
  };

  void _applyFacets() {
    _results = sortCocktails(
      _fetched
          .where((cocktail) => _filters.allows(cocktail, _shelf))
          .toList(growable: false),
      _sort,
      _shelf,
    );
  }

  Future<void> _persistRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, _recentSearches);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
