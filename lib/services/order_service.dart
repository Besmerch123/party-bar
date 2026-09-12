import '../data/order_repository.dart';
import '../models/models.dart';

/// Flow 06 — cancelling a whole round is the one verb with real logic left;
/// every other order verb is a bare delegate, so callers reach
/// [OrderRepository] directly instead of going through a pass-through here.
class OrderService {
  OrderService([OrderRepository? repository])
    : _repository = repository ?? OrderRepository();

  final OrderRepository _repository;

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
}
