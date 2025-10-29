import '../data/order_repository.dart';
import '../models/models.dart';

/// Service class for handling Order-related business logic
class OrderService {
  final OrderRepository _repository = OrderRepository();

  /// Create a new cocktail order
  Future<String> createOrder({
    required String partyId,
    required String cocktailId,
    required String guestName,
    String? guestId,
    String? specialRequests,
  }) async {
    try {
      return await _repository.createOrder(
        partyId: partyId,
        cocktailId: cocktailId,
        guestName: guestName,
        guestId: guestId,
        specialRequests: specialRequests,
      );
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get a single order by ID
  Future<CocktailOrder?> getOrderById(String partyId, String orderId) async {
    try {
      return await _repository.getOrderById(partyId, orderId);
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  /// Stream all orders for a party
  Stream<List<CocktailOrder>> streamPartyOrders(String partyId) {
    return _repository.streamPartyOrders(partyId);
  }

  /// Stream orders filtered by status
  Stream<List<CocktailOrder>> streamOrdersByStatus(
    String partyId,
    OrderStatus status,
  ) {
    return _repository.streamOrdersByStatus(partyId, status);
  }

  /// Update order status (host action)
  Future<void> updateOrderStatus(
    String partyId,
    String orderId,
    OrderStatus newStatus,
  ) async {
    try {
      await _repository.updateOrderStatus(partyId, orderId, newStatus);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Cancel an order
  Future<void> cancelOrder(String partyId, String orderId) async {
    try {
      await _repository.updateOrderStatus(
        partyId,
        orderId,
        OrderStatus.cancelled,
      );
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  /// Delete an order (should be used rarely, mainly for cleanup)
  Future<void> deleteOrder(String partyId, String orderId) async {
    try {
      await _repository.deleteOrder(partyId, orderId);
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }
}
