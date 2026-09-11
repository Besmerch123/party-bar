import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Flow 06 · screens 01–02 — the round a guest is building, before it is
/// sent. Lives for as long as the guest party screen does; nothing here
/// touches Firestore until the send.
class RoundDraft extends ChangeNotifier {
  final List<RoundItem> _items = [];
  final List<String> _friends = [];

  List<RoundItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get length => _items.length;

  /// Names this guest has ordered for tonight, most recent first — the
  /// chips after "Me" in "who's it for".
  List<String> get friends => List.unmodifiable(_friends);

  /// Adds [count] of the same drink, each queued on its own.
  void add({
    required String cocktailId,
    String? forName,
    String? note,
    int count = 1,
  }) {
    final friend = forName?.trim();
    final trimmedNote = note?.trim();
    for (var i = 0; i < count; i++) {
      _items.add(
        RoundItem(
          cocktailId: cocktailId,
          forName: friend == null || friend.isEmpty ? null : friend,
          note: trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote,
        ),
      );
    }
    if (friend != null && friend.isNotEmpty) rememberFriend(friend);
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  void rememberFriend(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _friends
      ..removeWhere((f) => f.toLowerCase() == trimmed.toLowerCase())
      ..insert(0, trimmed);
  }

  /// After a successful send.
  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
