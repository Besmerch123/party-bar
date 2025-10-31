import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

/// Repository for managing cocktail orders in Firestore
/// Orders are stored as subcollections under parties: parties/{partyId}/orders/{orderId}
class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get orders collection reference for a specific party
  CollectionReference _ordersCollection(String partyId) =>
      _firestore.collection('parties').doc(partyId).collection('orders');

  /// Create a new order
  Future<String> createOrder({
    required String partyId,
    required String cocktailId,
    required String guestName,
    String? guestId,
    String? specialRequests,
  }) async {
    try {
      final orderData = {
        'partyId': partyId,
        'cocktailId': cocktailId,
        'guestName': guestName,
        'guestId': guestId,
        'specialRequests': specialRequests,
        'status': OrderStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
        'preparedAt': null,
        'deliveredAt': null,
      };

      final docRef = await _ordersCollection(partyId).add(orderData);
      await docRef.update({'id': docRef.id});

      // Increment party's total orders count
      await _firestore.collection('parties').doc(partyId).update({
        'totalOrders': FieldValue.increment(1),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get a single order by ID
  Future<CocktailOrder?> getOrderById(String partyId, String orderId) async {
    try {
      final snapshot = await _ordersCollection(partyId).doc(orderId).get();
      if (!snapshot.exists) {
        return null;
      }
      return _orderFromSnapshot(snapshot);
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  /// Stream all orders for a party
  Stream<List<CocktailOrder>> streamPartyOrders(String partyId) {
    return _ordersCollection(
      partyId,
    ).orderBy('createdAt', descending: false).snapshots().map((snapshot) {
      return snapshot.docs.map(_orderFromSnapshot).toList();
    });
  }

  /// Stream orders by status
  Stream<List<CocktailOrder>> streamOrdersByStatus(
    String partyId,
    OrderStatus status,
  ) {
    return _ordersCollection(partyId)
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(_orderFromSnapshot).toList();
        });
  }

  /// Update order status
  Future<void> updateOrderStatus(
    String partyId,
    String orderId,
    OrderStatus newStatus,
  ) async {
    try {
      final updates = <String, dynamic>{'status': newStatus.name};

      // Add timestamps based on status
      if (newStatus == OrderStatus.preparing) {
        updates['preparedAt'] = FieldValue.serverTimestamp();
      } else if (newStatus == OrderStatus.delivered) {
        updates['deliveredAt'] = FieldValue.serverTimestamp();
      }

      await _ordersCollection(partyId).doc(orderId).update(updates);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Delete an order
  Future<void> deleteOrder(String partyId, String orderId) async {
    try {
      await _ordersCollection(partyId).doc(orderId).delete();

      // Decrement party's total orders count
      await _firestore.collection('parties').doc(partyId).update({
        'totalOrders': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  /// Helper method to convert Firestore snapshot to CocktailOrder model
  CocktailOrder _orderFromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return CocktailOrder.fromMap({
      ...data,
      'id': snapshot.id,
      'createdAt': (data['createdAt'] as Timestamp).millisecondsSinceEpoch,
      if (data['preparedAt'] != null)
        'preparedAt': (data['preparedAt'] as Timestamp).millisecondsSinceEpoch,
      if (data['deliveredAt'] != null)
        'deliveredAt':
            (data['deliveredAt'] as Timestamp).millisecondsSinceEpoch,
    });
  }
}
