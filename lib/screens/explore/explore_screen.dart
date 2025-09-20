import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../../utils/app_router.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Cocktail> _filteredCocktails = [];
  String _searchQuery = '';
  CocktailCategory? _selectedCategory;
  CocktailDifficulty? _selectedDifficulty;
  bool _showAlcoholicOnly = false;
  bool _showNonAlcoholicOnly = false;

  @override
  void initState() {
    super.initState();
    _filteredCocktails = MockData.cocktails;
  }

  void _filterCocktails() {
    setState(() {
      _filteredCocktails = MockData.cocktails.where((cocktail) {
        // Search query filter
        bool matchesSearch =
            _searchQuery.isEmpty ||
            cocktail.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            cocktail.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            cocktail.tags.any(
              (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()),
            ) ||
            cocktail.ingredients.any(
              (ingredient) => ingredient.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
            );

        // Category filter
        bool matchesCategory =
            _selectedCategory == null || cocktail.category == _selectedCategory;

        // Difficulty filter
        bool matchesDifficulty =
            _selectedDifficulty == null ||
            cocktail.difficulty == _selectedDifficulty;

        // Alcohol content filter
        bool matchesAlcohol = true;
        if (_showAlcoholicOnly && _showNonAlcoholicOnly) {
          matchesAlcohol = true; // Both selected means show all
        } else if (_showAlcoholicOnly) {
          matchesAlcohol = cocktail.alcoholContent > 0;
        } else if (_showNonAlcoholicOnly) {
          matchesAlcohol = cocktail.alcoholContent == 0;
        }

        return matchesSearch &&
            matchesCategory &&
            matchesDifficulty &&
            matchesAlcohol;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedDifficulty = null;
      _showAlcoholicOnly = false;
      _showNonAlcoholicOnly = false;
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
        ],
      ),
      body: Column(
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
          if (_selectedCategory != null ||
              _selectedDifficulty != null ||
              _showAlcoholicOnly ||
              _showNonAlcoholicOnly)
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
                        if (_selectedDifficulty != null)
                          _buildFilterChip(
                            _getDifficultyDisplayName(_selectedDifficulty!),
                            () => setState(() {
                              _selectedDifficulty = null;
                              _filterCocktails();
                            }),
                          ),
                        if (_showAlcoholicOnly)
                          _buildFilterChip(
                            'Alcoholic',
                            () => setState(() {
                              _showAlcoholicOnly = false;
                              _filterCocktails();
                            }),
                          ),
                        if (_showNonAlcoholicOnly)
                          _buildFilterChip(
                            'Non-Alcoholic',
                            () => setState(() {
                              _showNonAlcoholicOnly = false;
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filteredCocktails.length} cocktails found',
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
            child: _filteredCocktails.isEmpty
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
                    itemCount: _filteredCocktails.length,
                    itemBuilder: (context, index) {
                      return _buildCocktailCard(_filteredCocktails[index]);
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

  Widget _buildCocktailCard(Cocktail cocktail) {
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.cocktailDetails}/${cocktail.id}'),
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getCategoryColor(cocktail.category).withOpacity(0.8),
                    _getCategoryColor(cocktail.category),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.local_bar,
                      size: 40,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${cocktail.prepTimeMinutes}m',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  if (cocktail.isPopular)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: Icon(Icons.star, color: Colors.amber, size: 20),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cocktail.name,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDifficultyBadge(cocktail.difficulty),
                        if (cocktail.alcoholContent > 0)
                          Text(
                            '${cocktail.alcoholContent.toStringAsFixed(0)}% ABV',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          )
                        else
                          Text(
                            'Non-Alcoholic',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                      ],
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

  Widget _buildDifficultyBadge(CocktailDifficulty difficulty) {
    Color color;
    switch (difficulty) {
      case CocktailDifficulty.easy:
        color = Colors.green;
        break;
      case CocktailDifficulty.medium:
        color = Colors.orange;
        break;
      case CocktailDifficulty.hard:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        _getDifficultyDisplayName(difficulty),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getCategoryColor(CocktailCategory category) {
    switch (category) {
      case CocktailCategory.classic:
        return Colors.brown;
      case CocktailCategory.modern:
        return Colors.purple;
      case CocktailCategory.tropical:
        return Colors.orange;
      case CocktailCategory.martini:
        return Colors.blue;
      case CocktailCategory.whiskey:
        return Colors.amber;
      case CocktailCategory.vodka:
        return Colors.cyan;
      case CocktailCategory.rum:
        return Colors.deepOrange;
      case CocktailCategory.gin:
        return Colors.teal;
      case CocktailCategory.shots:
        return Colors.red;
      case CocktailCategory.mocktail:
        return Colors.green;
    }
  }

  String _getCategoryDisplayName(CocktailCategory category) {
    switch (category) {
      case CocktailCategory.classic:
        return 'Classic';
      case CocktailCategory.modern:
        return 'Modern';
      case CocktailCategory.tropical:
        return 'Tropical';
      case CocktailCategory.martini:
        return 'Martini';
      case CocktailCategory.whiskey:
        return 'Whiskey';
      case CocktailCategory.vodka:
        return 'Vodka';
      case CocktailCategory.rum:
        return 'Rum';
      case CocktailCategory.gin:
        return 'Gin';
      case CocktailCategory.shots:
        return 'Shots';
      case CocktailCategory.mocktail:
        return 'Mocktail';
    }
  }

  String _getDifficultyDisplayName(CocktailDifficulty difficulty) {
    switch (difficulty) {
      case CocktailDifficulty.easy:
        return 'Easy';
      case CocktailDifficulty.medium:
        return 'Medium';
      case CocktailDifficulty.hard:
        return 'Hard';
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

                  const SizedBox(height: 24),

                  // Difficulty
                  Text(
                    'Difficulty',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CocktailDifficulty.values.map((difficulty) {
                      final isSelected = _selectedDifficulty == difficulty;
                      return FilterChip(
                        label: Text(_getDifficultyDisplayName(difficulty)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedDifficulty = selected ? difficulty : null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Alcohol Content
                  Text(
                    'Alcohol Content',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Alcoholic cocktails only'),
                    value: _showAlcoholicOnly,
                    onChanged: (value) {
                      setModalState(() {
                        _showAlcoholicOnly = value ?? false;
                        if (_showAlcoholicOnly) _showNonAlcoholicOnly = false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Non-alcoholic cocktails only'),
                    value: _showNonAlcoholicOnly,
                    onChanged: (value) {
                      setModalState(() {
                        _showNonAlcoholicOnly = value ?? false;
                        if (_showNonAlcoholicOnly) _showAlcoholicOnly = false;
                      });
                    },
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
                        _selectedDifficulty = null;
                        _showAlcoholicOnly = false;
                        _showNonAlcoholicOnly = false;
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
