import 'package:flutter/material.dart';
import 'package:party_bar/models/models.dart';
import 'package:party_bar/utils/localization_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget to display and manage party cocktails list
class PartyCocktailsList extends StatelessWidget {
  final List<String> cocktailIds;
  final List<Cocktail> cocktails;
  final Function(String cocktailId) onRemove;
  final VoidCallback onAddCocktails;
  final bool isLoading;

  const PartyCocktailsList({
    super.key,
    required this.cocktailIds,
    required this.cocktails,
    required this.onRemove,
    required this.onAddCocktails,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_bar,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.partyCocktails,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: isLoading ? null : onAddCocktails,
                  icon: const Icon(Icons.add),
                  label: Text(context.l10n.addCocktails),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (cocktails.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_bar_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.noCocktailsAdded,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cocktails.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final cocktail = cocktails[index];
                  return _CocktailListItem(
                    cocktail: cocktail,
                    onRemove: () => onRemove(cocktail.id),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _CocktailListItem extends StatelessWidget {
  final Cocktail cocktail;
  final VoidCallback onRemove;

  const _CocktailListItem({required this.cocktail, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
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
                      child: Icon(Icons.local_bar, color: Colors.grey.shade400),
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
                      return Chip(
                        label: Text(
                          category.name[0].toUpperCase() +
                              category.name.substring(1),
                          style: const TextStyle(fontSize: 11),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          // Remove Button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle_outline),
            color: Colors.red,
            tooltip: context.l10n.removeCocktail,
          ),
        ],
      ),
    );
  }
}
