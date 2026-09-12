import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/menu_preset.dart';

/// Flow 08 · screen 05 — where saved menus live.
///
/// On the device, not the account: a preset is a convenience for the phone
/// that hosts, and asking someone to be signed in before they can keep their
/// own menu would be the app charging rent on its own suggestion. Newest
/// first, because the menu a host wants back is usually the last one.
abstract final class MenuPresets {
  static const _key = 'menu_presets';

  /// How many a phone keeps. Beyond this the oldest falls off — a preset
  /// list nobody prunes stops being a shortcut.
  static const max = 12;

  static Future<List<MenuPreset>> list() async {
    final prefs = await SharedPreferences.getInstance();
    return _decode(prefs.getString(_key));
  }

  /// Returns the saved preset. An empty menu is not worth keeping and is
  /// rejected rather than written as a preset with nothing in it.
  static Future<MenuPreset?> save({
    required String name,
    required List<String> cocktailIds,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || cocktailIds.isEmpty) return null;

    final preset = MenuPreset(
      id: const Uuid().v4(),
      name: trimmed,
      cocktailIds: List<String>.of(cocktailIds),
      savedAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final presets = _decode(prefs.getString(_key))
      ..insert(0, preset);
    await prefs.setString(
      _key,
      jsonEncode([
        for (final p in presets.take(max)) p.toJson(),
      ]),
    );
    return preset;
  }

  static Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final presets = _decode(prefs.getString(_key))
      ..removeWhere((preset) => preset.id == id);
    await prefs.setString(
      _key,
      jsonEncode([for (final p in presets) p.toJson()]),
    );
  }

  /// A list that will not decode is a list nobody can fix from inside the
  /// app, so it reads as empty rather than throwing on every launch.
  static List<MenuPreset> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return [
        for (final json in decoded)
          MenuPreset.fromJson(Map<String, dynamic>.from(json as Map)),
      ];
    } catch (e) {
      debugPrint('Could not read the saved menus: $e');
      return [];
    }
  }
}
