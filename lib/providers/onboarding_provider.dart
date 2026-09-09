import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/onboarding.dart';

/// Holds what the first run collected — a vibe and a few bottles — and keeps
/// it on the device.
///
/// Flow 01 asks for no account, so nothing here touches Firestore. When auth
/// lands, the claiming user reads this state once and uploads it; that is why
/// the getters below are all derived rather than cached.
class OnboardingProvider extends ChangeNotifier {
  static const _vibesKey = 'onboarding_vibes';
  static const _bottlesKey = 'onboarding_bottles';

  final Set<DrinkVibe> _vibes = {};
  final Set<String> _bottleIds = {};
  bool _isInitialized = false;

  Set<DrinkVibe> get vibes => Set.unmodifiable(_vibes);
  Set<String> get bottleIds => Set.unmodifiable(_bottleIds);
  bool get isInitialized => _isInitialized;

  int get selectedBottleCount => _bottleIds.length;

  bool isVibeSelected(DrinkVibe vibe) => _vibes.contains(vibe);
  bool isBottleSelected(String id) => _bottleIds.contains(id);

  /// Drinks the current shelf can already make.
  ///
  /// A stand-in for the recipe-coverage query that does not exist yet: each
  /// bottle contributes its own [StarterBottle.unlocks], and an empty shelf
  /// pours nothing.
  int get pourableCount => kStarterBottles
      .where((bottle) => _bottleIds.contains(bottle.id))
      .fold(0, (total, bottle) => total + bottle.unlocks);

  /// The unselected bottle that would add the most, or null once the shelf
  /// holds everything the starter catalogue knows about.
  StarterBottle? get bestUnlock {
    final remaining = kStarterBottles
        .where((bottle) => !_bottleIds.contains(bottle.id))
        .toList();
    if (remaining.isEmpty) return null;

    remaining.sort((a, b) => b.unlocks.compareTo(a.unlocks));
    return remaining.first;
  }

  /// Progress towards [kStarterBottleTarget], clamped to 1.0 so a generous
  /// shelf does not overflow the bar.
  double get stockingProgress =>
      (_bottleIds.length / kStarterBottleTarget).clamp(0.0, 1.0);

  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    final savedVibes = prefs.getStringList(_vibesKey) ?? const [];
    _vibes
      ..clear()
      ..addAll(
        savedVibes
            .map(
              (name) => DrinkVibe.values
                  .where((vibe) => vibe.name == name)
                  .firstOrNull,
            )
            .whereType<DrinkVibe>(),
      );

    final knownIds = kStarterBottles.map((bottle) => bottle.id).toSet();
    _bottleIds
      ..clear()
      ..addAll(
        (prefs.getStringList(_bottlesKey) ?? const []).where(knownIds.contains),
      );

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> toggleVibe(DrinkVibe vibe) async {
    if (!_vibes.remove(vibe)) _vibes.add(vibe);
    notifyListeners();
    await _persist(
      _vibesKey,
      _vibes.map((vibe) => vibe.name).toList(growable: false),
    );
  }

  Future<void> toggleBottle(String id) async {
    if (!_bottleIds.remove(id)) _bottleIds.add(id);
    notifyListeners();
    await _persist(_bottlesKey, _bottleIds.toList(growable: false));
  }

  Future<void> _persist(String key, List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, values);
  }
}
