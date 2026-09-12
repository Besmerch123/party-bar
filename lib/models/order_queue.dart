/// Flow 06 — everything both phones derive from the same list of orders.
///
/// The order is one object: the guest and the host read the same stream and
/// compute their own view of it here, so "you're #3" on one phone and "#3"
/// in the host's line are the same arithmetic. Pure functions, no Firebase,
/// so the rules can be tested.
library;

import 'cocktail.dart';
import 'order.dart';

int _byAge(CocktailOrder a, CocktailOrder b) {
  final byTime = a.createdAt.compareTo(b.createdAt);
  return byTime != 0 ? byTime : a.id.compareTo(b.id);
}

/// Oldest first — the order the host pours in.
List<CocktailOrder> oldestFirst(Iterable<CocktailOrder> orders) =>
    orders.toList()..sort(_byAge);

/// The line: every order still waiting for pouring to start, oldest first.
List<CocktailOrder> inLine(Iterable<CocktailOrder> orders) =>
    oldestFirst(orders.where((o) => o.isPending));

List<CocktailOrder> pouring(Iterable<CocktailOrder> orders) =>
    oldestFirst(orders.where((o) => o.isPreparing));

/// On the counter, waiting to be handed over — longest-waiting first.
List<CocktailOrder> onTheCounter(Iterable<CocktailOrder> orders) =>
    orders.where((o) => o.isReady).toList()..sort(
      (a, b) => (a.readyAt ?? a.createdAt).compareTo(b.readyAt ?? b.createdAt),
    );

/// "#3 in line". One more than the orders still in line that were sent
/// before this one — so it counts down as the host pours, and a drink the
/// host pulled out of turn keeps the place it jumped from. Null for orders
/// that are past pouring or out of the queue.
int? positionOf(CocktailOrder order, Iterable<CocktailOrder> orders) {
  if (!order.isPending && !order.isPreparing) return null;
  final ahead = orders.where(
    (other) =>
        other.id != order.id && other.isPending && _byAge(other, order) < 0,
  );
  return ahead.length + 1;
}

/// How many orders a new send would queue behind.
int aheadOfNewOrder(Iterable<CocktailOrder> orders) =>
    orders.where((o) => o.isPending).length;

/// The orders this phone sent. Pre-Flow-06 orders carry no guest id and
/// fall back to the name.
List<CocktailOrder> ordersOf(
  Iterable<CocktailOrder> orders, {
  required String guestId,
  String? guestName,
}) => oldestFirst(
  orders.where(
    (o) =>
        o.guestId == guestId ||
        (o.guestId == null && guestName != null && o.guestName == guestName),
  ),
);

/// Orders grouped by round, newest round first. An order with no round id
/// is a round of its own.
List<List<CocktailOrder>> roundsOf(Iterable<CocktailOrder> orders) {
  final byRound = <String, List<CocktailOrder>>{};
  for (final order in oldestFirst(orders)) {
    byRound.putIfAbsent(order.roundId ?? order.id, () => []).add(order);
  }
  final rounds = byRound.values.toList()
    ..sort((a, b) => _byAge(b.first, a.first));
  return rounds;
}

/// Where one drink is, as the guest sees it.
enum GuestStage { inLine, mixing, ready, served, pulled, cancelled }

GuestStage guestStageOf(CocktailOrder order) => switch (order.status) {
  OrderStatus.pending => GuestStage.inLine,
  OrderStatus.preparing => GuestStage.mixing,
  OrderStatus.ready => GuestStage.ready,
  OrderStatus.delivered => GuestStage.served,
  OrderStatus.cancelled =>
    order.wasPulledForStock ? GuestStage.pulled : GuestStage.cancelled,
};

/// The four-segment progress bar: SENT · IN LINE · MIXING · READY. Returns
/// how many segments are lit (2 while in line, 3 mixing, 4 ready).
int progressSegmentsOf(CocktailOrder order) => switch (order.status) {
  OrderStatus.pending => 2,
  OrderStatus.preparing => 3,
  OrderStatus.ready || OrderStatus.delivered => 4,
  OrderStatus.cancelled => 1,
};

