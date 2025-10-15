import 'package:flutter/material.dart';
import '../../models/cocktail.dart';

class CocktailCategories extends StatelessWidget {
  final List<CocktailCategory> categories;

  const CocktailCategories({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories
              .map(
                (category) => Chip(
                  label: Text(
                    CocktailCategories.getCategoryDisplayName(category),
                  ),
                  avatar: Icon(
                    Icons.local_bar,
                    size: 18,
                    color: _getCategoryColor(category),
                  ),
                  backgroundColor: _getCategoryColor(
                    category,
                  ).withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: _getCategoryColor(category),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  static String getCategoryDisplayName(CocktailCategory category) {
    final name = category.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  Color _getCategoryColor(CocktailCategory category) {
    switch (category) {
      case CocktailCategory.classic:
        return Colors.lightGreen;
      case CocktailCategory.signature:
        return Colors.purple;
      case CocktailCategory.seasonal:
        return Colors.orange;
      case CocktailCategory.frozen:
        return Colors.blue;
      case CocktailCategory.mocktail:
        return Colors.green;
      case CocktailCategory.shot:
        return Colors.red;
      case CocktailCategory.long:
        return Colors.cyan;
      case CocktailCategory.punch:
        return Colors.pink;
      case CocktailCategory.tiki:
        return Colors.deepOrange;
      case CocktailCategory.highball:
        return Colors.teal;
      case CocktailCategory.lowball:
        return Colors.amber;
    }
  }
}
