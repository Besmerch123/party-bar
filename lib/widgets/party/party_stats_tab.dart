import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/localization_helper.dart';
import 'party_stats_card.dart';
import 'popular_cocktails_list.dart';

/// A widget that displays the stats tab for a party, showing party overview
/// and popular cocktails.
class PartyStatsTab extends StatelessWidget {
  final Party party;
  final List<CocktailOrder> orders;
  final List<Cocktail> availableCocktails;

  const PartyStatsTab({
    super.key,
    required this.party,
    required this.orders,
    required this.availableCocktails,
  });

  @override
  Widget build(BuildContext context) {
    final totalOrders = orders.length;
    final completedOrders = orders
        .where((o) => o.status == OrderStatus.delivered)
        .length;
    final pendingOrders = orders
        .where((o) => o.status == OrderStatus.pending)
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Party Overview
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.partyOverview,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    PartyStatsCard(
                      label: context.l10n.totalOrders,
                      value: totalOrders.toString(),
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    PartyStatsCard(
                      label: context.l10n.completed,
                      value: completedOrders.toString(),
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    PartyStatsCard(
                      label: context.l10n.pending,
                      value: pendingOrders.toString(),
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    PartyStatsCard(
                      label: context.l10n.activeTime,
                      value: _getActiveTime(),
                      color: Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Popular Cocktails
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.popularCocktails,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                PopularCocktailsList(
                  popularCocktails: _getPopularCocktails(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<MapEntry<String, int>> _getPopularCocktails(BuildContext context) {
    final cocktailCounts = <String, int>{};
    for (final order in orders) {
      Cocktail? cocktail;
      try {
        cocktail = availableCocktails.firstWhere(
          (c) => c.id == order.cocktailId,
        );
      } catch (_) {
        continue;
      }

      final name = cocktail.title.translate(context);
      cocktailCounts[name] = (cocktailCounts[name] ?? 0) + 1;
    }
    final sortedEntries = cocktailCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(3).toList();
  }

  String _getActiveTime() {
    final duration = DateTime.now().difference(party.createdAt);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
