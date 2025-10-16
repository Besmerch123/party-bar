import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../data/cocktail_repository.dart';
import '../../utils/app_router.dart';
import '../../services/elastic_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final CocktailRepository _repository = CocktailRepository();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  List<Cocktail> _cocktails = [];
  String _searchQuery = '';
  CocktailCategory? _selectedCategory;
  bool _isLoading = true;
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCocktails();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Load cocktails using Elasticsearch-powered search
  Future<void> _loadCocktails() async {
    setState(() {
      _isLoading = true;
      _isSearching = true;
      _error = null;
    });

    try {
      // Build filters
      CocktailSearchFilters? filters;
      if (_selectedCategory != null) {
        filters = CocktailSearchFilters(categories: [_selectedCategory!.name]);
      }

      // Search using repository method (Elasticsearch + Firestore hybrid)
      final result = await _repository.searchCocktails(
        query: _searchQuery.isEmpty ? null : _searchQuery,
        filters: filters,
      );

      setState(() {
        _cocktails = result.cocktails;
        _isLoading = false;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load cocktails: $e';
        _isLoading = false;
        _isSearching = false;
      });
    }
  }

  /// Refresh cocktails - keeps previous state if fetch fails
  Future<void> _refreshCocktails() async {
    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      // Build filters
      CocktailSearchFilters? filters;
      if (_selectedCategory != null) {
        filters = CocktailSearchFilters(categories: [_selectedCategory!.name]);
      }

      await _repository.clearCache();
      // Search using repository method (Elasticsearch + Firestore hybrid)
      final result = await _repository.searchCocktails(
        query: _searchQuery.isEmpty ? null : _searchQuery,
        filters: filters,
      );

      setState(() {
        _cocktails = result.cocktails;
        _isSearching = false;
      });
    } catch (e) {
      // Restore previous state on error
      setState(() {
        _isSearching = false;
      });

      // Show snackbar to inform user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Debounced search - waits 1 second after user stops typing
  void _onSearchChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Update search query immediately for UI feedback
    setState(() {
      _searchQuery = value;
    });

    // Set new timer
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      // Perform search after debounce period
      _loadCocktails();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _searchQuery = '';
      _searchController.clear();
    });
    _loadCocktails();
  }

  void _applyFilters() {
    _loadCocktails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Cocktails'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFiltersBottomSheet(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCocktails,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          _error != null
              ? _buildErrorState()
              : Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search cocktails...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),

                    // Active Filters Display
                    if (_selectedCategory != null)
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  if (_selectedCategory != null)
                                    _buildFilterChip(
                                      _getCategoryDisplayName(
                                        _selectedCategory!,
                                      ),
                                      () {
                                        setState(() {
                                          _selectedCategory = null;
                                        });
                                        _loadCocktails();
                                      },
                                    ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _clearFilters,
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                      ),

                    // Results Count
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        '${_cocktails.length} cocktails found',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),

                    // Cocktails Grid
                    Expanded(
                      child: _cocktails.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _refreshCocktails,
                              child: GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.75,
                                    ),
                                itemCount: _cocktails.length,
                                itemBuilder: (context, index) {
                                  final cocktail = _cocktails[index];
                                  return _buildCocktailCard(cocktail);
                                },
                              ),
                            ),
                    ),
                  ],
                ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: .7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [CircularProgressIndicator()],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onRemove,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_bar_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No cocktails found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _clearFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Cocktails',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadCocktails, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildCocktailCard(Cocktail cocktail) {
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.cocktailDetails}/${cocktail.id}'),
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder with category color
            SizedBox(
              height: 120,
              child: Center(
                child: cocktail.image.isNotEmpty
                    ? Image.network(
                        cocktail.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.local_bar,
                        size: 40,
                        color: Colors.white.withValues(alpha: .8),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cocktail.title.translate(context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cocktail.description.translate(context),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Display categories as chips
                    if (cocktail.categories.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: cocktail.categories.take(2).map((category) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(
                                category,
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getCategoryDisplayName(category),
                              style: TextStyle(
                                color: _getCategoryColor(category),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(CocktailCategory category) {
    switch (category) {
      case CocktailCategory.classic:
        return Colors.brown;
      case CocktailCategory.signature:
        return Colors.purple;
      case CocktailCategory.seasonal:
        return Colors.orange;
      case CocktailCategory.frozen:
        return Colors.lightBlue;
      case CocktailCategory.mocktail:
        return Colors.green;
      case CocktailCategory.shot:
        return Colors.red;
      case CocktailCategory.long:
        return Colors.amber;
      case CocktailCategory.punch:
        return Colors.pink;
      case CocktailCategory.tiki:
        return Colors.deepOrange;
      case CocktailCategory.highball:
        return Colors.cyan;
      case CocktailCategory.lowball:
        return Colors.teal;
    }
  }

  String _getCategoryDisplayName(CocktailCategory category) {
    switch (category) {
      case CocktailCategory.classic:
        return 'Classic';
      case CocktailCategory.signature:
        return 'Signature';
      case CocktailCategory.seasonal:
        return 'Seasonal';
      case CocktailCategory.frozen:
        return 'Frozen';
      case CocktailCategory.mocktail:
        return 'Mocktail';
      case CocktailCategory.shot:
        return 'Shot';
      case CocktailCategory.long:
        return 'Long';
      case CocktailCategory.punch:
        return 'Punch';
      case CocktailCategory.tiki:
        return 'Tiki';
      case CocktailCategory.highball:
        return 'Highball';
      case CocktailCategory.lowball:
        return 'Lowball';
    }
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) =>
            _buildFiltersSheet(scrollController),
      ),
    );
  }

  Widget _buildFiltersSheet(ScrollController scrollController) {
    return StatefulBuilder(
      builder: (context, setModalState) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Filter Cocktails',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  // Categories
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CocktailCategory.values.map((category) {
                      final isSelected = _selectedCategory == category;
                      return FilterChip(
                        label: Text(_getCategoryDisplayName(category)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedCategory = selected ? category : null;
                          });
                        },
                        backgroundColor: _getCategoryColor(
                          category,
                        ).withOpacity(0.1),
                        selectedColor: _getCategoryColor(
                          category,
                        ).withOpacity(0.3),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Action buttons
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedCategory = null;
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _applyFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
