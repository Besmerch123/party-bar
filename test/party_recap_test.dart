import 'package:flutter_test/flutter_test.dart';

import 'package:party_bar/models/models.dart';

/// Flow 08's arithmetic — what a night is allowed to claim about itself.

final _live = DateTime(2026, 9, 4, 21, 0);
final _closed = DateTime(2026, 9, 5, 1, 24);

Party _party({DateTime? endedAt, List<String> menu = const ['cosmo', 'gt']}) =>
    Party(
      id: 'p',
      name: "Kate's Birthday",
      hostId: 'kate',
      hostName: 'Kate Blake',
      availableCocktailIds: menu,
      joinCode: 'K7QM4P',
      status: endedAt == null ? PartyStatus.active : PartyStatus.ended,
      createdAt: _live.subtract(const Duration(hours: 2)),
      wentLiveAt: _live,
      endedAt: endedAt,
    );

CocktailOrder _order(
  String id, {
  int minute = 0,
  OrderStatus status = OrderStatus.delivered,
  String cocktailId = 'cosmo',
  String guestId = 'sam-phone',
  String guestName = 'Sam',
  String? forName,
  int? readyAfter,
}) {
  final createdAt = _live.add(Duration(minutes: minute));
  return CocktailOrder(
    id: id,
    partyId: 'p',
    cocktailId: cocktailId,
    guestName: guestName,
    guestId: guestId,
    forName: forName,
    status: status,
    createdAt: createdAt,
    readyAt: readyAfter == null
        ? null
        : createdAt.add(Duration(minutes: readyAfter)),
    deliveredAt: status == OrderStatus.delivered
        ? createdAt.add(Duration(minutes: readyAfter ?? 5))
        : null,
  );
}

