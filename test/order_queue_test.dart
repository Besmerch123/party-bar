import 'package:flutter_test/flutter_test.dart';

import 'package:party_bar/models/models.dart';

/// Flow 06's arithmetic — the numbers both phones must agree on.

final _t0 = DateTime(2026, 9, 12, 22, 30);

CocktailOrder _order(
  String id, {
  int minute = 0,
  OrderStatus status = OrderStatus.pending,
  String cocktailId = 'gt',
  String guestId = 'sam-phone',
  String guestName = 'Sam',
  String? roundId,
  CancelReason? cancelReason,
  String? outOf,
  DateTime? readyAt,
}) => CocktailOrder(
  id: id,
  partyId: 'p',
  cocktailId: cocktailId,
  guestName: guestName,
  guestId: guestId,
  status: status,
  createdAt: _t0.add(Duration(minutes: minute)),
  roundId: roundId,
  cancelReason: cancelReason,
  outOfIngredientId: outOf,
  readyAt: readyAt,
);

Ingredient _ingredient(String id) =>
    Ingredient(id: id, title: {'en': id}, category: IngredientCategory.spirit);

Cocktail _cocktail(String id, List<String> ingredients) => Cocktail(
  id: id,
  title: {'en': id},
  description: const {'en': ''},
  image: '',
  categories: const [],
  ingredients: ingredients.map(_ingredient).toList(),
  equipments: const [],
);

