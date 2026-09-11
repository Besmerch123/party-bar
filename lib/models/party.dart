/// Flow 05. A party starts as a [draft] — its code dead, nobody can join —
/// and only [PartyService.goLive] opens it. [active] and [paused] are both
/// "live": the code works and the host has one bar to run. [ended] is the
/// only one-way door. [idle] predates the draft and is read as one.
enum PartyStatus { draft, active, paused, ended, idle }

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

  /// Null is "tonight, open-ended" — the design's default.
  final DateTime? scheduledFor;

  /// When Go live was tapped; the live chip counts from here.
  final DateTime? wentLiveAt;

  /// When the bar was last paused, for "BAR PAUSED · 6M".
  final DateTime? pausedAt;

  const Party({
    required this.id,
    required this.name,
    required this.hostId,
    required this.hostName,
    required this.availableCocktailIds,
    required this.joinCode,
    this.status = PartyStatus.draft,
    required this.createdAt,
    this.endedAt,
    this.totalOrders = 0,
    this.description,
    this.scheduledFor,
    this.wentLiveAt,
    this.pausedAt,
  });

  bool get isDraft => status == PartyStatus.draft || status == PartyStatus.idle;

  /// The code works and orders can land — paused counts, because the queue
  /// is still the host's to pour.
  bool get isLive => status == PartyStatus.active || status == PartyStatus.paused;

  bool get isEnded => status == PartyStatus.ended;

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
      'scheduledFor': scheduledFor?.millisecondsSinceEpoch,
      'wentLiveAt': wentLiveAt?.millisecondsSinceEpoch,
      'pausedAt': pausedAt?.millisecondsSinceEpoch,
    };
  }

  factory Party.fromMap(Map<String, dynamic> map) {
    DateTime? optionalDate(String key) => map[key] != null
        ? DateTime.fromMillisecondsSinceEpoch(map[key])
        : null;

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
      endedAt: optionalDate('endedAt'),
      totalOrders: map['totalOrders']?.toInt() ?? 0,
      description: map['description'],
      scheduledFor: optionalDate('scheduledFor'),
      wentLiveAt: optionalDate('wentLiveAt'),
      pausedAt: optionalDate('pausedAt'),
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
    DateTime? scheduledFor,
    bool clearScheduledFor = false,
    DateTime? wentLiveAt,
    DateTime? pausedAt,
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
      scheduledFor: clearScheduledFor
          ? null
          : scheduledFor ?? this.scheduledFor,
      wentLiveAt: wentLiveAt ?? this.wentLiveAt,
      pausedAt: pausedAt ?? this.pausedAt,
    );
  }
}
