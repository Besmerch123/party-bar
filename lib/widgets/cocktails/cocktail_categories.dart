import 'package:flutter/material.dart';
import 'package:party_bar/utils/localization_helper.dart';
import '../../models/cocktail.dart';
import '../../theme/theme.dart';
import '../common/app_chip.dart';

class CocktailCategories extends StatelessWidget {
  final List<CocktailCategory> categories;

  const CocktailCategories({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.categories, style: AppTypography.section),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories
              .map(
                (category) => TagChip(
                  label: CocktailCategories.getCategoryDisplayName(category),
                  icon: CocktailCategories.getCategoryIcon(category),
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

  static IconData getCategoryIcon(CocktailCategory category) {
    switch (category) {
      case CocktailCategory.classic:
        return Icons.history;
      case CocktailCategory.signature:
        return Icons.auto_awesome;
      case CocktailCategory.seasonal:
        return Icons.wb_sunny;
      case CocktailCategory.frozen:
        return Icons.ac_unit;
      case CocktailCategory.mocktail:
        return Icons.eco;
      case CocktailCategory.shot:
        return Icons.flash_on;
      case CocktailCategory.long:
        return Icons.height;
      case CocktailCategory.punch:
        return Icons.celebration;
      case CocktailCategory.tiki:
        return Icons.sailing;
      case CocktailCategory.highball:
        return Icons.wine_bar;
      case CocktailCategory.lowball:
        return Icons.local_bar;
    }
  }
}
