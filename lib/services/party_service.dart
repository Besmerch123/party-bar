import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/models.dart';

/// Service class for handling Party-related Firebase operations.
class PartyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  /// Collection reference for parties
  CollectionReference get _partiesCollection =>
      _firestore.collection('parties');

  /// Get current user
  auth.User? get _currentUser => _auth.currentUser;

  /// Create a new party
  /// Firebase will automatically generate the party ID
  Future<Party> createParty({required String name, String? description}) async {
    if (_currentUser == null) {
      throw Exception('User must be authenticated to create a party');
    }

    // Generate a unique join code
    final joinCode = _generateJoinCode();

    // Create party data without ID (Firebase will generate it)
    final partyData = {
      'name': name,
      'hostId': _currentUser!.uid,
      'hostName': _currentUser!.displayName ?? 'Anonymous',
      'availableCocktailIds': [],
      'joinCode': joinCode,
      'status': PartyStatus.paused.name,
      'createdAt': FieldValue.serverTimestamp(),
      'endedAt': null,
      'totalOrders': 0,
      'description': description,
    };

    try {
      // Add document and let Firebase generate the ID
      final docRef = await _partiesCollection.add(partyData);

      // Update the document to include its own ID
      await docRef.update({'id': docRef.id});

      // Fetch the created party
      final snapshot = await docRef.get();
      final data = snapshot.data() as Map<String, dynamic>;

      return Party.fromMap({
        ...data,
        'id': docRef.id,
        'createdAt': (data['createdAt'] as Timestamp).millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to create party: $e');
    }
  }

  /// Generate a unique 6-character join code
  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// Get a party by ID
  Future<Party?> getPartyById(String partyId) async {
    try {
      final snapshot = await _partiesCollection.doc(partyId).get();
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      return Party.fromMap({
        ...data,
        'id': snapshot.id,
        'createdAt': (data['createdAt'] as Timestamp).millisecondsSinceEpoch,
        if (data['endedAt'] != null)
          'endedAt': (data['endedAt'] as Timestamp).millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to get party: $e');
    }
  }

  /// Get parties hosted by the current user
  Stream<List<Party>> getHostedParties() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    return _partiesCollection
        .where('hostId', isEqualTo: _currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Party.fromMap({
              ...data,
              'id': doc.id,
              'createdAt':
                  (data['createdAt'] as Timestamp).millisecondsSinceEpoch,
              if (data['endedAt'] != null)
                'endedAt':
                    (data['endedAt'] as Timestamp).millisecondsSinceEpoch,
            });
          }).toList();
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

  /// Update party information (name and description)
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

  /// Join a party by join code
  Future<Party?> joinPartyByCode(String joinCode) async {
    try {
      final snapshot = await _partiesCollection
          .where('joinCode', isEqualTo: joinCode.toUpperCase())
          .where('status', isEqualTo: PartyStatus.active.name)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      return Party.fromMap({
        ...data,
        'id': doc.id,
        'createdAt': (data['createdAt'] as Timestamp).millisecondsSinceEpoch,
        if (data['endedAt'] != null)
          'endedAt': (data['endedAt'] as Timestamp).millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to join party: $e');
    }
  }

  /// Delete a party (only by host)
  Future<void> deleteParty(String partyId) async {
    if (_currentUser == null) {
      throw Exception('User must be authenticated to delete a party');
    }

    try {
      // Verify the user is the host
      final party = await getPartyById(partyId);
      if (party == null) {
        throw Exception('Party not found');
      }

      if (party.hostId != _currentUser!.uid) {
        throw Exception('Only the host can delete the party');
      }

      await _partiesCollection.doc(partyId).delete();
    } catch (e) {
      throw Exception('Failed to delete party: $e');
    }
  }
}
