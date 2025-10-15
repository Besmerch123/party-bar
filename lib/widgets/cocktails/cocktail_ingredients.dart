import 'package:flutter/material.dart';
import '../../models/ingredient.dart';

class CocktailIngredients extends StatelessWidget {
  final List<Ingredient> ingredients;

  const CocktailIngredients({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ingredients.isEmpty
            ? SizedBox.shrink()
            : GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  return _buildIngredientItem(context, ingredients[index]);
                },
              ),
      ],
    );
  }

  Widget _buildIngredientItem(BuildContext context, Ingredient ingredient) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 80,
            child: Center(
              child: ingredient.image?.isNotEmpty ?? false
                  ? Image.network(
                      ingredient.image!,
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
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              ingredient.title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
