import '../data/order_repository.dart';
import '../models/models.dart';

export '../data/order_repository.dart' show OrderAlreadyPouring;

/// Flow 06 — the verbs of the loop. The guest sends and cancels; the host
/// pours, puts up, hands over, buzzes, skips and pulls. Nothing waits on a
/// yes.
class OrderService {
  OrderService([OrderRepository? repository])
    : _repository = repository ?? OrderRepository();

  final OrderRepository _repository;

  Stream<List<CocktailOrder>> streamPartyOrders(String partyId) =>
      _repository.streamPartyOrders(partyId);

  // ------------------------------------------------------------------ guest

  Future<List<String>> sendRound({
    required String partyId,
    required String guestName,
    required String guestId,
    required List<RoundItem> items,
  }) => _repository.sendRound(
    partyId: partyId,
    guestName: guestName,
    guestId: guestId,
    items: items,
  );

  /// Throws [OrderAlreadyPouring] once the host has started it.
  Future<void> cancelByGuest(CocktailOrder order) =>
      _repository.cancelByGuest(order);

  /// Cancels every order in [round] that can still be cancelled; returns how
  /// many were already pouring and stayed.
  Future<int> cancelRound(Iterable<CocktailOrder> round) async {
    var kept = 0;
    for (final order in round) {
      if (!order.canGuestCancel) {
        if (order.isOpen) kept++;
        continue;
      }
      try {
        await _repository.cancelByGuest(order);
      } on OrderAlreadyPouring {
        kept++;
      }
    }
    return kept;
  }

  // ------------------------------------------------------------------- host

  Future<void> startPouring(CocktailOrder order) =>
      _repository.startPouring(order);

  Future<void> markReady(CocktailOrder order) => _repository.markReady(order);

  Future<void> backToMixing(CocktailOrder order) =>
      _repository.backToMixing(order);

  Future<void> markServed(CocktailOrder order) =>
      _repository.markServed(order);

  Future<void> buzz(CocktailOrder order) => _repository.buzz(order);

  /// "Skip · can't make it" and "Cancel order".
  Future<void> skip(CocktailOrder order) => _repository.cancelByHost(order);

  /// "Only this order — keep them on the menu".
  Future<void> pullOneForStock(CocktailOrder order, Ingredient ingredient) =>
      _repository.cancelByHost(
        order,
        reason: CancelReason.outOfStock,
        outOf: ingredient,
      );

  /// "Pull N drinks from the menu".
  Future<void> pullForStock({
    required String partyId,
    required Ingredient ingredient,
    required Iterable<CocktailOrder> orders,
    required Iterable<String> cocktailIds,
  }) => _repository.pullForStock(
    partyId: partyId,
    ingredient: ingredient,
    orders: orders,
    cocktailIds: cocktailIds,
  );

  Future<void> cancelForPartyEnd(Iterable<CocktailOrder> orders) =>
      _repository.cancelForPartyEnd(orders);
}
