import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:party_bar/models/shared_types.dart';
import 'package:party_bar/providers/locale_provider.dart';

/// `followsSystem` and `setFollowSystem` — the half of Flow 09 screen 04
/// that never reaches a widget: a manual pick always wins, and only the
/// switch itself ever hands the choice back to the device.

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('followsSystem', () {
    test('is true out of the box, before anyone has picked a language', () async {
      final locale = LocaleProvider();
      await locale.initialize();

      expect(locale.followsSystem, isTrue);
      expect(locale.currentLocale, SupportedLocale.en);
    });

    test('a saved manual pick from before the flag existed reads as off', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'uk'});

      final locale = LocaleProvider();
      await locale.initialize();

      expect(
        locale.followsSystem,
        isFalse,
        reason: 'a locale was saved by hand before this flag shipped',
      );
      expect(locale.currentLocale, SupportedLocale.uk);
    });
  });

  group('setLocale', () {
    test('a manual pick always turns followsSystem off', () async {
      final locale = LocaleProvider();
      await locale.initialize();
      expect(locale.followsSystem, isTrue);

      await locale.setLocale(SupportedLocale.uk);

      expect(locale.followsSystem, isFalse);
      expect(locale.currentLocale, SupportedLocale.uk);

      final fresh = LocaleProvider();
      await fresh.initialize();
      expect(fresh.followsSystem, isFalse, reason: 'the manual pick survives a fresh provider');
      expect(fresh.currentLocale, SupportedLocale.uk);
    });
  });

  group('setFollowSystem', () {
    test('turning it on immediately adopts the device locale', () async {
      final locale = LocaleProvider();
      await locale.initialize();
      await locale.setLocale(SupportedLocale.uk);

      await locale.setFollowSystem(true, deviceLocale: const Locale('en'));

      expect(locale.followsSystem, isTrue);
      expect(locale.currentLocale, SupportedLocale.en);
    });

    test('turning it off leaves the language exactly where it was', () async {
      final locale = LocaleProvider();
      await locale.initialize();
      expect(locale.followsSystem, isTrue);
      expect(locale.currentLocale, SupportedLocale.en);

      await locale.setFollowSystem(false, deviceLocale: const Locale('uk'));

      expect(locale.followsSystem, isFalse);
      expect(
        locale.currentLocale,
        SupportedLocale.en,
        reason: 'switching the flag off never itself changes the language showing',
      );
    });

    test('a later manual pick wins over "follow my phone"', () async {
      final locale = LocaleProvider();
      await locale.initialize();
      // Off then on again, so this actually exercises the switch flipping on
      // rather than a no-op against the already-true default.
      await locale.setFollowSystem(false, deviceLocale: const Locale('en'));
      await locale.setFollowSystem(true, deviceLocale: const Locale('uk'));
      expect(locale.currentLocale, SupportedLocale.uk);

      await locale.setLocale(SupportedLocale.en);

      expect(locale.followsSystem, isFalse);
      expect(locale.currentLocale, SupportedLocale.en);

      // The device staying Ukrainian must not pull it back — the manual pick
      // is the one that sticks until the switch is flipped on again by hand.
      final fresh = LocaleProvider();
      await fresh.initialize();
      expect(fresh.followsSystem, isFalse);
      expect(fresh.currentLocale, SupportedLocale.en);
    });

    test('setting the flag to what it already is does nothing', () async {
      final locale = LocaleProvider();
      await locale.initialize();

      var notified = 0;
      locale.addListener(() => notified++);

      await locale.setFollowSystem(true, deviceLocale: const Locale('en'));

      expect(notified, 0);
    });
  });
}
