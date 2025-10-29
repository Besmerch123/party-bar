import 'dart:async';
import 'package:flutter/material.dart';
import 'package:party_bar/data/cocktail_repository.dart';
import 'package:party_bar/models/models.dart';
import 'package:party_bar/utils/localization_helper.dart';
import 'package:party_bar/widgets/cocktails/cocktail_categories.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Bottom sheet for adding cocktails to a party
///
/// Features:
/// - Search cocktails by name or ingredient
/// - Multi-select cocktails with visual feedback
/// - Uses Elasticsearch for search
/// - Returns selected cocktails when confirmed
class AddCocktailsBottomSheet extends StatefulWidget {
  /// IDs of cocktails already added to the party (to show as pre-selected)
  final List<String> alreadyAddedCocktailIds;

  const AddCocktailsBottomSheet({
    super.key,
    this.alreadyAddedCocktailIds = const [],
  });

  /// Shows the bottom sheet and returns selected cocktails
  ///
  /// Returns null if user cancels, otherwise returns list of selected cocktails
  static Future<List<Cocktail>?> show(
    BuildContext context, {
    List<String> alreadyAddedCocktailIds = const [],
  }) {
    return showModalBottomSheet<List<Cocktail>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCocktailsBottomSheet(
        alreadyAddedCocktailIds: alreadyAddedCocktailIds,
      ),
    );
  }

  @override
  State<AddCocktailsBottomSheet> createState() =>
      _AddCocktailsBottomSheetState();
}

class _AddCocktailsBottomSheetState extends State<AddCocktailsBottomSheet> {
  final CocktailRepository _repository = CocktailRepository();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  List<Cocktail> _cocktails = [];
  final Set<String> _selectedCocktailIds = {};
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Initialize with already added cocktails as selected
    _selectedCocktailIds.addAll(widget.alreadyAddedCocktailIds);
    _loadCocktails();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCocktails() async {
    setState(() {
      _isLoading = _cocktails.isEmpty; // Only show full loading on initial load
      _isSearching = true;
      _error = null;
    });

    try {
      final result = await _repository.searchCocktails(
        query: _searchQuery.isEmpty ? null : _searchQuery,
      );

      if (mounted) {
        setState(() {
          _cocktails = result.cocktails;
          _isLoading = false;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load cocktails: $e';
          _isLoading = false;
          _isSearching = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();

    setState(() {
      _searchQuery = value;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadCocktails();
    });
  }

  void _toggleCocktailSelection(String cocktailId) {
    setState(() {
      if (_selectedCocktailIds.contains(cocktailId)) {
        _selectedCocktailIds.remove(cocktailId);
      } else {
        _selectedCocktailIds.add(cocktailId);
      }
    });
  }

  void _confirmSelection() {
    final selectedCocktails = _cocktails
        .where((cocktail) => _selectedCocktailIds.contains(cocktail.id))
        .toList();
    Navigator.of(context).pop(selectedCocktails);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.addCocktails,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.l10n.cancel),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: context.l10n.searchCocktailsHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
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

            const SizedBox(height: 8),

            // Selected count
            if (_selectedCocktailIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      context.l10n.cocktailsSelected(
                        _selectedCocktailIds.length,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Cocktails List
            Expanded(child: _buildContent(scrollController)),

            // Confirm Button
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedCocktailIds.isEmpty
                        ? null
                        : _confirmSelection,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _selectedCocktailIds.isEmpty
                          ? context.l10n.selectCocktails
                          : context.l10n.addSelectedCocktails(
                              _selectedCocktailIds.length,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ScrollController scrollController) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
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
              context.l10n.errorLoadingCocktails,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCocktails,
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_cocktails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_bar_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: .5),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noCocktailsFound,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.tryAdjustingFilters,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: .5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _cocktails.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final cocktail = _cocktails[index];
        final isSelected = _selectedCocktailIds.contains(cocktail.id);
        return _CocktailSelectionItem(
          cocktail: cocktail,
          isSelected: isSelected,
          onTap: () => _toggleCocktailSelection(cocktail.id),
        );
      },
    );
  }
}

/// Individual cocktail item in the selection list
class _CocktailSelectionItem extends StatelessWidget {
  final Cocktail cocktail;
  final bool isSelected;
  final VoidCallback onTap;

  const _CocktailSelectionItem({
    required this.cocktail,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: .3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Selection indicator
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : null,
            ),

            // Cocktail Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: cocktail.image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: cocktail.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.local_bar,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.local_bar, color: Colors.grey.shade400),
                    ),
            ),

            const SizedBox(width: 12),

            // Cocktail Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cocktail.title.translate(context),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cocktail.description.translate(context),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (cocktail.categories.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: cocktail.categories.take(2).map((category) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: CocktailCategories.getCategoryColor(
                              category,
                            ).withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            CocktailCategories.getCategoryDisplayName(category),
                            style: TextStyle(
                              fontSize: 11,
                              color: CocktailCategories.getCategoryColor(
                                category,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
