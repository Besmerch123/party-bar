import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:party_bar/models/models.dart';

/// One codec for every shape a Firestore date field turns up in: a
/// `Timestamp` from `FieldValue.serverTimestamp()`, an `int` of epoch millis
/// from a model's own `toMap()`, an ISO-8601 string from an older document
/// or from local JSON, or a `DateTime` already decoded. A document written
/// by one path and read back through another can legitimately hold either
/// of the first two — that disagreement used to throw on a party document
/// and silently drop timestamps on an order document.

void main() {
  group('firestoreDate', () {
    test('decodes a Timestamp', () {
      final timestamp = Timestamp.fromMillisecondsSinceEpoch(1000);
      expect(firestoreDate(timestamp), DateTime.fromMillisecondsSinceEpoch(1000));
    });

    test('decodes an int of epoch millis', () {
      expect(firestoreDate(1000), DateTime.fromMillisecondsSinceEpoch(1000));
    });

    test('decodes an ISO-8601 string', () {
      final moment = DateTime(2026, 9, 12, 22, 30);
      expect(firestoreDate(moment.toIso8601String()), moment);
    });

    test('passes a DateTime through unchanged', () {
      final now = DateTime(2026, 9, 12);
      expect(firestoreDate(now), now);
    });

    test('null decodes to null', () {
      expect(firestoreDate(null), isNull);
    });

    test('an unparseable string decodes to null rather than throwing', () {
      expect(firestoreDate('not a date'), isNull);
    });

    test('a wrong-type value decodes to null rather than throwing', () {
      expect(firestoreDate(<String, dynamic>{'not': 'a date'}), isNull);
      expect(firestoreDate(3.14), isNull);
    });
  });

  group('firestoreDateOr', () {
    final fallback = DateTime(2000);

    test('falls back when the field is missing', () {
      expect(firestoreDateOr(null, fallback), fallback);
    });

    test('falls back when the value cannot be decoded', () {
      expect(firestoreDateOr('garbage', fallback), fallback);
      expect(firestoreDateOr(3.14, fallback), fallback);
    });

    test('uses the decoded value when there is one', () {
      expect(
        firestoreDateOr(1000, fallback),
        DateTime.fromMillisecondsSinceEpoch(1000),
      );
    });
  });

  group('regression — a document an int date field crashed or dropped', () {
    // Party.toMap() writes createdAt/wentLiveAt as epoch millis, but
    // PartyRepository.goLive() and party creation write them with
    // FieldValue.serverTimestamp(). The same field on the same document can
    // hold either type depending on which write path touched it last.
    test('Party.fromMap decodes an int createdAt instead of throwing', () {
      final party = Party.fromMap({
        'id': 'p1',
        'name': "Kate's Birthday",
        'hostId': 'host',
        'hostName': 'Kate',
        'joinCode': 'ABC123',
        'status': 'active',
        'createdAt': 1000,
        'wentLiveAt': 2000,
      });

      expect(party.createdAt, DateTime.fromMillisecondsSinceEpoch(1000));
      expect(party.wentLiveAt, DateTime.fromMillisecondsSinceEpoch(2000));
    });

    test('Party.fromMap still decodes a Timestamp createdAt', () {
      final party = Party.fromMap({
        'id': 'p1',
        'name': 'n',
        'hostId': 'h',
        'hostName': 'h',
        'joinCode': 'ABC123',
        'status': 'active',
        'createdAt': Timestamp.fromMillisecondsSinceEpoch(1000),
      });

      expect(party.createdAt, DateTime.fromMillisecondsSinceEpoch(1000));
    });

    // CocktailOrder.toMap() writes epoch millis; OrderRepository writes
    // FieldValue.serverTimestamp() on every status change. Same field, same
    // disagreement.
    test('CocktailOrder.fromMap decodes an int createdAt instead of dropping it', () {
      final order = CocktailOrder.fromMap({
        'id': 'o1',
        'partyId': 'p1',
        'cocktailId': 'gt',
        'guestName': 'Sam',
        'status': 'pending',
        'createdAt': 1000,
        'preparedAt': 2000,
      });

      expect(order.createdAt, DateTime.fromMillisecondsSinceEpoch(1000));
      expect(order.preparedAt, DateTime.fromMillisecondsSinceEpoch(2000));
    });

    test('CocktailOrder.fromMap still decodes a Timestamp preparedAt', () {
      final order = CocktailOrder.fromMap({
        'id': 'o1',
        'partyId': 'p1',
        'cocktailId': 'gt',
        'guestName': 'Sam',
        'status': 'preparing',
        'createdAt': 1000,
        'preparedAt': Timestamp.fromMillisecondsSinceEpoch(2000),
      });

      expect(order.preparedAt, DateTime.fromMillisecondsSinceEpoch(2000));
    });
  });
}
