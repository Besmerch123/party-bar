class User {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final List<String> favoriteCoktailIds;
  final List<String> allergens;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const User({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.favoriteCoktailIds = const [],
    this.allergens = const [],
    this.notificationsEnabled = true,
    required this.createdAt,
    required this.lastLoginAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'favoriteCoktailIds': favoriteCoktailIds,
      'allergens': allergens,
      'notificationsEnabled': notificationsEnabled,
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
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastLoginAt: DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt'] ?? 0),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    List<String>? favoriteCoktailIds,
    List<String>? allergens,
    bool? notificationsEnabled,
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
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
