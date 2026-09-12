/// Flow 08 — the night, counted.
///
/// The recap is a page that keeps, not a toast: it has to be computable long
/// after the party ended, from nothing but the party and its orders. So the
/// arithmetic lives here, pure and testable, and the screens only draw it.
library;

import 'order.dart';
import 'order_queue.dart';
import 'party.dart';

/// One drink on the menu and how many of it actually went out.
class DrinkTally {
  const DrinkTally({required this.cocktailId, required this.poured});

  final String cocktailId;
  final int poured;
}

/// The host's night: what it poured, who was there, and what it cost them in
/// waiting. Only *served* drinks count — a cancelled order was never drunk,
/// and a recap that counted it would be flattering the host with a lie.
class PartyRecap {
  const PartyRecap({
    required this.party,
    required this.poured,
    required this.guests,
    required this.recipesUsed,
    required this.averageWait,
    required this.tallies,
    required this.startedAt,
    required this.endedAt,
  });

  factory PartyRecap.of(Party party, Iterable<CocktailOrder> orders) {
    final stats = barNightStatsOf(orders);

    final counts = <String, int>{};
    for (final order in orders.where((o) => o.isDelivered)) {
      counts[order.cocktailId] = (counts[order.cocktailId] ?? 0) + 1;
    }
    final tallies = [
      for (final entry in counts.entries)
        DrinkTally(cocktailId: entry.key, poured: entry.value),
    ]..sort((a, b) {
      final byCount = b.poured.compareTo(a.poured);
      return byCount != 0 ? byCount : a.cocktailId.compareTo(b.cocktailId);
    });

    // A party whose host never tapped "go live" still started somewhere.
    final started = party.wentLiveAt ?? party.createdAt;

    // The last drink out of the bar is a better closing time than "now" for
    // a party nobody ever closed — six hours of silence is not six hours of
    // party. [Party.endedAt] wins wherever it exists.
    final lastTouch = orders
        .map((o) => o.deliveredAt ?? o.readyAt ?? o.createdAt)
        .fold<DateTime?>(
          null,
          (latest, at) => latest == null || at.isAfter(latest) ? at : latest,
        );

    return PartyRecap(
      party: party,
      poured: stats.poured,
      guests: guestCountOf(orders),
      recipesUsed: counts.length,
      averageWait: stats.averageWait,
      tallies: tallies,
      startedAt: started,
      endedAt: party.endedAt ?? lastTouch,
    );
  }

  final Party party;
  final int poured;
  final int guests;

  /// Distinct drinks actually served — "7 recipes used", not "9 on the menu".
  final int recipesUsed;

  /// Sent to on-the-counter, averaged. Null before the first drink lands.
  final Duration? averageWait;

  /// Busiest first.
  final List<DrinkTally> tallies;

  final DateTime startedAt;

  /// Null only for a party still running.
  final DateTime? endedAt;

  /// Nothing was served. The recap still exists — it just has nothing to
  /// chart and says so in words.
  bool get isEmpty => poured == 0;

  int get topPoured => tallies.isEmpty ? 0 : tallies.first.poured;

  /// How long the bar was open, floored at zero for a clock that disagrees
  /// with itself.
  Duration? get openFor {
    final until = endedAt;
    if (until == null) return null;
    final open = until.difference(startedAt);
    return open.isNegative ? Duration.zero : open;
  }

  /// One drink is not a chart. Below two, the tallies read as a list and the
  /// bars are left off rather than drawing a single full-width bar and
  /// calling it a night.
  bool get showsBars => tallies.length > 1;

  /// How wide one drink's bar sits, against the busiest.
  double shareOf(DrinkTally tally) =>
      topPoured == 0 ? 0 : tally.poured / topPoured;
}

/// The guest's own night — three drinks, two of them for someone else.
///
/// Deliberately not the party's numbers: the counts are the host's, and what
/// a guest keeps is only ever theirs.
class GuestRecap {
  const GuestRecap({
    required this.party,
    required this.drinks,
    required this.forFriends,
    required this.hoursThere,
    required this.friends,
    required this.lastDrink,
  });

  factory GuestRecap.of(Party party, Iterable<CocktailOrder> myOrders) {
    final mine = myOrders.toList(growable: false);
    // A cancelled drink was never drunk, so it is not part of the night.
    final had = mine.where((o) => !o.isCancelled).toList(growable: false);

    final friends = <String>[];
    for (final order in had) {
      final name = order.forName?.trim();
      if (name == null || name.isEmpty || friends.contains(name)) continue;
      friends.add(name);
    }

    // The last one out of the bar: served if anything was, otherwise the
    // last thing they asked for.
    final served = oldestFirst(had.where((o) => o.isDelivered));
    final last = served.isNotEmpty
        ? served.last
        : (had.isEmpty ? null : oldestFirst(had).last);

    return GuestRecap(
      party: party,
      drinks: had.length,
      forFriends: had.where((o) => o.isForFriend).length,
      hoursThere: _hoursThere(party, mine),
      friends: friends,
      lastDrink: last,
    );
  }

  final Party party;
  final int drinks;
  final int forFriends;

  /// Rounded down, floored at one: someone who arrived at half past midnight
  /// was still here for the night, and "0H there" says otherwise.
  final int hoursThere;

  /// Who they bought for, in the order they first did.
  final List<String> friends;

  /// The drink the night ends on, or null for a guest who ordered nothing.
  final CocktailOrder? lastDrink;

  static int _hoursThere(Party party, List<CocktailOrder> mine) {
    final arrived = mine.isEmpty
        ? party.wentLiveAt
        : mine.map((o) => o.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
    if (arrived == null) return 1;

    final until = party.endedAt ?? DateTime.now();
    final hours = until.difference(arrived).inHours;
    return hours < 1 ? 1 : hours;
  }
}
