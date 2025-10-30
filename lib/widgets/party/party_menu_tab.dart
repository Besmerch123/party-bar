import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/localization_helper.dart';
import '../cocktails/cocktail_list_item.dart';

/// A widget that displays the menu tab for a party, showing available cocktails
/// and the number of orders for each.
class PartyMenuTab extends StatelessWidget {
  final List<Cocktail> availableCocktails;
  final List<String> availableCocktailIds;
  final List<CocktailOrder> orders;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const PartyMenuTab({
    super.key,
    required this.availableCocktails,
    required this.availableCocktailIds,
    required this.orders,
    required this.isLoading,
    this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                context.l10n.errorLoadingCocktailsList,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    final filteredCocktails = availableCocktails
        .where((c) => availableCocktailIds.contains(c.id))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          context.l10n.availableCocktails(filteredCocktails.length),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (filteredCocktails.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.local_bar_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.noCocktailsAvailable,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    context.l10n.addCocktailsToMenu,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          )
        else
          ...filteredCocktails.map(
            (cocktail) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: CocktailListItem(cocktail: cocktail),
            ),
          ),
      ],
    );
  }
}
