import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:party_bar/generated/l10n/app_localizations.dart';
import 'package:party_bar/models/models.dart';
import 'package:party_bar/providers/bar_provider.dart';
import 'package:party_bar/providers/locale_provider.dart';
import 'package:party_bar/providers/party_cocktails.dart';
import 'package:party_bar/screens/party/pouring_screen.dart';
import 'package:party_bar/theme/theme.dart';
import 'package:party_bar/widgets/party/queue/out_of_stock_sheet.dart';
import 'package:party_bar/widgets/party/queue/queue_body.dart';

/// Flow 06 (host) layout smoke tests — the queue, the pour and the out-of
/// sheet hold together at a small phone and a large text scale, following
/// the harness in `test/bar_ran_out_test.dart`.

const _sizes = <String, Size>{
  'iPhone 14 Pro': Size(390, 844),
  'small phone': Size(320, 568),
};
const _textScales = <double>[1.0, 1.5];

const delegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Ingredient _ingredient(String id, {String? image}) =>
    Ingredient(id: id, title: {'en': id}, category: IngredientCategory.spirit, image: image);

Cocktail _cocktail(
  String id, {
  List<Ingredient> ingredients = const [],
  List<Equipment> equipments = const [],
  Map<String, IngredientMeasure> measures = const {},
  List<PourStep> pourSteps = const [],
  CocktailMethod? method,
  int? prepTimeMinutes,
}) => Cocktail(
  id: id,
  title: {'en': id},
  description: const {'en': ''},
  image: '',
  categories: const [],
  ingredients: ingredients,
  equipments: equipments,
  measures: measures,
  pourSteps: pourSteps,
  method: method,
  prepTimeMinutes: prepTimeMinutes,
);

CocktailOrder _order(
  String id, {
  required String cocktailId,
  OrderStatus status = OrderStatus.pending,
  int minute = 0,
  String guestName = 'Sam',
  String? forName,
  String? note,
  DateTime? preparedAt,
  DateTime? readyAt,
}) {
  final t0 = DateTime(2026, 9, 12, 22, 30);
  return CocktailOrder(
    id: id,
    partyId: 'p1',
    cocktailId: cocktailId,
    guestName: guestName,
    guestId: '$id-device',
    forName: forName,
    specialRequests: note,
    status: status,
    createdAt: t0.add(Duration(minutes: minute)),
    preparedAt: preparedAt,
    readyAt: readyAt,
  );
}

Party _party({PartyStatus status = PartyStatus.active}) => Party(
  id: 'p1',
  name: "Kate's Birthday",
  hostId: 'host-1',
  hostName: 'Kate Doe',
  availableCocktailIds: const ['gt', 'cosmo'],
  joinCode: 'ABC123',
  status: status,
  createdAt: DateTime(2026, 9, 12, 20),
  wentLiveAt: DateTime(2026, 9, 12, 21),
);

Future<PartyCocktails> _cocktailsFor(List<Cocktail> cocktails) async {
  final byId = {for (final c in cocktails) c.id: c};
  final resolver = PartyCocktails(load: (id) async => byId[id]);
  await resolver.ensure(byId.keys);
  return resolver;
}

