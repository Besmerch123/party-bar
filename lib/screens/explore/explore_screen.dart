import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../data/cocktail_repository.dart';
import '../../providers/locale_provider.dart';
import '../../utils/app_router.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final CocktailRepository _repository = CocktailRepository();

  List<(String id, CocktailDocument doc)> _allCocktailDocs = [];
  List<(String id, CocktailDocument doc)> _filteredCocktailDocs = [];
  String _searchQuery = '';
  CocktailCategory? _selectedCategory;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCocktails();
  }

  Future<void> _loadCocktails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cocktailDocs = await _repository.getAllCocktailDocuments();

      setState(() {
        _allCocktailDocs = cocktailDocs;
        _filteredCocktailDocs = cocktailDocs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load cocktails: $e';
        _isLoading = false;
      });
    }
  }

  void _filterCocktails() {
    // Get current locale for search filtering
    final locale = context.read<LocaleProvider>().currentLocale;

    setState(() {
      _filteredCocktailDocs = _allCocktailDocs.where((entry) {
        final (id, doc) = entry;
        final cocktail = doc.toEntity(id, locale);

        // Search query filter
        bool matchesSearch =
            _searchQuery.isEmpty ||
            cocktail.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            cocktail.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        // Category filter
        bool matchesCategory =
            _selectedCategory == null ||
            doc.categories.contains(_selectedCategory);

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _searchQuery = '';
    });
    _filterCocktails();
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterCocktails();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search cocktails...',
                      prefixIcon: const Icon(Icons.search),
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
                                  _getCategoryDisplayName(_selectedCategory!),
                                  () => setState(() {
                                    _selectedCategory = null;
                                    _filterCocktails();
                                  }),
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
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_filteredCocktailDocs.length} cocktails found',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),

                // Cocktails Grid
                Expanded(
                  child: _filteredCocktailDocs.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: _filteredCocktailDocs.length,
                          itemBuilder: (context, index) {
                            final (id, doc) = _filteredCocktailDocs[index];
                            final locale = context
                                .watch<LocaleProvider>()
                                .currentLocale;
                            final cocktail = doc.toEntity(id, locale);
                            return _buildCocktailCard(cocktail);
                          },
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
                      cocktail.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cocktail.description,
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
                      _filterCocktails();
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
