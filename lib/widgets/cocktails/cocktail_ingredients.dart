import 'package:flutter/material.dart';
import 'package:party_bar/widgets/common/image_widget.dart';
import '../../models/ingredient.dart';

class CocktailIngredients extends StatelessWidget {
  final List<Ingredient> ingredients;

  const CocktailIngredients({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ingredients',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: ingredients
                  .map(
                    (ingredient) => _buildIngredientItem(context, ingredient),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(BuildContext context, Ingredient ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ImageWidget(imageUrl: ingredient.image, width: 40, height: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  _getIngredientCategoryName(ingredient.category),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: .6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getIngredientCategoryName(IngredientCategory category) {
    final name = category.name;

    return (name[0].toUpperCase() + name.substring(1));
  }
}
