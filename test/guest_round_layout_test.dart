import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:party_bar/models/models.dart';
import 'package:party_bar/providers/party_cocktails.dart';
import 'package:party_bar/providers/round_draft.dart';
import 'package:party_bar/screens/party/guest/add_to_round_screen.dart';
import 'package:party_bar/theme/theme.dart';
import 'package:party_bar/widgets/party/guest/tonight_tab.dart';
import 'package:party_bar/widgets/party/guest/your_round_sheet.dart';

import 'support/harness.dart';

/// Flow 06 — the guest side's four Tonight states (in line, mixing, ready,
/// pulled) and screens 01/02, laid out with fake data at a couple of sizes
/// and a large text scale. No Firebase: every widget here takes plain data,
/// per the flow's own testability rule.

const _sizes = testSizes;
const _textScales = standardTextScales;

final _t0 = DateTime(2026, 9, 12, 22, 30);

Party _party({PartyStatus status = PartyStatus.active}) => Party(
  id: 'p1',
  name: "Kate's Birthday",
  hostId: 'host1',
  hostName: 'Kate Malone',
  availableCocktailIds: const ['gt', 'cosmo'],
  joinCode: 'KATE01',
  status: status,
  createdAt: _t0.subtract(const Duration(hours: 1)),
  wentLiveAt: _t0.subtract(const Duration(minutes: 30)),
);

Ingredient _ingredient(String id) =>
    Ingredient(id: id, title: {'en': id}, category: IngredientCategory.spirit);

Cocktail _cocktail(
  String id, {
  required String title,
  List<String> ingredients = const ['gin', 'tonic'],
}) => Cocktail(
  id: id,
  title: {'en': title},
  description: const {'en': ''},
  image: '',
  categories: const [],
  ingredients: ingredients.map(_ingredient).toList(),
  equipments: const [],
);

final _gt = _cocktail('gt', title: 'Gin & Tonic', ingredients: const ['gin', 'tonic']);
final _cosmo = _cocktail('cosmo', title: 'Cosmopolitan', ingredients: const ['vodka', 'cranberry']);

CocktailOrder _order(
  String id, {
  int minute = 0,
  OrderStatus status = OrderStatus.pending,
  String cocktailId = 'gt',
  String guestId = 'sam-phone',
  String guestName = 'Sam',
  String? roundId = 'r1',
  String? forName,
  DateTime? readyAt,
  DateTime? preparedAt,
  CancelReason? cancelReason,
  String? outOf,
  I18nField? outOfTitle,
  String? note,
}) => CocktailOrder(
  id: id,
  partyId: 'p1',
  cocktailId: cocktailId,
  guestName: guestName,
  guestId: guestId,
  specialRequests: note,
  status: status,
  createdAt: _t0.add(Duration(minutes: minute)),
  roundId: roundId,
  forName: forName,
  readyAt: readyAt,
  preparedAt: preparedAt,
  cancelReason: cancelReason,
  outOfIngredientId: outOf,
  outOfIngredientTitle: outOfTitle,
);

