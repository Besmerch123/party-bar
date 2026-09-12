import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/bar.dart';
import '../models/bar_item.dart';
import '../models/onboarding.dart';
import '../models/shared_types.dart';
import '../models/shopping_list.dart';
import '../models/user.dart';

/// The bar as flow 04 leaves it — one account, one shelf.
class RemoteBar {
  const RemoteBar({this.items = const [], this.shoppingList = const []});

  final List<BarItem> items;
  final List<ShoppingEntry> shoppingList;
}

/// Where [BarProvider] reads and writes the account's copy of the bar.
///
/// A seam, not just for tests: the provider must never touch Firestore at
/// construction, and this is what lets it defer that until someone is
/// actually signed in.
abstract class BarAccountSync {
  /// The account's bar, or null if it has never saved one. A doc that only
  /// carries the pre-Flow-04 `shelf` field still answers this — every key
  /// becomes a stocked item, because that is all the old shape could mean.
  Future<RemoteBar?> loadBar(String uid);

  Future<void> saveBar(String uid, RemoteBar bar);
}

/// The account document behind a signed-in person.
///
/// Flow 01 collects a vibe and a shelf before any account exists, and flow 02
/// spends them signed out. This is where that device-local state stops being
/// device-local: the first successful sign-in claims it.
///
/// The claim is a union, never a replace. Someone who stocked a shelf on a
/// second phone before signing in should end up with both shelves, not
/// whichever one happened to sign in last.
class AccountService implements BarAccountSync {
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

  // ------------------------------------------------------------------- profile

  /// Flow 09 — the whole of what Settings reads about the signed-in person.
  /// Null only for a document that has genuinely never been written, which
  /// [claimLocalState] rules out for anyone who has ever signed in once.
  Future<User?> getProfile(String uid) async {
    final snapshot = await _userDoc(uid).get();
    final data = snapshot.data();
    if (data == null) return null;
    return _userFromData(data, uid);
  }

  /// The live version of [getProfile] — so a toggle flipped on screen 06
  /// shows up on the index's "2 of 3 on" without a manual refresh.
  Stream<User?> watchProfile(String uid) => _userDoc(uid).snapshots().map((snapshot) {
    final data = snapshot.data();
    if (data == null) return null;
    return _userFromData(data, uid);
  });

  /// [User.fromMap] decodes whatever shape the field arrives in, so the only
  /// thing left to say here is what a *missing* stamp means: a write this
  /// device just made can reach a listener before the server has stamped it,
  /// and "now" is a truer reading of that than the epoch.
  User _userFromData(Map<String, dynamic> data, String uid) {
    final now = DateTime.now();

    return User.fromMap({
      ...data,
      'id': uid,
      'createdAt': firestoreDate(data['createdAt']) ?? now,
      'lastLoginAt': firestoreDate(data['lastLoginAt']) ?? now,
    });
  }

  /// Screen 03 (name, allergens) and screen 06 (the three switches) both
  /// write through here — a merge, so editing one never clobbers the other.
  Future<void> updateProfile(
    String uid, {
    String? name,
    List<String>? allergens,
    bool? notifyDrinkReady,
    bool? notifyNewOrder,
    bool? notifyRecapMorning,
  }) async {
    await _userDoc(uid).set({
      if (name != null) 'name': name,
      if (allergens != null) 'allergens': allergens,
      if (notifyDrinkReady != null) 'notifyDrinkReady': notifyDrinkReady,
      if (notifyNewOrder != null) 'notifyNewOrder': notifyNewOrder,
      if (notifyRecapMorning != null) 'notifyRecapMorning': notifyRecapMorning,
    }, SetOptions(merge: true));
  }

  /// Screen 07's one-way door, the Firestore half of it. What this does not
  /// do is just as deliberate: it never touches another host's parties, so a
  /// guest's drink count survives inside them — only the account that placed
  /// it is gone.
  Future<void> deleteAccountDoc(String uid) => _userDoc(uid).delete();

  // ------------------------------------------------------------ BarAccountSync

  @override
  Future<RemoteBar?> loadBar(String uid) async {
    final data = (await _userDoc(uid).get()).data();
    if (data == null) return null;

    final bar = data['bar'];
    if (bar is Map) {
      return RemoteBar(
        items: _decodeList(bar['items']).map(BarItem.fromJson).toList(),
        shoppingList: _decodeList(
          bar['shoppingList'],
        ).map(ShoppingEntry.fromJson).toList(),
      );
    }

    // Pre-Flow-04 accounts only ever wrote `shelf` — every key on it was
    // stocked, because binary stock is all that shape could represent.
    final shelf = data['shelf'];
    if (shelf is List) {
      final now = DateTime.now();
      return RemoteBar(
        items: shelf.whereType<String>().map((raw) {
          final key = barKey(raw);
          return BarItem(
            key: key,
            kind: BarItemKind.ingredient,
            section: BarSection.other,
            addedAt: now,
          );
        }).toList(),
      );
    }

    return null;
  }

  @override
  Future<void> saveBar(String uid, RemoteBar bar) async {
    await _userDoc(uid).set({
      // Kept in step for anything still reading the old field, e.g. the
      // claim on a second device signing in for the first time.
      'shelf': bar.items
          .where((item) => item.isStocked)
          .map((item) => item.key)
          .toList(),
      'bar': {
        'items': bar.items.map((item) => item.toJson()).toList(),
        'shoppingList': bar.shoppingList.map((entry) => entry.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }

  List<Map<String, dynamic>> _decodeList(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }
}
