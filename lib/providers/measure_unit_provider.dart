import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';

/// Flow 09 · screen 05 — the one row in Settings that changes the product.
///
/// Every recipe is written in millilitres; this only ever changes how it is
/// *read*. [MeasureUnit.ml] means "print the recipe as stored" — the default,
/// and the only sane one, since converting ml to ml would just be rounding
/// error for no reason.
class MeasureUnitProvider extends ChangeNotifier {
  static const _key = 'measure_unit';

  MeasureUnit _unit = MeasureUnit.ml;
  bool _isInitialized = false;

  MeasureUnit get unit => _unit;
  bool get isOz => _unit == MeasureUnit.oz;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_key) == MeasureUnit.oz.name) {
      _unit = MeasureUnit.oz;
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setUnit(MeasureUnit unit) async {
    if (_unit == unit) return;

    _unit = unit;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, unit.name);
  }
}