void main() {
  group('position in line', () {
    test('counts the orders still in line that were sent earlier', () {
      final orders = [
        _order('a', minute: 0),
        _order('b', minute: 1),
        _order('c', minute: 2),
      ];
      expect(positionOf(orders[0], orders), 1);
      expect(positionOf(orders[2], orders), 3);
    });

    test('moves up as the host starts pouring the ones ahead', () {
      final orders = [
        _order('a', minute: 0, status: OrderStatus.preparing),
        _order('b', minute: 1, status: OrderStatus.ready),
        _order('c', minute: 2),
      ];
      expect(positionOf(orders[2], orders), 1);
    });

    test('a drink pulled out of turn keeps the place it jumped from', () {
      final orders = [
        _order('a', minute: 0),
        _order('b', minute: 1),
        _order('c', minute: 2, status: OrderStatus.preparing),
      ];
      expect(positionOf(orders[2], orders), 3);
    });

    test('has no position once it is on the counter or out', () {
      final ready = _order('a', status: OrderStatus.ready);
      final gone = _order('b', status: OrderStatus.cancelled);
      expect(positionOf(ready, [ready, gone]), isNull);
      expect(positionOf(gone, [ready, gone]), isNull);
    });

    test('ties on the same instant break by id, identically everywhere', () {
      final orders = [_order('b'), _order('a')];
      expect(inLine(orders).map((o) => o.id), ['a', 'b']);
      expect(positionOf(orders[0], orders), 2);
    });

    test('a new send queues behind everything still in line', () {
      final orders = [
        _order('a'),
        _order('b', minute: 1),
        _order('c', minute: 2, status: OrderStatus.preparing),
      ];
      expect(aheadOfNewOrder(orders), 2);
    });
  });

  group('the guest\'s own orders', () {
    test('match by phone, and by name for orders older than Flow 06', () {
      final orders = [
        _order('mine', guestId: 'sam-phone'),
        _order('legacy', guestId: '', guestName: 'Sam'),
        CocktailOrder(
          id: 'old',
          partyId: 'p',
          cocktailId: 'gt',
          guestName: 'Sam',
          createdAt: _t0,
        ),
        _order('theirs', guestId: 'leo-phone', guestName: 'Leo'),
      ];
      final mine = ordersOf(orders, guestId: 'sam-phone', guestName: 'Sam');
      expect(mine.map((o) => o.id), containsAll(['mine', 'old']));
      expect(mine.map((o) => o.id), isNot(contains('theirs')));
    });

    test('the current round is the newest one with something open', () {
      final orders = [
        _order('r1a', minute: 0, roundId: 'r1', status: OrderStatus.delivered),
        _order('r2a', minute: 5, roundId: 'r2'),
        _order('r2b', minute: 5, roundId: 'r2', status: OrderStatus.ready),
      ];
      expect(currentRoundOf(orders)!.map((o) => o.id), ['r2a', 'r2b']);
    });

    test('a pulled drink holds the round until the guest dismisses it', () {
      final orders = [
        _order(
          'pulled',
          roundId: 'r1',
          status: OrderStatus.cancelled,
          cancelReason: CancelReason.outOfStock,
          outOf: 'gin',
        ),
        _order('served', roundId: 'r1', status: OrderStatus.delivered),
      ];
      expect(currentRoundOf(orders), isNotNull);
      expect(currentRoundOf(orders, dismissedPulls: {'pulled'}), isNull);
    });

    test('progress lights one more segment per step', () {
      expect(progressSegmentsOf(_order('a')), 2);
      expect(progressSegmentsOf(_order('a', status: OrderStatus.preparing)), 3);
      expect(progressSegmentsOf(_order('a', status: OrderStatus.ready)), 4);
    });
  });

  group('the host', () {
    test('an order landing is announced per round', () {
      final orders = [
        _order('old', minute: 0),
        _order('n1', minute: 3, roundId: 'r'),
        _order('n2', minute: 3, roundId: 'r'),
      ];
      final landed = landedSince(orders, _t0.add(const Duration(minutes: 1)));
      expect(landed, hasLength(1));
      expect(landed.single.map((o) => o.id), ['n1', 'n2']);
    });

    test('the night in numbers counts served drinks only', () {
      final orders = [
        _order(
          'a',
          cocktailId: 'gt',
          status: OrderStatus.delivered,
          readyAt: _t0.add(const Duration(minutes: 4)),
        ),
        _order(
          'b',
          cocktailId: 'gt',
          status: OrderStatus.delivered,
          readyAt: _t0.add(const Duration(minutes: 2)),
        ),
        _order('c', cocktailId: 'negroni', status: OrderStatus.cancelled),
      ];
      final stats = barNightStatsOf(orders);
      expect(stats.poured, 2);
      expect(stats.averageWait, const Duration(minutes: 3));
      expect(stats.topCocktailId, 'gt');
    });

    test('running out finds every menu drink that needs the bottle', () {
      final menu = [
        _cocktail('gt', ['gin', 'tonic']),
        _cocktail('negroni', ['gin', 'campari', 'vermouth']),
        _cocktail('cosmo', ['vodka', 'cranberry']),
      ];
      expect(cocktailsNeeding('gin', menu).map((c) => c.id), ['gt', 'negroni']);
    });
  });

  group('swapping a pulled drink', () {
    final menu = [
      _cocktail('gt', ['gin', 'tonic']),
      _cocktail('negroni', ['gin', 'campari']),
      _cocktail('orchard', ['bourbon', 'apple']),
      _cocktail('cosmo', ['vodka', 'cranberry']),
      _cocktail('mule', ['vodka', 'ginger']),
    ];

    test('never offers the drink or anything else needing what ran out', () {
      final pulled = _order(
        'p',
        cocktailId: 'gt',
        status: OrderStatus.cancelled,
        cancelReason: CancelReason.outOfStock,
        outOf: 'gin',
      );
      final picks = swapSuggestionsFor(
        pulled,
        menu: menu,
        round: [pulled],
        allOrders: [pulled],
        limit: 5,
      );
      expect(picks.map((c) => c.id), isNot(contains('gt')));
      expect(picks.map((c) => c.id), isNot(contains('negroni')));
    });

    test('what a friend in the round is having comes first', () {
      final pulled = _order(
        'p',
        cocktailId: 'gt',
        roundId: 'r',
        status: OrderStatus.cancelled,
        cancelReason: CancelReason.outOfStock,
        outOf: 'gin',
      );
      final friend = _order('f', cocktailId: 'cosmo', roundId: 'r');
      final popular = [
        _order('x1', cocktailId: 'mule', guestId: 'x'),
        _order('x2', cocktailId: 'mule', guestId: 'x'),
      ];
      final picks = swapSuggestionsFor(
        pulled,
        menu: menu,
        round: [pulled, friend],
        allOrders: [pulled, friend, ...popular],
      );
      expect(picks.map((c) => c.id), ['cosmo', 'mule']);
    });
  });
}
