import '../../data/cocktail_repository.dart';
import '../../models/models.dart';
import '../../services/order_service.dart';
import '../bar/ran_out_screen.dart';

/// What the Flow 04 ran-out checklist opens with once a party ends.
///
/// Best-effort only: how many drinks were delivered, and per required
/// ingredient how many of those deliveries needed it. A stats query that
/// fails or hangs must never keep the host from moving on, so any failure
/// or timeout returns just the party name — [RanOutScreen] already treats
/// that as "no numbers to show".
Future<RanOutArgs> ranOutArgsFor(Party party) async {
  int? drinksPoured;
  Map<String, int> pourCounts = const {};

  try {
    final tally = await _pourTally(party.id).timeout(const Duration(seconds: 4));
    drinksPoured = tally.$1;
    pourCounts = tally.$2;
  } catch (_) {
    // Network hiccup, a cocktail that failed to load, a slow query — the
    // checklist still opens, just without the "31 drinks poured" flourish.
  }

  return RanOutArgs(
    partyName: party.name,
    drinksPoured: drinksPoured,
    pourCounts: pourCounts,
  );
}

/// Reads the party's orders once (rather than subscribing to the live
/// stream) and counts, per [barKey], how many delivered orders needed that
/// ingredient — the busiest bottles are the ones most likely to actually be
/// empty, which is what the checklist sorts by.
Future<(int?, Map<String, int>)> _pourTally(String partyId) async {
  final orders = await OrderService().streamPartyOrders(partyId).first;
  final delivered = orders
      .where((order) => order.status == OrderStatus.delivered)
      .toList(growable: false);
  if (delivered.isEmpty) return (null, const <String, int>{});

  final cocktailRepo = CocktailRepository();
  final requiredKeysByCocktail = <String, List<String>>{};
  for (final cocktailId in delivered.map((order) => order.cocktailId).toSet()) {
    final cocktail = await cocktailRepo.getCocktail(cocktailId);
    if (cocktail == null) continue;
    requiredKeysByCocktail[cocktailId] = [
      for (final ingredient in cocktail.requiredIngredients)
        barKey(ingredient.slug ?? ingredient.id),
    ];
  }

  final pourCounts = <String, int>{};
  for (final order in delivered) {
    final keys = requiredKeysByCocktail[order.cocktailId];
    if (keys == null) continue;
    for (final key in keys) {
      pourCounts[key] = (pourCounts[key] ?? 0) + 1;
    }
  }

  return (delivered.length, pourCounts);
}
