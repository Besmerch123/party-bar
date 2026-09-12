import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

/// Repository for managing party data from Firestore
class PartyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference for parties
  CollectionReference get _partiesCollection =>
      _firestore.collection('parties');

  /// Create a new party in Firestore
  /// Returns the generated document ID
  Future<String> createParty({
    required String name,
    required String hostId,
    required String hostName,
    required String joinCode,
    PartyStatus status = PartyStatus.draft,
    String? description,
    List<String> cocktailIds = const [],
    DateTime? scheduledFor,
  }) async {
    try {
      final partyData = {
        'name': name,
        'hostId': hostId,
        'hostName': hostName,
        'availableCocktailIds': cocktailIds,
        'joinCode': joinCode,
        'status': status.name,
        'createdAt': FieldValue.serverTimestamp(),
        'endedAt': null,
        'totalOrders': 0,
        'description': description,
        'scheduledFor': scheduledFor == null
            ? null
            : Timestamp.fromDate(scheduledFor),
      };

      // Add document and let Firebase generate the ID
      final docRef = await _partiesCollection.add(partyData);

      // Update the document to include its own ID
      await docRef.update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create party: $e');
    }
  }

  /// Get a party by ID
  Future<Party?> getPartyById(String partyId) async {
    try {
      final snapshot = await _partiesCollection.doc(partyId).get();
      if (!snapshot.exists) {
        return null;
      }

      return _partyFromSnapshot(snapshot);
    } catch (e) {
      throw Exception('Failed to get party: $e');
    }
  }

  /// One party, live — status, menu and all. Null once it is deleted.
  Stream<Party?> streamParty(String partyId) => _partiesCollection
      .doc(partyId)
      .snapshots()
      .map((snapshot) => snapshot.exists ? _partyFromSnapshot(snapshot) : null);

  /// Get parties hosted by a specific user
  Stream<List<Party>> getPartiesByHostId(String hostId) {
    return _partiesCollection
        .where('hostId', isEqualTo: hostId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(_partyFromSnapshot).toList();
        });
  }

  /// Update party status
  Future<void> updatePartyStatus(String partyId, PartyStatus status) async {
    try {
      final updates = {
        'status': status.name,
        if (status == PartyStatus.ended)
          'endedAt': FieldValue.serverTimestamp(),
        if (status == PartyStatus.paused)
          'pausedAt': FieldValue.serverTimestamp(),
      };

      await _partiesCollection.doc(partyId).update(updates);
    } catch (e) {
      throw Exception('Failed to update party status: $e');
    }
  }

  /// Flow 05 · screen 08 — the one commitment. The code starts working and
  /// the live chip starts counting from the server's clock, not the phone's.
  Future<void> goLive(String partyId) async {
    try {
      await _partiesCollection.doc(partyId).update({
        'status': PartyStatus.active.name,
        'wentLiveAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to go live: $e');
    }
  }

  /// Update party information. [clearSchedule] sets the party back to
  /// "tonight", which a null [scheduledFor] alone cannot say.
  Future<void> updateParty(
    String partyId, {
    String? name,
    String? description,
    DateTime? scheduledFor,
    bool clearSchedule = false,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) {
        updates['description'] = description;
      }
      if (clearSchedule) {
        updates['scheduledFor'] = null;
      } else if (scheduledFor != null) {
        updates['scheduledFor'] = Timestamp.fromDate(scheduledFor);
      }

      if (updates.isNotEmpty) {
        await _partiesCollection.doc(partyId).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update party: $e');
    }
  }

  /// Update available cocktails for a party
  Future<void> updateAvailableCocktails(
    String partyId,
    List<String> cocktailIds,
  ) async {
    try {
      await _partiesCollection.doc(partyId).update({
        'availableCocktailIds': cocktailIds,
      });
    } catch (e) {
      throw Exception('Failed to update available cocktails: $e');
    }
  }

  /// Find a party by join code
  Future<Party?> findPartyByJoinCode(String joinCode) async {
    try {
      // Flow 07 — the code is looked up whatever state its party is in, and
      // the caller decides what that means. Filtering to `active` here made
      // a paused bar unjoinable (pause stops orders, not arrivals) and made
      // an ended party indistinguishable from a typo, which is the one
      // distinction screen 04 exists to draw.
      final snapshot = await _partiesCollection
          .where('joinCode', isEqualTo: joinCode.toUpperCase())
          .limit(5)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      // Codes are random and never reused, so more than one match means a
      // collision across nights. A party still running wins; otherwise the
      // most recent one, which is the one whoever typed this meant.
      final parties = snapshot.docs.map(_partyFromSnapshot).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return parties.firstWhere((p) => p.isLive, orElse: () => parties.first);
    } catch (e) {
      throw Exception('Failed to find party by join code: $e');
    }
  }

  /// Delete a party
  Future<void> deleteParty(String partyId) async {
    try {
      await _partiesCollection.doc(partyId).delete();
    } catch (e) {
      throw Exception('Failed to delete party: $e');
    }
  }

  /// Helper method to convert Firestore snapshot to Party model
  ///
  /// A write this device just made reaches the hosted-parties stream before
  /// the server has stamped it, so every server timestamp can still be null
  /// here — a fresh draft reads as created "now" rather than crashing.
  Party _partyFromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    int? millis(String key) =>
        (data[key] as Timestamp?)?.millisecondsSinceEpoch;

    return Party.fromMap({
      ...data,
      'id': snapshot.id,
      'createdAt': millis('createdAt') ?? DateTime.now().millisecondsSinceEpoch,
      'endedAt': millis('endedAt'),
      'scheduledFor': millis('scheduledFor'),
      'wentLiveAt': millis('wentLiveAt') ??
          (data['status'] == PartyStatus.active.name
              ? DateTime.now().millisecondsSinceEpoch
              : null),
      'pausedAt': millis('pausedAt'),
    });
  }
}
