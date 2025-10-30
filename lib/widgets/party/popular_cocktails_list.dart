import 'package:flutter/material.dart';
import '../../utils/localization_helper.dart';

/// Widget displaying popular cocktails in a list
class PopularCocktailsList extends StatelessWidget {
  final List<MapEntry<String, int>> popularCocktails;

  const PopularCocktailsList({super.key, required this.popularCocktails});

  @override
  Widget build(BuildContext context) {
    if (popularCocktails.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          context.l10n.noOrdersYet,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      );
    }

    return Column(
      children: popularCocktails
          .map(
            (entry) => _PopularCocktailItem(
              cocktailName: entry.key,
              orderCount: entry.value,
            ),
          )
          .toList(),
    );
  }
}

class _PopularCocktailItem extends StatelessWidget {
  final String cocktailName;
  final int orderCount;

  const _PopularCocktailItem({
    required this.cocktailName,
    required this.orderCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.local_bar, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(child: Text(cocktailName)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$orderCount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
