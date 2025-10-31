import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/models.dart';
import '../../utils/localization_helper.dart';

/// A reusable list item widget for displaying cocktail information
/// with an optional action button or trailing widget.
class CocktailListItem extends StatelessWidget {
  final Cocktail cocktail;
  final VoidCallback? onRemove;
  final Widget? trailing;
  final bool isUpdating;
  final bool showCategories;

  const CocktailListItem({
    super.key,
    required this.cocktail,
    this.onRemove,
    this.trailing,
    this.isUpdating = false,
    this.showCategories = true,
  });

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
                if (showCategories && cocktail.categories.isNotEmpty) ...[
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
          // Trailing widget (either custom or remove button)
          if (trailing != null)
            trailing!
          else if (onRemove != null)
            IconButton(
              onPressed: isUpdating ? null : onRemove,
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.red,
              tooltip: context.l10n.removeCocktail,
            ),
        ],
      ),
    );
  }
}