void main() {
  group('PartyRecap', () {
    test('counts only what was actually served', () {
      final recap = PartyRecap.of(_party(endedAt: _closed), [
        _order('a'),
        _order('b'),
        _order('c', status: OrderStatus.cancelled),
        _order('d', status: OrderStatus.pending),
      ]);

      expect(recap.poured, 2);
      expect(recap.isEmpty, isFalse);
    });

    test('counts people by phone, cancelled drinks included', () {
      // Olha's only drink was cancelled — she was still in the room.
      final recap = PartyRecap.of(_party(endedAt: _closed), [
        _order('a', guestId: 'sam-phone', guestName: 'Sam'),
        _order('b', guestId: 'sam-phone', guestName: 'Sam'),
        _order(
          'c',
          guestId: 'olha-phone',
          guestName: 'Olha',
          status: OrderStatus.cancelled,
        ),
      ]);

      expect(recap.guests, 2);
      expect(recap.poured, 2);
    });

    test('tallies the drinks busiest first, and only the served ones', () {
      final recap = PartyRecap.of(_party(endedAt: _closed), [
        _order('a', cocktailId: 'gt'),
        _order('b', cocktailId: 'cosmo'),
        _order('c', cocktailId: 'cosmo'),
        _order('d', cocktailId: 'orchard', status: OrderStatus.cancelled),
      ]);

      expect(recap.tallies.map((t) => t.cocktailId), ['cosmo', 'gt']);
      expect(recap.tallies.first.poured, 2);
      expect(recap.recipesUsed, 2);
      expect(recap.topPoured, 2);
      expect(recap.shareOf(recap.tallies.last), 0.5);
    });

    test('leaves the bars off a night with one drink on it', () {
      final one = PartyRecap.of(_party(endedAt: _closed), [_order('a')]);
      expect(one.showsBars, isFalse);

      final two = PartyRecap.of(_party(endedAt: _closed), [
        _order('a'),
        _order('b', cocktailId: 'gt'),
      ]);
      expect(two.showsBars, isTrue);
    });

    test('averages the wait from sent to on the counter', () {
      final recap = PartyRecap.of(_party(endedAt: _closed), [
        _order('a', readyAfter: 2),
        _order('b', readyAfter: 6),
      ]);

      expect(recap.averageWait, const Duration(minutes: 4));
    });

    test('has no average wait before the first drink lands', () {
      final recap = PartyRecap.of(_party(), [
        _order('a', status: OrderStatus.pending),
      ]);

      expect(recap.averageWait, isNull);
      expect(recap.isEmpty, isTrue);
    });

    test('closes on the last drink when nobody ever closed the bar', () {
      final recap = PartyRecap.of(_party(), [
        _order('a', minute: 10, readyAfter: 5),
        _order('b', minute: 40, readyAfter: 5),
      ]);

      expect(recap.endedAt, _live.add(const Duration(minutes: 45)));
      expect(recap.openFor, const Duration(minutes: 45));
    });

    test('prefers the stamped end over the last drink', () {
      final recap = PartyRecap.of(_party(endedAt: _closed), [
        _order('a', minute: 10, readyAfter: 5),
      ]);

      expect(recap.endedAt, _closed);
      expect(recap.openFor, const Duration(hours: 4, minutes: 24));
    });

    test('an open party has no ending and no duration', () {
      final recap = PartyRecap.of(_party(), const []);
      expect(recap.endedAt, isNull);
      expect(recap.openFor, isNull);
      expect(recap.guests, 0);
    });
  });

  group('GuestRecap', () {
    test('counts the guest’s own night, cancellations aside', () {
      final recap = GuestRecap.of(_party(endedAt: _closed), [
        _order('a', minute: 10),
        _order('b', minute: 20, forName: 'Marta'),
        _order('c', minute: 30, forName: 'Marta'),
        _order('d', minute: 40, status: OrderStatus.cancelled),
      ]);

      expect(recap.drinks, 3);
      expect(recap.forFriends, 2);
      expect(recap.friends, ['Marta']);
    });

    test('ends on the last drink that was actually served', () {
      final recap = GuestRecap.of(_party(endedAt: _closed), [
        _order('a', minute: 10, cocktailId: 'cosmo'),
        _order('b', minute: 20, cocktailId: 'orchard'),
        _order('c', minute: 30, cocktailId: 'gt', status: OrderStatus.pending),
      ]);

      expect(recap.lastDrink?.cocktailId, 'orchard');
    });

    test('falls back to what they asked for when nothing was served', () {
      final recap = GuestRecap.of(_party(endedAt: _closed), [
        _order('a', minute: 10, cocktailId: 'cosmo', status: OrderStatus.pending),
        _order('b', minute: 20, cocktailId: 'gt', status: OrderStatus.pending),
      ]);

      expect(recap.lastDrink?.cocktailId, 'gt');
    });

    test('hours there are floored at one, never zero', () {
      final recap = GuestRecap.of(
        _party(endedAt: _live.add(const Duration(minutes: 20))),
        [_order('a', minute: 5)],
      );

      expect(recap.hoursThere, 1);
    });

    test('counts from the first drink, not from when the bar opened', () {
      final recap = GuestRecap.of(_party(endedAt: _closed), [
        _order('a', minute: 120),
      ]);

      expect(recap.hoursThere, 2);
    });

    test('a guest who ordered nothing still has a night', () {
      final recap = GuestRecap.of(_party(endedAt: _closed), const []);

      expect(recap.drinks, 0);
      expect(recap.forFriends, 0);
      expect(recap.lastDrink, isNull);
      expect(recap.hoursThere, 4);
    });
  });

  group('guestCountOf', () {
    test('falls back to the name for orders that carry no phone', () {
      final orders = [
        _order('a', guestId: 'sam-phone', guestName: 'Sam'),
        CocktailOrder(
          id: 'b',
          partyId: 'p',
          cocktailId: 'gt',
          guestName: 'Olha',
          createdAt: _live,
        ),
      ];

      expect(guestCountOf(orders), 2);
    });
  });
}
