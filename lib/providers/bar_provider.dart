import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bar.dart';
import '../models/ingredient.dart';
import '../models/onboarding.dart';

/// The shelf, on the device.
///
/// Flow 01 collected a few bottles before an account existed, and flow 02
/// spends them: "makeable with my bar" is free, signed out, and is the reason
/// to come back. So the shelf lives here — in [barKey] form, which survives
/// the catalogue being re-seeded under different document ids — and auth later
/// claims it rather than owning it.
class BarProvider extends ChangeNotifier {
  static const _shelfKey = 'bar_shelf';

  /// The key flow 01 writes. Read once, to seed a shelf that has never been
  /// saved; after that the two drift apart and this one wins.
  static const _onboardingBottlesKey = 'onboarding_bottles';

  final Set<String> _keys = {};
  bool _isInitialized = false;

  /// Normalized bottle keys. Compare against [ingredientKeys], never raw ids.
  Set<String> get shelf => Set.unmodifiable(_keys);

  bool get isInitialized => _isInitialized;

  bool get isEmpty => _keys.isEmpty;

  int get bottleCount => _keys.length;

  bool holds(Ingredient ingredient) =>
      ingredientKeys(ingredient).any(_keys.contains);

  bool holdsKey(String raw) => _keys.contains(barKey(raw));

  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_shelfKey);

    if (saved == null) {
      // First run after onboarding: adopt whatever was ticked there. The
      // starter catalogue is the only guard — an id it does not know about
      // cannot have come from that screen.
      final knownIds = kStarterBottles.map((bottle) => bottle.id).toSet();
      final seeded = (prefs.getStringList(_onboardingBottlesKey) ?? const [])
          .where(knownIds.contains)
          .map(barKey);
      _keys.addAll(seeded);
      await _persist();
    } else {
      _keys.addAll(saved.map(barKey));
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> add(String raw) async {
    if (!_keys.add(barKey(raw))) return;
    notifyListeners();
    await _persist();
  }

  Future<void> addIngredient(Ingredient ingredient) =>
      add(ingredient.slug ?? ingredient.id);

  Future<void> remove(String raw) async {
    if (!_keys.remove(barKey(raw))) return;
    notifyListeners();
    await _persist();
  }

  Future<void> toggle(String raw) =>
      holdsKey(raw) ? remove(raw) : add(raw);

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_shelfKey, _keys.toList(growable: false));
  }
}
