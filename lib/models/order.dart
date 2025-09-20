enum OrderStatus { pending, preparing, ready, delivered, cancelled }

class CocktailOrder {
  final String id;
  final String partyId;
  final String cocktailId;
  final String guestName;
  final String? guestId;
  final String? specialRequests;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? preparedAt;
  final DateTime? deliveredAt;
  final int priority;

  const CocktailOrder({
    required this.id,
    required this.partyId,
    required this.cocktailId,
    required this.guestName,
    this.guestId,
    this.specialRequests,
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.preparedAt,
    this.deliveredAt,
    this.priority = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'partyId': partyId,
      'cocktailId': cocktailId,
      'guestName': guestName,
      'guestId': guestId,
      'specialRequests': specialRequests,
      'status': status.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'preparedAt': preparedAt?.millisecondsSinceEpoch,
      'deliveredAt': deliveredAt?.millisecondsSinceEpoch,
      'priority': priority,
    };
  }

  factory CocktailOrder.fromMap(Map<String, dynamic> map) {
    return CocktailOrder(
      id: map['id'] ?? '',
      partyId: map['partyId'] ?? '',
      cocktailId: map['cocktailId'] ?? '',
      guestName: map['guestName'] ?? '',
      guestId: map['guestId'],
      specialRequests: map['specialRequests'],
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      preparedAt: map['preparedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['preparedAt'])
          : null,
      deliveredAt: map['deliveredAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deliveredAt'])
          : null,
      priority: map['priority']?.toInt() ?? 0,
    );
  }

  CocktailOrder copyWith({
    String? id,
    String? partyId,
    String? cocktailId,
    String? guestName,
    String? guestId,
    String? specialRequests,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? preparedAt,
    DateTime? deliveredAt,
    int? priority,
  }) {
    return CocktailOrder(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      cocktailId: cocktailId ?? this.cocktailId,
      guestName: guestName ?? this.guestName,
      guestId: guestId ?? this.guestId,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      preparedAt: preparedAt ?? this.preparedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      priority: priority ?? this.priority,
    );
  }
}
