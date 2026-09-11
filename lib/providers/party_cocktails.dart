import 'package:flutter/foundation.dart';

import '../data/cocktail_repository.dart';
import '../models/models.dart';

/// Flow 06 — the drinks a party's orders point at, loaded once and kept.
///
/// Both phones need more than the menu: an order for a drink the host has
/// since pulled still has to show its name and photo in the queue and in the
/// guest's round. So this caches by id rather than by menu, and [ensure] is
/// cheap to call on every stream event.
class PartyCocktails extends ChangeNotifier {
  PartyCocktails({Future<Cocktail?> Function(String id)? load})
    : _loadOverride = load;

  final Future<Cocktail?> Function(String id)? _loadOverride;
  CocktailRepository? _repository;

  final Map<String, Cocktail> _byId = {};
  final Set<String> _inFlight = {};
  final Set<String> _missing = {};

  Cocktail? byId(String id) => _byId[id];

  /// [ids] in their own order, skipping any not loaded (yet, or ever).
  List<Cocktail> resolve(Iterable<String> ids) => [
    for (final id in ids)
      if (_byId[id] case final cocktail?) cocktail,
  ];

  /// True once every one of [ids] has loaded or failed.
  bool isSettled(Iterable<String> ids) =>
      ids.every((id) => _byId.containsKey(id) || _missing.contains(id));

  Future<void> ensure(Iterable<String> ids) async {
    final wanted = ids
        .where(
          (id) =>
              id.isNotEmpty &&
              !_byId.containsKey(id) &&
              !_missing.contains(id) &&
              !_inFlight.contains(id),
        )
        .toSet();
    if (wanted.isEmpty) return;

    _inFlight.addAll(wanted);
    final load =
        _loadOverride ?? (_repository ??= CocktailRepository()).getCocktail;

    await Future.wait(
      wanted.map((id) async {
        try {
          final cocktail = await load(id);
          if (cocktail == null) {
            _missing.add(id);
          } else {
            _byId[id] = cocktail;
          }
        } catch (e) {
          debugPrint('Could not load cocktail $id: $e');
          _missing.add(id);
        } finally {
          _inFlight.remove(id);
        }
      }),
    );
    notifyListeners();
  }
}
