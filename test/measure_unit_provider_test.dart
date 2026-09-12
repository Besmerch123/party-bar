import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:party_bar/models/recipe.dart';
import 'package:party_bar/providers/measure_unit_provider.dart';

/// Flow 09 · screen 05's state — the one setting that changes the product.
/// Nothing here touches Firebase: this is a `shared_preferences` round-trip,
/// same as `bar_provider_test.dart`'s persistence group.

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('initialize', () {
    test('defaults to ml with nothing saved', () async {
      final provider = MeasureUnitProvider();
      await provider.initialize();

      expect(provider.unit, MeasureUnit.ml);
      expect(provider.isOz, isFalse);
      expect(provider.isInitialized, isTrue);
    });

    test('loads oz when that is what was last saved', () async {
      SharedPreferences.setMockInitialValues({'measure_unit': 'oz'});

      final provider = MeasureUnitProvider();
      await provider.initialize();

      expect(provider.unit, MeasureUnit.oz);
      expect(provider.isOz, isTrue);
    });

    test('only ever runs once', () async {
      final provider = MeasureUnitProvider();
      await provider.initialize();
      await provider.setUnit(MeasureUnit.oz);

      // A second initialize must not stomp the choice already made.
      await provider.initialize();
      expect(provider.unit, MeasureUnit.oz);
    });
  });

  group('setUnit', () {
    test('flips the unit, notifies, and persists it for the next launch', () async {
      final provider = MeasureUnitProvider();
      await provider.initialize();

      var notified = 0;
      provider.addListener(() => notified++);

      await provider.setUnit(MeasureUnit.oz);

      expect(provider.unit, MeasureUnit.oz);
      expect(notified, 1);

      final fresh = MeasureUnitProvider();
      await fresh.initialize();
      expect(fresh.unit, MeasureUnit.oz, reason: 'the pick survives a fresh provider');
    });

    test('setting the unit it already is does nothing', () async {
      final provider = MeasureUnitProvider();
      await provider.initialize();

      var notified = 0;
      provider.addListener(() => notified++);

      await provider.setUnit(MeasureUnit.ml);

      expect(notified, 0);
    });
  });
}
