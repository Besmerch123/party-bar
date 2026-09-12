import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:party_bar/models/models.dart';
import 'package:party_bar/providers/party_cocktails.dart';
import 'package:party_bar/screens/party/guest/party_ended_screen.dart';
import 'package:party_bar/widgets/party/guest/guest_name_gate.dart';
import 'package:party_bar/widgets/party/guest/paused_bar.dart';
import 'package:party_bar/widgets/party/guest/your_round_tab.dart';
import 'package:party_bar/widgets/party/join_code_field.dart';

import 'support/harness.dart';

/// Flow 07 — the door's own screens with fake data, at a couple of sizes and
/// a large text scale. Nothing here touches Firebase: the join screen itself
/// resolves a code through [PartyService] and is covered by the pieces it is
/// built from instead.

const _sizes = testSizes;
const _textScales = standardTextScales;

final _t0 = DateTime(2026, 9, 12, 22, 30);

Party _party({PartyStatus status = PartyStatus.active}) => Party(
  id: 'p1',
  name: "Kate's Birthday",
  hostId: 'host1',
  hostName: 'Kate Malone',
  availableCocktailIds: const ['gt'],
  joinCode: 'KATE01',
  status: status,
  createdAt: _t0.subtract(const Duration(hours: 4)),
  wentLiveAt: _t0.subtract(const Duration(hours: 3)),
  endedAt: status == PartyStatus.ended ? _t0 : null,
);

CocktailOrder _order(
  String id, {
  int minute = 0,
  OrderStatus status = OrderStatus.delivered,
  String? forName,
}) => CocktailOrder(
  id: id,
  partyId: 'p1',
  cocktailId: 'gt',
  guestName: 'Sam',
  guestId: 'sam-phone',
  status: status,
  createdAt: _t0.subtract(Duration(hours: 3, minutes: -minute)),
  roundId: 'r1',
  forName: forName,
);

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('01 · the code field', () {
    testWidgets('draws one box per character, filled as far as it is typed', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'K7Q');
      addTearDown(controller.dispose);
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await pumpLocaleAware(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(22),
            child: JoinCodeField(controller: controller, focusNode: focusNode),
          ),
        ),
      );

      for (final character in ['K', '7', 'Q']) {
        expect(find.text(character), findsOneWidget);
      }
      expect(find.text('M'), findsNothing);
    });

    testWidgets('uppercases, strips punctuation and stops at six', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await pumpLocaleAware(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(22),
            child: JoinCodeField(controller: controller, focusNode: focusNode),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'k7-q m4px');
      await tester.pump();

      expect(controller.text, 'K7QM4P');
    });

    testWidgets('a pasted join link becomes the code it carries', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await pumpLocaleAware(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(22),
            child: JoinCodeField(controller: controller, focusNode: focusNode),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), partyJoinLink('K7QM4P'));
      await tester.pump();

      expect(controller.text, 'K7QM4P');
    });
  });

  group('03 · the name gate', () {
    testWidgets('refuses to send on an empty name or an unticked 18+', (
      tester,
    ) async {
      String? committed;

      await pumpLocaleAware(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  committed = await showGuestNameGate(
                    context,
                    hostName: 'Kate',
                    drinks: 2,
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Nothing typed, nothing ticked: the send says what is missing rather
      // than closing on a guest with no name.
      await tester.tap(find.text('Send to the bar · 2 drinks'));
      await tester.pumpAndSettle();
      expect(find.text('A name is all we need.'), findsOneWidget);
      expect(find.text('Tick the line above to send.'), findsOneWidget);
      expect(committed, isNull);

      // A name on its own is still not enough — 18+ rides the same tap.
      await tester.enterText(find.byType(TextField), 'Sam');
      await tester.tap(find.text('Send to the bar · 2 drinks'));
      await tester.pumpAndSettle();
      expect(find.text("I'm over 18 and drinking responsibly"), findsOneWidget);
      expect(committed, isNull);

      await tester.tap(find.text("I'm over 18 and drinking responsibly"));
      await tester.pump();
      await tester.tap(find.text('Send to the bar · 2 drinks'));
      await tester.pumpAndSettle();
      expect(committed, 'Sam');
    });

    testWidgets('the rename has nothing to send and nothing to confirm', (
      tester,
    ) async {
      await pumpLocaleAware(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showGuestNameGate(
                  context,
                  hostName: 'Kate',
                  drinks: null,
                  initialName: 'Sam',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);
      expect(find.text("I'm over 18 and drinking responsibly"), findsNothing);
    });
  });

  group('05 · my round', () {
    testWidgets('names the guest and offers the way out once they have one', (
      tester,
    ) async {
      final cocktails = PartyCocktails(load: (_) async => null);
      addTearDown(cocktails.dispose);

      await pumpLocaleAware(
        tester,
        Scaffold(
          body: YourRoundTab(
            party: _party(),
            allOrders: [_order('a')],
            myOrders: [_order('a')],
            guestName: 'Sam',
            cocktails: cocktails,
            onChangeName: () {},
            onLeave: () {},
          ),
        ),
      );

      expect(find.text("You're Sam tonight"), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
      expect(find.text('Leave the party'), findsOneWidget);
    });

    testWidgets('says nothing about a guest who has not ordered yet', (
      tester,
    ) async {
      final cocktails = PartyCocktails(load: (_) async => null);
      addTearDown(cocktails.dispose);

      await pumpLocaleAware(
        tester,
        Scaffold(
          body: YourRoundTab(
            party: _party(),
            allOrders: const [],
            myOrders: const [],
            guestName: null,
            cocktails: cocktails,
            onChangeName: () {},
            onLeave: () {},
          ),
        ),
      );

      expect(find.text('Change'), findsNothing);
    });
  });

  group('06 · party ended', () {
    testWidgets('counts the guest\'s night, not the party\'s', (tester) async {
      await pumpLocaleAware(
        tester,
        PartyEndedScreen(
          party: _party(status: PartyStatus.ended),
          myOrders: [
            _order('a'),
            _order('b', minute: 20, forName: 'Marta'),
            _order('c', minute: 40, status: OrderStatus.cancelled),
          ],
          onDone: () {},
        ),
      );

      // The cancelled one was never drunk and is not part of the night.
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('3H'), findsOneWidget);
      expect(find.text('Kate closed the bar'), findsOneWidget);
    });

    testWidgets('floors an arrival minutes before closing at one hour', (
      tester,
    ) async {
      await pumpLocaleAware(
        tester,
        PartyEndedScreen(
          party: _party(status: PartyStatus.ended),
          myOrders: const [],
          onDone: () {},
        ),
      );

      expect(find.text('0'), findsNWidgets(2));
      expect(find.text('3H'), findsOneWidget);
    });
  });

  group('layout holds under a narrow phone and a bumped text scale', () {
    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('06 party ended on a $device at ${scale}x text', (
          tester,
        ) async {
          await pumpLocaleAware(
            tester,
            PartyEndedScreen(
              party: _party(status: PartyStatus.ended),
              myOrders: [_order('a'), _order('b', minute: 20, forName: 'Marta')],
              onDone: () {},
            ),
            size: size,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('07 bar paused on a $device at ${scale}x text', (
          tester,
        ) async {
          await pumpLocaleAware(
            tester,
            Scaffold(
              body: Stack(
                children: [
                  const PausedNotice(
                    hostName: 'Kate',
                    stillInLine: 'Midnight Orchard · still #2 in line',
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: PausedFooter(hostName: 'Kate'),
                  ),
                ],
              ),
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
