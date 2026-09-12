import 'shared_types.dart';

/// The account behind a signed-in person — Flow 09's "one question: what do
/// guests read?" plus the handful of fields nothing else in the app owns yet.
///
/// [allergens] existed on this document before Flow 09 gave it a screen:
/// written nowhere, read by nothing. Flow 09 makes it editable but the
/// caveat on its own screen is honest about the rest — nothing downstream
/// reads it yet, so it rides along with an order as a note rather than
/// filtering a menu.
class User {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final List<String> favoriteCoktailIds;
  final List<String> allergens;

  /// "Your drink is ready" — the one notification that already fires from
  /// the pour flow's own logic. Defaults on.
  final bool notifyDrinkReady;

  /// Batched new-order pings for whoever is hosting. Defaults on.
  final bool notifyNewOrder;

  /// The morning-after summary. Defaults off — a recap is a place you visit,
  /// not a push someone asked for.
  final bool notifyRecapMorning;

  final DateTime createdAt;
  final DateTime lastLoginAt;

  const User({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.favoriteCoktailIds = const [],
    this.allergens = const [],
    this.notifyDrinkReady = true,
    this.notifyNewOrder = true,
    this.notifyRecapMorning = false,
    required this.createdAt,
    required this.lastLoginAt,
  });

  /// How the index row reads it — "2 of 3 on".
  int get notificationsOnCount =>
      (notifyDrinkReady ? 1 : 0) + (notifyNewOrder ? 1 : 0) + (notifyRecapMorning ? 1 : 0);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'favoriteCoktailIds': favoriteCoktailIds,
      'allergens': allergens,
      'notifyDrinkReady': notifyDrinkReady,
      'notifyNewOrder': notifyNewOrder,
      'notifyRecapMorning': notifyRecapMorning,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      avatarUrl: map['avatarUrl'],
      favoriteCoktailIds: List<String>.from(map['favoriteCoktailIds'] ?? []),
      allergens: List<String>.from(map['allergens'] ?? []),
      // Pre-Flow-09 accounts only ever wrote the single `notificationsEnabled`
      // — both new switches inherit it rather than silently going quiet.
      notifyDrinkReady: map['notifyDrinkReady'] ?? map['notificationsEnabled'] ?? true,
      notifyNewOrder: map['notifyNewOrder'] ?? map['notificationsEnabled'] ?? true,
      notifyRecapMorning: map['notifyRecapMorning'] ?? false,
      createdAt: firestoreDateOr(
        map['createdAt'],
        DateTime.fromMillisecondsSinceEpoch(0),
      ),
      lastLoginAt: firestoreDateOr(
        map['lastLoginAt'],
        DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    List<String>? favoriteCoktailIds,
    List<String>? allergens,
    bool? notifyDrinkReady,
    bool? notifyNewOrder,
    bool? notifyRecapMorning,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      favoriteCoktailIds: favoriteCoktailIds ?? this.favoriteCoktailIds,
      allergens: allergens ?? this.allergens,
      notifyDrinkReady: notifyDrinkReady ?? this.notifyDrinkReady,
      notifyNewOrder: notifyNewOrder ?? this.notifyNewOrder,
      notifyRecapMorning: notifyRecapMorning ?? this.notifyRecapMorning,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
