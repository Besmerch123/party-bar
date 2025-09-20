enum PartyStatus { active, paused, ended }

class Party {
  final String id;
  final String name;
  final String hostId;
  final String hostName;
  final List<String> availableCocktailIds;
  final String joinCode;
  final PartyStatus status;
  final DateTime createdAt;
  final DateTime? endedAt;
  final int totalOrders;
  final String? description;

  const Party({
    required this.id,
    required this.name,
    required this.hostId,
    required this.hostName,
    required this.availableCocktailIds,
    required this.joinCode,
    this.status = PartyStatus.active,
    required this.createdAt,
    this.endedAt,
    this.totalOrders = 0,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'hostId': hostId,
      'hostName': hostName,
      'availableCocktailIds': availableCocktailIds,
      'joinCode': joinCode,
      'status': status.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'endedAt': endedAt?.millisecondsSinceEpoch,
      'totalOrders': totalOrders,
      'description': description,
    };
  }

  factory Party.fromMap(Map<String, dynamic> map) {
    return Party(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      hostId: map['hostId'] ?? '',
      hostName: map['hostName'] ?? '',
      availableCocktailIds: List<String>.from(
        map['availableCocktailIds'] ?? [],
      ),
      joinCode: map['joinCode'] ?? '',
      status: PartyStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PartyStatus.active,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      endedAt: map['endedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endedAt'])
          : null,
      totalOrders: map['totalOrders']?.toInt() ?? 0,
      description: map['description'],
    );
  }

  Party copyWith({
    String? id,
    String? name,
    String? hostId,
    String? hostName,
    List<String>? availableCocktailIds,
    String? joinCode,
    PartyStatus? status,
    DateTime? createdAt,
    DateTime? endedAt,
    int? totalOrders,
    String? description,
  }) {
    return Party(
      id: id ?? this.id,
      name: name ?? this.name,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      availableCocktailIds: availableCocktailIds ?? this.availableCocktailIds,
      joinCode: joinCode ?? this.joinCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
      totalOrders: totalOrders ?? this.totalOrders,
      description: description ?? this.description,
    );
  }
}
