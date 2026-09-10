import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/onboarding.dart';

/// The account document behind a signed-in person.
///
/// Flow 01 collects a vibe and a shelf before any account exists, and flow 02
/// spends them signed out. This is where that device-local state stops being
/// device-local: the first successful sign-in claims it.
///
/// The claim is a union, never a replace. Someone who stocked a shelf on a
/// second phone before signing in should end up with both shelves, not
/// whichever one happened to sign in last.
class AccountService {
  AccountService({FirebaseFirestore? firestore})
    : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  // Resolved on use, so a test double that overrides [claimLocalState] never
  // reaches for an uninitialized Firestore.
  late final FirebaseFirestore _firestore =
      _firestoreOverride ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Fold everything this device was holding into the account.
  ///
  /// Safe to call on every sign-in: `arrayUnion` makes a second call with the
  /// same shelf a no-op, and `createdAt` is only written once.
  Future<void> claimLocalState({
    required String uid,
    String? displayName,
    String? email,
    String? avatarUrl,
    Set<String> shelf = const {},
    Set<DrinkVibe> vibes = const {},
  }) async {
    final doc = _userDoc(uid);
    final existing = await doc.get();

    await doc.set({
      'id': uid,
      if (displayName != null && displayName.isNotEmpty) 'name': displayName,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (shelf.isNotEmpty) 'shelf': FieldValue.arrayUnion(shelf.toList()),
      if (vibes.isNotEmpty)
        'vibes': FieldValue.arrayUnion(vibes.map((v) => v.name).toList()),
      if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// The shelf the account already knows about, so a fresh phone can adopt it
  /// rather than starting empty.
  Future<Set<String>> remoteShelf(String uid) async {
    final snapshot = await _userDoc(uid).get();
    final shelf = snapshot.data()?['shelf'];
    if (shelf is! List) return const {};
    return shelf.whereType<String>().toSet();
  }
}
