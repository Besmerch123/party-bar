import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../data/party_repository.dart';
import '../models/models.dart';

/// Service class for handling Party-related business logic.
/// Database operations are delegated to PartyRepository.
class PartyService {
  final PartyRepository _repository = PartyRepository();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

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

    try {
      // Create party in repository
      final partyId = await _repository.createParty(
        name: name,
        hostId: _currentUser!.uid,
        hostName: _currentUser!.displayName ?? 'Anonymous',
        joinCode: joinCode,
        description: description,
      );

      // Fetch and return the created party
      final party = await _repository.getPartyById(partyId);
      if (party == null) {
        throw Exception('Failed to fetch created party');
      }

      return party;
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
      return await _repository.getPartyById(partyId);
    } catch (e) {
      throw Exception('Failed to get party: $e');
    }
  }

  /// Get parties hosted by the current user
  Stream<List<Party>> getHostedParties() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    return _repository.getPartiesByHostId(_currentUser!.uid);
  }

  /// Update party status
  Future<void> updatePartyStatus(String partyId, PartyStatus status) async {
    try {
      await _repository.updatePartyStatus(partyId, status);
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
      await _repository.updateParty(
        partyId,
        name: name,
        description: description,
      );
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
      await _repository.updateAvailableCocktails(partyId, cocktailIds);
    } catch (e) {
      throw Exception('Failed to update available cocktails: $e');
    }
  }

  /// Join a party by join code
  Future<Party?> joinPartyByCode(String joinCode) async {
    try {
      return await _repository.findPartyByJoinCode(joinCode);
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
      final party = await _repository.getPartyById(partyId);
      if (party == null) {
        throw Exception('Party not found');
      }

      if (party.hostId != _currentUser!.uid) {
        throw Exception('Only the host can delete the party');
      }

      await _repository.deleteParty(partyId);
    } catch (e) {
      throw Exception('Failed to delete party: $e');
    }
  }
}
