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
    PartyStatus status = PartyStatus.paused,
    String? description,
  }) async {
    try {
      final partyData = {
        'name': name,
        'hostId': hostId,
        'hostName': hostName,
        'availableCocktailIds': [],
        'joinCode': joinCode,
        'status': status.name,
        'createdAt': FieldValue.serverTimestamp(),
        'endedAt': null,
        'totalOrders': 0,
        'description': description,
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
      };

      await _partiesCollection.doc(partyId).update(updates);
    } catch (e) {
      throw Exception('Failed to update party status: $e');
    }
  }

  /// Update party information
  Future<void> updateParty(
    String partyId, {
    String? name,
    String? description,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) {
        updates['description'] = description;
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
      final snapshot = await _partiesCollection
          .where('joinCode', isEqualTo: joinCode.toUpperCase())
          .where('status', isEqualTo: PartyStatus.active.name)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return _partyFromSnapshot(snapshot.docs.first);
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
  Party _partyFromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Party.fromMap({
      ...data,
      'id': snapshot.id,
      'createdAt': (data['createdAt'] as Timestamp).millisecondsSinceEpoch,
      if (data['endedAt'] != null)
        'endedAt': (data['endedAt'] as Timestamp).millisecondsSinceEpoch,
    });
  }
}
