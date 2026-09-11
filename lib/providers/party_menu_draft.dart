import 'package:flutter/foundation.dart';

import '../models/cocktail.dart';

/// Flow 05 · screens 03-06 — the menu being built for a draft party.
///
/// One selection shared by the grid, search and the full list, so a drink
/// picked in one shows as picked in the others. It holds whole cocktails,
/// not just ids, so the draft screen can say what is short without fetching
/// anything a second time. Order is the order drinks were picked in.
class PartyMenuDraft extends ChangeNotifier {
  PartyMenuDraft({Iterable<Cocktail> initial = const []}) {
    for (final cocktail in initial) {
      _picked[cocktail.id] = cocktail;
    }
  }

  final Map<String, Cocktail> _picked = {};

  List<Cocktail> get cocktails => List.unmodifiable(_picked.values);

  List<String> get ids => List.unmodifiable(_picked.keys);

  int get count => _picked.length;

  bool get isEmpty => _picked.isEmpty;

  bool contains(String id) => _picked.containsKey(id);

  void add(Cocktail cocktail) {
    if (_picked.containsKey(cocktail.id)) return;
    _picked[cocktail.id] = cocktail;
    notifyListeners();
  }

  void remove(String id) {
    if (_picked.remove(id) != null) notifyListeners();
  }

  void toggle(Cocktail cocktail) =>
      contains(cocktail.id) ? remove(cocktail.id) : add(cocktail);
}
