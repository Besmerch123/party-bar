import 'shared_types.dart';

/// Flow 06 — one order is one drink. A round of several drinks is several
/// orders sharing a [CocktailOrder.roundId], so the host pours them one at a
/// time and half a round can be ready before the rest.
///
/// There is no approval step: an order is born [pending] ("in line") and
/// only the host moves it — [preparing] (pouring), [ready] (on the counter),
/// [delivered] (served). [cancelled] is the one state either side can reach,
/// and [CocktailOrder.cancelReason] says who and why.
enum OrderStatus { pending, preparing, ready, delivered, cancelled }

/// Why an order left the queue without being served.
enum CancelReason {
  /// The guest pulled it out before pouring started.
  guest,

  /// The host skipped it — "can't make it", or "cancel order" mid-pour.
  host,

  /// The host ran out of something it needs. Carries the ingredient, so the
  /// guest's apology can name it and offer a swap.
  outOfStock,

  /// Still waiting when the party ended.
  partyEnded,
}

class CocktailOrder {
  final String id;
  final String partyId;
  final String cocktailId;

  /// Who sent it — the name the host shouts, whoever the drink is for.
  final String guestName;

  /// The sending phone. Guests have no account, so this is a per-device id
  /// (see `GuestIdentity`); orders older than Flow 06 carry none.
  final String? guestId;

  /// The guest's note — "heavy on the lime, no straw". Stored under the
  /// pre-Flow-06 `specialRequests` key.
  final String? specialRequests;

  final OrderStatus status;
  final DateTime createdAt;

  /// Pouring started.
  final DateTime? preparedAt;

  /// Put on the counter.
  final DateTime? readyAt;
  final DateTime? deliveredAt;

  /// Every order sent in one tap shares this.
  final String? roundId;

  /// A friend the drink is for. Null is the sender themself.
  final String? forName;

  /// The last time the host buzzed the guest about this order. Ready sets it,
  /// "Buzz again" bumps it; the guest's phone buzzes whenever it moves.
  final DateTime? buzzedAt;

  final DateTime? cancelledAt;
  final CancelReason? cancelReason;

  /// Set with [CancelReason.outOfStock].
  final String? outOfIngredientId;
  final I18nField? outOfIngredientTitle;

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
    this.readyAt,
    this.deliveredAt,
    this.roundId,
    this.forName,
    this.buzzedAt,
    this.cancelledAt,
    this.cancelReason,
    this.outOfIngredientId,
    this.outOfIngredientTitle,
  });

  /// The note, trimmed, or null when there is nothing worth printing.
  String? get note {
    final trimmed = specialRequests?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  /// For somebody other than the sender.
  bool get isForFriend => forName != null && forName!.trim().isNotEmpty;

  bool get isPending => status == OrderStatus.pending;
  bool get isPreparing => status == OrderStatus.preparing;
  bool get isReady => status == OrderStatus.ready;
  bool get isDelivered => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;

  /// Still in the host's hands: in line, pouring, or on the counter.
  bool get isOpen => isPending || isPreparing || isReady;

  /// The guest can still pull it — the door closes when pouring starts.
  bool get canGuestCancel => isPending;

  bool get wasPulledForStock =>
      isCancelled && cancelReason == CancelReason.outOfStock;

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
      'readyAt': readyAt?.millisecondsSinceEpoch,
      'deliveredAt': deliveredAt?.millisecondsSinceEpoch,
      'roundId': roundId,
      'forName': forName,
      'buzzedAt': buzzedAt?.millisecondsSinceEpoch,
      'cancelledAt': cancelledAt?.millisecondsSinceEpoch,
      'cancelReason': cancelReason?.name,
      'outOfIngredientId': outOfIngredientId,
      'outOfIngredientTitle': outOfIngredientTitle,
    };
  }

  /// Dates arrive as whatever Firestore last wrote for that field — a
  /// `Timestamp` from `FieldValue.serverTimestamp()`, or epoch millis from a
  /// `toMap()` — [firestoreDate] takes either.
  factory CocktailOrder.fromMap(Map<String, dynamic> map) {
    final title = map['outOfIngredientTitle'];

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
      createdAt: firestoreDateOr(
        map['createdAt'],
        DateTime.fromMillisecondsSinceEpoch(0),
      ),
      preparedAt: firestoreDate(map['preparedAt']),
      readyAt: firestoreDate(map['readyAt']),
      deliveredAt: firestoreDate(map['deliveredAt']),
      roundId: map['roundId'],
      forName: map['forName'],
      buzzedAt: firestoreDate(map['buzzedAt']),
      cancelledAt: firestoreDate(map['cancelledAt']),
      cancelReason: CancelReason.values
          .where((reason) => reason.name == map['cancelReason'])
          .firstOrNull,
      outOfIngredientId: map['outOfIngredientId'],
      outOfIngredientTitle: title is Map ? Map<String, String>.from(title) : null,
    );
  }

  CocktailOrder copyWith({
    OrderStatus? status,
    DateTime? preparedAt,
    DateTime? readyAt,
    DateTime? deliveredAt,
    DateTime? buzzedAt,
    DateTime? cancelledAt,
    CancelReason? cancelReason,
  }) {
    return CocktailOrder(
      id: id,
      partyId: partyId,
      cocktailId: cocktailId,
      guestName: guestName,
      guestId: guestId,
      specialRequests: specialRequests,
      status: status ?? this.status,
      createdAt: createdAt,
      preparedAt: preparedAt ?? this.preparedAt,
      readyAt: readyAt ?? this.readyAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      roundId: roundId,
      forName: forName,
      buzzedAt: buzzedAt ?? this.buzzedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelReason: cancelReason ?? this.cancelReason,
      outOfIngredientId: outOfIngredientId,
      outOfIngredientTitle: outOfIngredientTitle,
    );
  }
}

/// One drink in a round that has not been sent yet.
class RoundItem {
  const RoundItem({required this.cocktailId, this.forName, this.note});

  final String cocktailId;

  /// Null is "me".
  final String? forName;
  final String? note;
}