/// The round the guest's Tonight tab is about: the newest round that still
/// has something open, or a pulled drink the guest has not dismissed.
List<CocktailOrder>? currentRoundOf(
  Iterable<CocktailOrder> myOrders, {
  Set<String> dismissedPulls = const {},
}) {
  for (final round in roundsOf(myOrders)) {
    final live = round.any(
      (o) => o.isOpen || (o.wasPulledForStock && !dismissedPulls.contains(o.id)),
    );
    if (live) return round;
  }
  return null;
}

/// Fresh orders since [since], grouped by round — what the host's "an
/// order lands" banner announces. Newest round first.
List<List<CocktailOrder>> landedSince(
  Iterable<CocktailOrder> orders,
  DateTime since,
) => roundsOf(
  orders.where((o) => o.isPending && o.createdAt.isAfter(since)),
);

/// The host's night in three numbers.
class BarNightStats {
  const BarNightStats({
    required this.poured,
    required this.averageWait,
    required this.topCocktailId,
  });

  final int poured;

  /// Sent to on-the-counter, across everything served. Null before the first.
  final Duration? averageWait;
  final String? topCocktailId;
}

BarNightStats barNightStatsOf(Iterable<CocktailOrder> orders) {
  final served = orders.where((o) => o.isDelivered).toList();

  final waits = [
    for (final order in served)
      if ((order.readyAt ?? order.deliveredAt) case final done?)
        done.difference(order.createdAt),
  ].where((wait) => !wait.isNegative).toList();

  final counts = <String, int>{};
  for (final order in served) {
    counts[order.cocktailId] = (counts[order.cocktailId] ?? 0) + 1;
  }
  final top = counts.entries.fold<MapEntry<String, int>?>(
    null,
    (best, entry) => best == null || entry.value > best.value ? entry : best,
  );

  return BarNightStats(
    poured: served.length,
    averageWait: waits.isEmpty
        ? null
        : waits.fold<Duration>(Duration.zero, (sum, w) => sum + w) ~/
              waits.length,
    topCocktailId: top?.key,
  );
}

/// How many people were at the bar: distinct phones, falling back to the
/// name for orders older than Flow 06, which carry no guest id. A guest
/// whose only drink was cancelled was still in the room, so nothing is
/// filtered out here.
int guestCountOf(Iterable<CocktailOrder> orders) =>
    orders.map((o) => o.guestId ?? o.guestName).toSet().length;

/// How many of each drink have been ordered tonight, cancellations aside.
Map<String, int> orderedTonight(Iterable<CocktailOrder> orders) {
  final counts = <String, int>{};
  for (final order in orders) {
    if (order.isCancelled) continue;
    counts[order.cocktailId] = (counts[order.cocktailId] ?? 0) + 1;
  }
  return counts;
}

/// Screen 12 — the menu drinks that need [ingredientId].
List<Cocktail> cocktailsNeeding(
  String ingredientId,
  Iterable<Cocktail> menu,
) => menu
    .where((c) => c.ingredients.any((ingredient) => ingredient.id == ingredientId))
    .toList();

/// Screen 13 — up to [limit] drinks to swap a pulled one for: still on the
/// menu, free of the ingredient that ran out, and not the pulled drink.
/// Drinks someone else in the same round is having come first ("what Marta's
/// having"), then the most ordered tonight.
List<Cocktail> swapSuggestionsFor(
  CocktailOrder pulled, {
  required Iterable<Cocktail> menu,
  required Iterable<CocktailOrder> round,
  required Iterable<CocktailOrder> allOrders,
  int limit = 2,
}) {
  final ranOut = pulled.outOfIngredientId;
  final roundmates = {
    for (final order in round)
      if (order.id != pulled.id && !order.isCancelled) order.cocktailId,
  };
  final popularity = orderedTonight(allOrders);

  final candidates = menu
      .where(
        (c) =>
            c.id != pulled.cocktailId &&
            (ranOut == null || !c.ingredients.any((i) => i.id == ranOut)),
      )
      .toList();

  candidates.sort((a, b) {
    final mateA = roundmates.contains(a.id) ? 0 : 1;
    final mateB = roundmates.contains(b.id) ? 0 : 1;
    if (mateA != mateB) return mateA - mateB;
    return (popularity[b.id] ?? 0) - (popularity[a.id] ?? 0);
  });

  return candidates.take(limit).toList();
}
