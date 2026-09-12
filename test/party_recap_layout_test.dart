import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:party_bar/models/models.dart';
import 'package:party_bar/services/menu_presets.dart';
import 'package:party_bar/widgets/party/end_party_sheet.dart';
import 'package:party_bar/widgets/party/recap_bits.dart';
import 'package:party_bar/widgets/party/save_menu_sheet.dart';
import 'package:party_bar/widgets/party/share_card.dart';

import 'support/harness.dart';

/// Flow 08 — the pieces the recap is drawn from, with fake data, at a couple
/// of sizes and a large text scale. Nothing here touches Firebase: the recap
/// screens themselves stream a party's orders and are covered by the
/// arithmetic in party_recap_test.dart plus the widgets below.

const _sizes = testSizes;
const _textScales = standardTextScales;

final _live = DateTime(2026, 9, 4, 21, 0);

Party _party() => Party(
  id: 'p1',
  name: "Kate's Birthday",
  hostId: 'host1',
  hostName: 'Kate Malone',
  availableCocktailIds: const ['cosmo', 'gt'],
  joinCode: 'KATE01',
  status: PartyStatus.active,
  createdAt: _live.subtract(const Duration(hours: 2)),
  wentLiveAt: _live,
);

CocktailOrder _order(
  String id, {
  int minute = 0,
  OrderStatus status = OrderStatus.delivered,
  String guestName = 'Sam',
  String guestId = 'sam-phone',
}) => CocktailOrder(
  id: id,
  partyId: 'p1',
  cocktailId: 'cosmo',
  guestName: guestName,
  guestId: guestId,
  status: status,
  createdAt: _live.add(Duration(minutes: minute)),
);

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  /// Opens a sheet the way the app does — from a context under a Navigator.
  Future<void> openSheet(
    WidgetTester tester,
    Future<void> Function(BuildContext context) open, {
    Size size = const Size(390, 844),
    double textScale = 1.0,
  }) async {
    await pumpLocaleAware(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => open(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      size: size,
      textScale: textScale,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('01 · closing time', () {
    testWidgets('names whose drinks are still waiting, and offers to pour '
        'them before it offers to close', (tester) async {
      await openSheet(
        tester,
        (context) => showEndPartySheet(
          context,
          party: _party(),
          orders: [
            _order('a', minute: 10),
            _order('b', minute: 50, status: OrderStatus.pending),
            _order(
              'c',
              minute: 55,
              status: OrderStatus.pending,
              guestName: 'Olha',
              guestId: 'olha-phone',
            ),
          ],
        ),
      );

      expect(find.text('Close the bar?'), findsOneWidget);
      expect(
        find.textContaining('Sam and Olha'),
        findsOneWidget,
        reason: 'the sheet names the two people closing would cancel',
      );
      expect(find.text('Pour those 2 first'), findsOneWidget);
      expect(find.text('Close anyway · cancels 2'), findsOneWidget);
      expect(
        find.text('The code stops working the second you close. '
            'Nothing is deleted.'),
        findsOneWidget,
      );
    });

    testWidgets('an empty queue makes closing the primary again', (
      tester,
    ) async {
      await openSheet(
        tester,
        (context) => showEndPartySheet(
          context,
          party: _party(),
          orders: [_order('a', minute: 10)],
        ),
      );

      expect(find.text('Call it a night?'), findsOneWidget);
      expect(find.text('Close the bar'), findsOneWidget);
      expect(find.textContaining('Close anyway'), findsNothing);
    });

    testWidgets('stops listing names once there are too many', (tester) async {
      await openSheet(
        tester,
        (context) => showEndPartySheet(
          context,
          party: _party(),
          orders: [
            for (final (i, name) in ['Sam', 'Olha', 'Marta', 'Jo'].indexed)
              _order(
                '$i',
                minute: 40 + i,
                status: OrderStatus.pending,
                guestName: name,
                guestId: '$name-phone',
              ),
          ],
        ),
      );

      expect(find.textContaining('Sam, Olha and 2 more'), findsOneWidget);
    });
  });

  group('02 · the recap’s pieces', () {
    testWidgets('a tally with no bar still reads as a tally', (tester) async {
      await pumpLocaleAware(
        tester,
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(22),
            child: DrinkTallyRow(
              name: 'Cosmopolitan',
              image: null,
              count: 12,
              share: null,
            ),
          ),
        ),
      );

      expect(find.text('Cosmopolitan'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('a chart of two draws a bar apiece', (tester) async {
      await pumpLocaleAware(
        tester,
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(22),
            child: Column(
              children: [
                DrinkTallyRow(
                  name: 'Cosmopolitan',
                  image: null,
                  count: 12,
                  share: 1,
                  leader: true,
                ),
                DrinkTallyRow(
                  name: 'Gin & Tonic',
                  image: null,
                  count: 6,
                  share: .5,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    });

    testWidgets('stat tiles survive three long labels side by side', (
      tester,
    ) async {
      await pumpLocaleAware(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(22),
            child: RecapStatRow(
              stats: const [
                RecapStat(value: '31', label: 'drinks poured', accent: true),
                RecapStat(value: '3:40', label: 'avg. wait'),
                RecapStat(value: '7', label: 'recipes used'),
              ],
            ),
          ),
        ),
        size: const Size(320, 568),
        textScale: 1.5,
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('03 · the share card', () {
    testWidgets('counts people by default and names nobody', (tester) async {
      await pumpLocaleAware(
        tester,
        const Scaffold(
          body: Center(
            child: ShareCard(
              shape: ShareCardShape.story,
              data: ShareCardData(
                headline: '31 drinks',
                partyLine: "Kate's Birthday · 9 people",
                dateLine: 'Fri 4 Sep, until 01:24',
                chips: ['Cosmopolitan ×12'],
                image: null,
              ),
            ),
          ),
        ),
      );

      expect(find.text('31 drinks'), findsOneWidget);
      expect(find.textContaining('9 people'), findsOneWidget);
      expect(find.textContaining('Sam'), findsNothing);
    });

    testWidgets('names guests only when it is handed names', (tester) async {
      await pumpLocaleAware(
        tester,
        const Scaffold(
          body: Center(
            child: ShareCard(
              shape: ShareCardShape.square,
              data: ShareCardData(
                headline: '31 drinks',
                partyLine: "Kate's Birthday · 9 people",
                dateLine: 'Fri 4 Sep, until 01:24',
                chips: ['Cosmopolitan ×12', '3:40 avg wait'],
                image: null,
                guestNames: 'Sam, Olha, Marta',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Sam, Olha, Marta'), findsOneWidget);
      expect(find.text('3:40 avg wait'), findsOneWidget);
    });
  });

  group('05 · saving the menu', () {
    testWidgets('keeps the recipes, says what it drops, and writes a preset', (
      tester,
    ) async {
      MenuPreset? saved;
      await openSheet(tester, (context) async {
        saved = await showSaveMenuSheet(
          context,
          suggestedName: "Kate's Birthday",
          cocktailIds: const ['cosmo', 'gt', 'orchard'],
        );
      });

      expect(find.text('Keep this menu'), findsOneWidget);
      expect(find.text('3 recipes, same order'), findsOneWidget);
      expect(find.text('Not the name, code or guest list'), findsOneWidget);

      await tester.tap(find.text('Save the menu'));
      await tester.pumpAndSettle();

      expect(saved?.name, "Kate's Birthday");
      expect(saved?.cocktailIds, ['cosmo', 'gt', 'orchard']);
      expect((await MenuPresets.list()).single.name, "Kate's Birthday");
    });

    testWidgets('will not save a menu with no name', (tester) async {
      await openSheet(
        tester,
        (context) => showSaveMenuSheet(
          context,
          suggestedName: '   ',
          cocktailIds: const ['cosmo'],
        ),
      );

      expect(find.text('Give it a name to save it.'), findsOneWidget);

      await tester.tap(find.text('Save the menu'));
      await tester.pumpAndSettle();

      expect(find.text('Keep this menu'), findsOneWidget, reason: 'still open');
      expect(await MenuPresets.list(), isEmpty);
    });

    testWidgets('the picker says so when there is nothing saved', (
      tester,
    ) async {
      await openSheet(tester, (context) => showMenuPresetPicker(context));

      expect(find.text('Your saved menus'), findsOneWidget);
      expect(find.textContaining('Nothing saved yet'), findsOneWidget);
    });
  });

  group('06 · the archive’s pieces', () {
    testWidgets('a night card carries its own numbers', (tester) async {
      await pumpLocaleAware(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(22),
            child: NightHeroCard(
              badge: 'Last night',
              title: "Kate's Birthday",
              drinks: '31 drinks',
              meta: const ['9 guests', '4 Sep'],
              image: null,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('LAST NIGHT'), findsOneWidget);
      expect(find.text('31 DRINKS'), findsOneWidget);
      expect(find.text('9 guests'), findsOneWidget);
    });
  });

  group('layout holds under a narrow phone and a bumped text scale', () {
    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('01 closing time on a $device at ${scale}x text', (
          tester,
        ) async {
          await openSheet(
            tester,
            (context) => showEndPartySheet(
              context,
              party: _party(),
              orders: [
                _order('a', minute: 10),
                _order('b', minute: 50, status: OrderStatus.pending),
              ],
            ),
            size: size,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('05 save the menu on a $device at ${scale}x text', (
          tester,
        ) async {
          await openSheet(
            tester,
            (context) => showSaveMenuSheet(
              context,
              suggestedName: "Kate's Birthday",
              cocktailIds: const ['cosmo', 'gt'],
            ),
            size: size,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
