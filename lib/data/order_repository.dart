import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';

/// Thrown when a guest tries to cancel an order the host already started
/// pouring — the race Flow 06 screen 05 explains to the guest.
class OrderAlreadyPouring implements Exception {
  const OrderAlreadyPouring();
}

/// Repository for managing cocktail orders in Firestore
/// Orders are stored as subcollections under parties: parties/{partyId}/orders/{orderId}
class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ordersCollection(
    String partyId,
  ) => _firestore.collection('parties').doc(partyId).collection('orders');

  DocumentReference<Map<String, dynamic>> _orderDoc(CocktailOrder order) =>
      _ordersCollection(order.partyId).doc(order.id);

  /// Flow 06 · screen 02 — one send, one order per drink, all in one write
  /// so a round never half-lands. Returns the new order ids, in [items]
  /// order.
  Future<List<String>> sendRound({
    required String partyId,
    required String guestName,
    required String guestId,
    required List<RoundItem> items,
  }) async {
    if (items.isEmpty) return const [];

    final roundId = const Uuid().v4();
    final batch = _firestore.batch();
    final ids = <String>[];

    for (final item in items) {
      final doc = _ordersCollection(partyId).doc();
      ids.add(doc.id);
      final note = item.note?.trim();
      final forName = item.forName?.trim();
      batch.set(doc, {
        'id': doc.id,
        'partyId': partyId,
        'cocktailId': item.cocktailId,
        'guestName': guestName,
        'guestId': guestId,
        'specialRequests': note == null || note.isEmpty ? null : note,
        'forName': forName == null || forName.isEmpty ? null : forName,
        'roundId': roundId,
        'status': OrderStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    // The tally on the party is a convenience for the recap; a guest who
    // cannot write it still got their round in.
    try {
      await _firestore.collection('parties').doc(partyId).update({
        'totalOrders': FieldValue.increment(items.length),
      });
    } catch (e) {
      debugPrint('Could not bump totalOrders on $partyId: $e');
    }

    return ids;
  }

  /// Stream all orders for a party
  Stream<List<CocktailOrder>> streamPartyOrders(String partyId) {
    return _ordersCollection(partyId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_orderFromSnapshot).toList());
  }

  /// Pending → pouring.
  Future<void> startPouring(CocktailOrder order) => _orderDoc(order).update({
    'status': OrderStatus.preparing.name,
    'preparedAt': FieldValue.serverTimestamp(),
  });

  /// Pouring → on the counter. Buzzes the guest.
  Future<void> markReady(CocktailOrder order) => _orderDoc(order).update({
    'status': OrderStatus.ready.name,
    'readyAt': FieldValue.serverTimestamp(),
    'buzzedAt': FieldValue.serverTimestamp(),
  });

  /// On the counter → back to pouring, for a drink put up by mistake.
  Future<void> backToMixing(CocktailOrder order) => _orderDoc(order).update({
    'status': OrderStatus.preparing.name,
    'readyAt': null,
  });

  /// On the counter → served.
  Future<void> markServed(CocktailOrder order) => _orderDoc(order).update({
    'status': OrderStatus.delivered.name,
    'deliveredAt': FieldValue.serverTimestamp(),
  });

  /// "Buzz again" — the guest's phone reacts to the timestamp moving.
  Future<void> buzz(CocktailOrder order) =>
      _orderDoc(order).update({'buzzedAt': FieldValue.serverTimestamp()});

  /// The guest pulling their own order. Transactional, because the host may
  /// have started pouring it a second ago; that throws [OrderAlreadyPouring].
  Future<void> cancelByGuest(CocktailOrder order) {
    final doc = _orderDoc(order);
    return _firestore.runTransaction((tx) async {
      final fresh = await tx.get(doc);
      if (fresh.data()?['status'] != OrderStatus.pending.name) {
        throw const OrderAlreadyPouring();
      }
      tx.update(doc, _cancellation(CancelReason.guest));
    });
  }

  Future<void> cancelByHost(
    CocktailOrder order, {
    CancelReason reason = CancelReason.host,
    Ingredient? outOf,
  }) => _orderDoc(order).update(_cancellation(reason, outOf: outOf));

  /// Flow 06 · screen 12 — running out is one tap: every open, not-yet-
  /// poured order in [orders] is pulled with [ingredient] named, and
  /// [cocktailIds] come off the party's menu, in one write.
  Future<void> pullForStock({
    required String partyId,
    required Ingredient ingredient,
    required Iterable<CocktailOrder> orders,
    required Iterable<String> cocktailIds,
  }) async {
    final batch = _firestore.batch();
    for (final order in orders) {
      if (!order.isPending && !order.isPreparing) continue;
      batch.update(
        _orderDoc(order),
        _cancellation(CancelReason.outOfStock, outOf: ingredient),
      );
    }
    final ids = cocktailIds.toList();
    if (ids.isNotEmpty) {
      batch.update(_firestore.collection('parties').doc(partyId), {
        'availableCocktailIds': FieldValue.arrayRemove(ids),
      });
    }
    await batch.commit();
  }

  /// Whatever is still open when a party ends.
  Future<void> cancelForPartyEnd(Iterable<CocktailOrder> orders) async {
    final open = orders.where((o) => o.isOpen).toList();
    if (open.isEmpty) return;
    final batch = _firestore.batch();
    for (final order in open) {
      batch.update(_orderDoc(order), _cancellation(CancelReason.partyEnded));
    }
    await batch.commit();
  }

  Map<String, dynamic> _cancellation(CancelReason reason, {Ingredient? outOf}) =>
      {
        'status': OrderStatus.cancelled.name,
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelReason': reason.name,
        if (outOf != null) 'outOfIngredientId': outOf.id,
        if (outOf != null) 'outOfIngredientTitle': outOf.title,
      };

  /// A write this device just made reaches the stream before the server has
  /// stamped it, so every server timestamp can still be null here. A fresh
  /// order reads as sent "now"; the others stay null for that one frame.
  ///
  /// Date fields pass through unconverted: [CocktailOrder.fromMap] decodes
  /// whatever shape Firestore handed back (`Timestamp` or an `int` of epoch
  /// millis) through the shared codec, so there is nothing to normalise here.
  CocktailOrder _orderFromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? const <String, dynamic>{};

    return CocktailOrder.fromMap({
      ...data,
      'id': snapshot.id,
      'createdAt': data['createdAt'] ?? DateTime.now(),
    });
  }
}