Future<PartyCocktails> _cocktails() async {
  final byId = {'gt': _gt, 'cosmo': _cosmo};
  final cocktails = PartyCocktails(load: (id) async => byId[id]);
  await cocktails.ensure(byId.keys);
  return cocktails;
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Map<String, List<CocktailOrder>> states() => {
    'in line': [
      _order('a'),
      _order('b', minute: 1, cocktailId: 'cosmo', forName: 'Marta'),
    ],
    'mixing': [
      _order('a', status: OrderStatus.preparing, preparedAt: DateTime.now().subtract(const Duration(seconds: 42))),
      _order('b', minute: 1, cocktailId: 'cosmo', forName: 'Marta'),
    ],
    'ready': [
      _order('a', status: OrderStatus.ready, readyAt: DateTime.now().subtract(const Duration(seconds: 20)), note: 'Heavy on the lime'),
      _order('b', minute: 1, cocktailId: 'cosmo', forName: 'Marta', status: OrderStatus.preparing, preparedAt: DateTime.now()),
    ],
    'pulled': [
      _order(
        'a',
        status: OrderStatus.cancelled,
        cancelReason: CancelReason.outOfStock,
        outOf: 'gin',
        outOfTitle: const {'en': 'Gin'},
      ),
      // Served, not in line: an open round-mate would lead the tab and the
      // apology would never be drawn.
      _order('b', minute: 1, cocktailId: 'cosmo', forName: 'Marta', status: OrderStatus.delivered),
    ],
  };

  group('Tonight tab', () {
    for (final MapEntry(key: state, value: orders) in states().entries) {
      for (final MapEntry(key: device, value: size) in _sizes.entries) {
        for (final scale in _textScales) {
          testWidgets('$state lays out on a $device at ${scale}x text', (tester) async {
            final cocktails = await _cocktails();

            await pumpLocaleAware(
              tester,
              Scaffold(
                backgroundColor: AppColors.ground,
                body: TonightTab(
                  party: _party(),
                  allOrders: orders,
                  myOrders: orders,
                  guestId: 'sam-phone',
                  guestName: 'Sam',
                  cocktails: cocktails,
                  dismissedPulls: const {},
                  onDismissPull: (_) {},
                  onOpenMenu: () {},
                ),
              ),
              size: size,
              textScale: scale,
            );

            expect(tester.takeException(), isNull);
          });
        }
      }
    }

    testWidgets('the arrival view (no round yet) lays out with no drinks ordered', (tester) async {
      final cocktails = await _cocktails();

      await pumpLocaleAware(
        tester,
        Scaffold(
          backgroundColor: AppColors.ground,
          body: TonightTab(
            party: _party(),
            allOrders: const [],
            myOrders: const [],
            guestId: 'sam-phone',
            guestName: 'Sam',
            cocktails: cocktails,
            dismissedPulls: const {},
            onDismissPull: (_) {},
            onOpenMenu: () {},
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text("Kate's Birthday"), findsOneWidget);
    });

    // Screen 13 on a phone went blank: the swap row's filled button took the
    // theme's full width inside a Row. This draws the apology with a real
    // suggestion, so that button is actually laid out.
    testWidgets('sorry, it\'s out draws its swap suggestions', (tester) async {
      final cocktails = await _cocktails();
      final orders = states()['pulled']!;

      await pumpLocaleAware(
        tester,
        Scaffold(
          backgroundColor: AppColors.ground,
          body: TonightTab(
            party: _party(),
            allOrders: orders,
            myOrders: orders,
            guestId: 'sam-phone',
            guestName: 'Sam',
            cocktails: cocktails,
            dismissedPulls: const {},
            onDismissPull: (_) {},
            onOpenMenu: () {},
          ),
        ),
        size: const Size(320, 568),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Cosmopolitan'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });
  });

  group('screen 01 · Add to round', () {
    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('lays out on a $device at ${scale}x text', (tester) async {
          final draft = RoundDraft();
          addTearDown(draft.dispose);

          await pumpLocaleAware(
            tester,
            AddToRoundScreen(
              party: _party(),
              cocktail: _gt,
              draft: draft,
              aheadOfNewOrder: 2,
              orderedTonight: 3,
              guestName: 'Sam',
            ),
            size: size,
            textScale: scale,
          );

          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('Add to round queues the drink and pops', (tester) async {
      final draft = RoundDraft();
      addTearDown(draft.dispose);

      await pumpLocaleAware(
        tester,
        AddToRoundScreen(party: _party(), cocktail: _gt, draft: draft, aheadOfNewOrder: 0, orderedTonight: 0, guestName: 'Sam'),
      );

      await tester.tap(find.text('Add to round'));
      await tester.pumpAndSettle();

      expect(draft.length, 1);
      expect(draft.items.single.cocktailId, 'gt');
    });
  });

  group('screen 02 · Your round', () {
    Future<void> openSheet(WidgetTester tester, RoundDraft draft, PartyCocktails cocktails) async {
      await pumpLocaleAware(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showYourRoundSheet(
                  context,
                  party: _party(),
                  draft: draft,
                  cocktails: cocktails,
                  aheadOfNewOrder: 2,
                  guestId: 'sam-phone',
                  guestName: 'Sam',
                  resolveName: ({int? drinks}) async => 'Sam',
                  paused: false,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('lays out on a $device at ${scale}x text', (tester) async {
          final draft = RoundDraft()
            ..add(cocktailId: 'gt', note: 'Heavy on the lime')
            ..add(cocktailId: 'cosmo', forName: 'Marta');
          addTearDown(draft.dispose);
          final cocktails = await _cocktails();

          tester.view
            ..physicalSize = size
            ..devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await openSheet(tester, draft, cocktails);

          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('removing every row leaves a way out instead of a dead end', (tester) async {
      final draft = RoundDraft()..add(cocktailId: 'gt');
      addTearDown(draft.dispose);
      final cocktails = await _cocktails();

      await openSheet(tester, draft, cocktails);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(draft.isEmpty, isTrue);
      expect(tester.takeException(), isNull);
    });
  });
}