Future<void> pumpWithTheme(
  WidgetTester tester,
  Widget child, {
  BarProvider? bar,
  Size size = const Size(390, 844),
  double textScale = 1.0,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final app = MaterialApp(
    theme: AppTheme.dark,
    localizationsDelegates: delegates,
    supportedLocales: const [Locale('en'), Locale('uk')],
    builder: (context, widget) => MediaQuery.withClampedTextScaling(
      minScaleFactor: textScale,
      maxScaleFactor: textScale,
      child: widget!,
    ),
    home: child,
  );

  // Titles translate through LocaleProvider, as in every other layout test;
  // only the out-of sheet reads the shelf.
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        if (bar != null) ChangeNotifierProvider.value(value: bar),
      ],
      child: app,
    ),
  );
  await tester.pump();
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  final gt = _cocktail(
    'gt',
    ingredients: [_ingredient('gin'), _ingredient('tonic')],
    equipments: [
      Equipment(id: 'highball', title: {'en': 'Highball'}, kind: EquipmentKind.glassware),
    ],
    measures: {
      'gin': const IngredientMeasure(amount: 50, unit: MeasureUnit.ml),
      'tonic': const IngredientMeasure(amount: 150, unit: MeasureUnit.ml),
    },
    method: CocktailMethod.built,
    prepTimeMinutes: 2,
  );

  final cosmo = _cocktail(
    'cosmo',
    ingredients: [_ingredient('vodka'), _ingredient('cointreau')],
    measures: {
      'vodka': const IngredientMeasure(amount: 40, unit: MeasureUnit.ml),
      'cointreau': const IngredientMeasure(amount: 15, unit: MeasureUnit.ml),
    },
    pourSteps: const [
      PourStep(title: {'en': 'Shake hard with ice.'}, durationSeconds: 12),
      PourStep(title: {'en': 'Strain into a chilled coupe.'}),
    ],
    method: CocktailMethod.shaken,
  );

  group('QueueBody', () {
    void expectNoOverflow(WidgetTester tester) {
      expect(tester.takeException(), isNull);
    }

    testWidgets('next up: the big card when nothing is on the counter', (tester) async {
      final cocktails = await _cocktailsFor([gt, cosmo]);
      final orders = [_order('a', cocktailId: 'gt', note: 'Heavy on the lime')];

      await pumpWithTheme(
        tester,
        Scaffold(
          body: QueueBody(
            party: _party(),
            orders: orders,
            cocktails: cocktails,
            onBack: () {},
            onTogglePause: () {},
            onManage: () {},
            onInvite: () {},
            onStartPouring: (_) {},
            onSkip: (_) {},
            onTapPouring: (_) {},
            onTapInLineRow: (_) {},
            onMarkServed: (_) {},
            onBuzzAgain: (_) {},
            onBackToMixing: (_) {},
          ),
        ),
      );

      expect(find.text('gt'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expectNoOverflow(tester);
    });

    testWidgets('on the counter, pouring and the rest of the line together', (tester) async {
      final cocktails = await _cocktailsFor([gt, cosmo]);
      final orders = [
        _order('a', cocktailId: 'gt', status: OrderStatus.ready, readyAt: DateTime(2026, 9, 12, 22, 40)),
        _order('b', cocktailId: 'cosmo', status: OrderStatus.preparing, minute: 1, preparedAt: DateTime(2026, 9, 12, 22, 41)),
        _order('c', cocktailId: 'gt', minute: 2, forName: 'Marta'),
        _order('d', cocktailId: 'cosmo', minute: 3),
      ];

      await pumpWithTheme(
        tester,
        Scaffold(
          body: QueueBody(
            party: _party(),
            orders: orders,
            cocktails: cocktails,
            onBack: () {},
            onTogglePause: () {},
            onManage: () {},
            onInvite: () {},
            onStartPouring: (_) {},
            onSkip: (_) {},
            onTapPouring: (_) {},
            onTapInLineRow: (_) {},
            onMarkServed: (_) {},
            onBuzzAgain: (_) {},
            onBackToMixing: (_) {},
          ),
        ),
      );

      expect(find.text('Handed it over'), findsOneWidget);
      expectNoOverflow(tester);
    });

    testWidgets('empty queue shows the calm message and a way to invite', (tester) async {
      final cocktails = await _cocktailsFor([gt, cosmo]);

      await pumpWithTheme(
        tester,
        Scaffold(
          body: QueueBody(
            party: _party(),
            orders: const [],
            cocktails: cocktails,
            onBack: () {},
            onTogglePause: () {},
            onManage: () {},
            onInvite: () {},
            onStartPouring: (_) {},
            onSkip: (_) {},
            onTapPouring: (_) {},
            onTapInLineRow: (_) {},
            onMarkServed: (_) {},
            onBuzzAgain: (_) {},
            onBackToMixing: (_) {},
          ),
        ),
      );

      expect(find.textContaining('Nobody'), findsOneWidget);
      expectNoOverflow(tester);
    });

    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('the queue holds on a $device at ${scale}x text', (tester) async {
          final cocktails = await _cocktailsFor([gt, cosmo]);
          final orders = [
            _order('a', cocktailId: 'gt', status: OrderStatus.ready, readyAt: DateTime(2026, 9, 12, 22, 40)),
            _order('b', cocktailId: 'cosmo', minute: 1, note: 'No straw please, thanks'),
            _order('c', cocktailId: 'gt', minute: 2, forName: 'Marta'),
          ];

          await pumpWithTheme(
            tester,
            Scaffold(
              body: QueueBody(
                party: _party(),
                orders: orders,
                cocktails: cocktails,
                onBack: () {},
                onTogglePause: () {},
                onManage: () {},
                onInvite: () {},
                onStartPouring: (_) {},
                onSkip: (_) {},
                onTapPouring: (_) {},
                onTapInLineRow: (_) {},
                onMarkServed: (_) {},
                onBuzzAgain: (_) {},
                onBackToMixing: (_) {},
              ),
            ),
            size: size,
            textScale: scale,
          );

          expectNoOverflow(tester);
        });
      }
    }
  });

  group('PouringBody', () {
    testWidgets('without a note', (tester) async {
      await pumpWithTheme(
        tester,
        PouringBody(
          party: _party(),
          order: _order('a', cocktailId: 'gt', status: OrderStatus.preparing, preparedAt: DateTime.now()),
          cocktail: gt,
          position: 1,
          onBack: () {},
          onMarkReady: () {},
          onOpenMethod: null,
          onOutOfSomething: () {},
          onCancelOrder: () {},
        ),
      );

      expect(find.text('gt'), findsOneWidget);
      expect(find.text('50 ml'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('with a note and a method row', (tester) async {
      await pumpWithTheme(
        tester,
        PouringBody(
          party: _party(),
          order: _order(
            'b',
            cocktailId: 'cosmo',
            status: OrderStatus.preparing,
            preparedAt: DateTime.now(),
            forName: 'Marta',
            note: 'Extra cold, please',
          ),
          cocktail: cosmo,
          position: 2,
          onBack: () {},
          onMarkReady: () {},
          onOpenMethod: () {},
          onOutOfSomething: () {},
          onCancelOrder: () {},
        ),
      );

      expect(find.textContaining('Extra cold'), findsOneWidget);
      expect(find.text('40 ml'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('holds on a $device at ${scale}x text', (tester) async {
          await pumpWithTheme(
            tester,
            PouringBody(
              party: _party(),
              order: _order(
                'b',
                cocktailId: 'cosmo',
                status: OrderStatus.preparing,
                preparedAt: DateTime.now(),
                forName: 'Marta',
                note: 'Heavy on the lime, no straw, extra cold please',
              ),
              cocktail: cosmo,
              position: 2,
              onBack: () {},
              onMarkReady: () {},
              onOpenMethod: () {},
              onOutOfSomething: () {},
              onCancelOrder: () {},
            ),
            size: size,
            textScale: scale,
          );

          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('the out-of sheet', () {
    Future<BarProvider> bareBar() async {
      final bar = BarProvider();
      await bar.initialize();
      return bar;
    }

    Widget openerFor({
      required Party party,
      required CocktailOrder order,
      required Cocktail cocktail,
      required List<Cocktail> menu,
      required List<CocktailOrder> allOrders,
    }) => Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => showOutOfStockFlow(
              context,
              party: party,
              order: order,
              cocktail: cocktail,
              menu: menu,
              allOrders: allOrders,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    testWidgets('names the ingredient and lists every drink it blocks', (tester) async {
      final single = _cocktail('gt', ingredients: [_ingredient('gin')]);
      final order = _order('a', cocktailId: 'gt', status: OrderStatus.preparing);
      final bar = await bareBar();

      await pumpWithTheme(
        tester,
        openerFor(
          party: _party(),
          order: order,
          cocktail: single,
          menu: [single, cosmo],
          allOrders: [order, _order('b', cocktailId: 'gt', minute: 1)],
        ),
        bar: bar,
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('gin'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('holds on a $device at ${scale}x text', (tester) async {
          final single = _cocktail('gt', ingredients: [_ingredient('gin')]);
          final order = _order('a', cocktailId: 'gt', status: OrderStatus.preparing);
          final bar = await bareBar();

          await pumpWithTheme(
            tester,
            openerFor(
              party: _party(),
              order: order,
              cocktail: single,
              menu: [single, cosmo],
              allOrders: [order, _order('b', cocktailId: 'gt', minute: 1)],
            ),
            bar: bar,
            size: size,
            textScale: scale,
          );

          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
