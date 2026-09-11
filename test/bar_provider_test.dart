import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:party_bar/data/bar_catalogue_repository.dart';
import 'package:party_bar/models/models.dart';
import 'package:party_bar/providers/bar_provider.dart';
import 'package:party_bar/services/account_service.dart';

/// Flow 04's data foundation: the shelf as a set of [BarItem]s rather than
/// bare keys, the shopping list, the catalogue merge, and the account sync —
/// all of it offline, against fakes standing in for Firestore.

Ingredient _ingredient(
  String id, {
  IngredientCategory category = IngredientCategory.spirit,
  int? cocktailCount,
}) => Ingredient(id: id, title: {'en': id}, category: category, cocktailCount: cocktailCount);

Equipment _equipment(String id, {EquipmentKind kind = EquipmentKind.tool}) =>
    Equipment(id: id, title: {'en': id}, kind: kind);

Cocktail _cocktail(
  String id, {
  List<Ingredient> ingredients = const [],
  List<Equipment> equipments = const [],
  int? popularity,
}) => Cocktail(
  id: id,
  title: {'en': id},
  description: const {'en': ''},
  image: '',
  categories: const [],
  ingredients: ingredients,
  equipments: equipments,
  popularity: popularity,
);

class _FakeCatalogueSource implements BarCatalogueSource {
  _FakeCatalogueSource(this.entries);

  List<BarCatalogueEntry> entries;
  bool shouldThrow = false;

  @override
  Future<List<BarCatalogueEntry>> load() async {
    if (shouldThrow) throw Exception('offline');
    return entries;
  }
}

class _FakeAccountSync implements BarAccountSync {
  RemoteBar? stored;
  final Map<String, RemoteBar> saved = {};
  int saveCount = 0;

  @override
  Future<RemoteBar?> loadBar(String uid) async => stored;

  @override
  Future<void> saveBar(String uid, RemoteBar bar) async {
    saveCount++;
    saved[uid] = bar;
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('migrating from a bar_shelf-only install', () {
    test('builds items, matching starters for a section and a picture', () async {
      SharedPreferences.setMockInitialValues({
        'bar_shelf': ['gin', 'lime', 'shaker', 'someMysteryThing'],
      });

      final bar = BarProvider();
      await bar.initialize();

      expect(bar.bottleCount, 4);

      final gin = bar.itemFor('gin')!;
      expect(gin.starterId, 'gin');
      expect(gin.section, BarSection.spirits);
      expect(gin.kind, BarItemKind.ingredient);

      final shaker = bar.itemFor('shaker')!;
      expect(shaker.starterId, 'shaker');
      expect(shaker.kind, BarItemKind.equipment);
      expect(shaker.section, BarSection.tools);

      final lime = bar.itemFor('lime')!;
      expect(lime.section, BarSection.fresh);

      final mystery = bar.itemFor('someMysteryThing'.toLowerCase())!;
      expect(mystery.kind, BarItemKind.ingredient);
      expect(mystery.section, BarSection.other);
      expect(mystery.starterId, isNull);

      // Migrating writes the upgraded shape back, so this only ever runs once.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('bar_items'), isNotNull);
    });

    test('still seeds from the onboarding key when neither has been saved', () async {
      SharedPreferences.setMockInitialValues({
        'onboarding_bottles': ['gin', 'sweetVermouth'],
      });

      final bar = BarProvider();
      await bar.initialize();

      expect(bar.bottleCount, 2);
      expect(bar.holdsKey('sweet-vermouth'), isTrue);
      expect(bar.itemFor('sweetvermouth')!.section, BarSection.spirits);
    });
  });

  group('add, markRanOut and restock', () {
    test('a ran-out item drops out of the shelf but stays on the bar', () async {
      final bar = BarProvider();
      await bar.initialize();

      await bar.add('gin');
      await bar.add('tonic');
      expect(bar.shelf, {'gin', 'tonic'});

      await bar.markRanOut('gin');
      expect(bar.shelf, {'tonic'});
      expect(bar.holdsKey('gin'), isFalse);
      expect(bar.itemFor('gin'), isNotNull, reason: 'still on the bar, just not stocked');
      expect(bar.ranOut.map((i) => i.key), ['gin']);

      await bar.restock('gin');
      expect(bar.shelf, {'gin', 'tonic'});
      expect(bar.ranOut, isEmpty);
    });

    test('add restocks rather than duplicating an existing item', () async {
      final bar = BarProvider();
      await bar.initialize();

      await bar.add('gin');
      await bar.markRanOut('gin');
      await bar.add('gin');

      expect(bar.items.length, 1);
      expect(bar.holdsKey('gin'), isTrue);
    });

    test('markRanOut can add straight to the shopping list', () async {
      final bar = BarProvider();
      await bar.initialize();
      await bar.add('lime');

      await bar.markRanOut('lime', addToList: true, context: "Kate's Birthday");

      expect(bar.isOnList('lime'), isTrue);
      final entry = bar.shoppingList.single;
      expect(entry.reason, ShoppingReason.ranOut);
      expect(entry.context, "Kate's Birthday");
    });
  });

  group('notes', () {
    test('can be set and cleared', () async {
      final bar = BarProvider();
      await bar.initialize();
      await bar.add('gin');

      await bar.setNote('gin', 'Bombay Sapphire');
      expect(bar.itemFor('gin')!.note, 'Bombay Sapphire');

      await bar.setNote('gin', '   ');
      expect(bar.itemFor('gin')!.note, isNull);
    });
  });

  group('removeItem', () {
    test('takes the item off the bar entirely', () async {
      final bar = BarProvider();
      await bar.initialize();
      await bar.add('gin');

      await bar.removeItem('gin');

      expect(bar.itemFor('gin'), isNull);
      expect(bar.holdsKey('gin'), isFalse);
    });
  });

  group('the shopping list', () {
    test('addToList never duplicates a key', () async {
      final bar = BarProvider();
      await bar.initialize();
      final entry = BarCatalogueEntry.custom('Lime');

      await bar.addToList(entry, reason: ShoppingReason.manual);
      await bar.addToList(entry, reason: ShoppingReason.manual);

      expect(bar.shoppingList.length, 1);
    });

    test('re-adding a ticked entry unticks it instead of duplicating', () async {
      final bar = BarProvider();
      await bar.initialize();
      final entry = BarCatalogueEntry.custom('Lime');

      await bar.addToList(entry, reason: ShoppingReason.manual);
      await bar.toggleTick('lime');
      expect(bar.shoppingList.single.ticked, isTrue);

      await bar.addToList(entry, reason: ShoppingReason.manual);
      expect(bar.shoppingList.length, 1);
      expect(bar.shoppingList.single.ticked, isFalse);
    });

    test('toggleTick stocks the item, ticking it back off returns it to ran out', () async {
      final bar = BarProvider();
      await bar.initialize();
      final entry = BarCatalogueEntry.custom('Lime');
      await bar.addToList(entry, reason: ShoppingReason.manual);

      await bar.toggleTick('lime');
      expect(bar.holdsKey('lime'), isTrue, reason: 'ticking adds it to the bar');
      expect(bar.shoppingList.single.ticked, isTrue);

      await bar.toggleTick('lime');
      expect(bar.holdsKey('lime'), isFalse);
      expect(bar.itemFor('lime')!.isStocked, isFalse);
      expect(bar.shoppingList.single.ticked, isFalse);
    });

    test('clearTicked removes only the ticked entries', () async {
      final bar = BarProvider();
      await bar.initialize();
      await bar.addToList(BarCatalogueEntry.custom('Lime'), reason: ShoppingReason.manual);
      await bar.addToList(BarCatalogueEntry.custom('Mint'), reason: ShoppingReason.manual);
      await bar.toggleTick('lime');

      await bar.clearTicked();

      expect(bar.shoppingList.map((e) => e.key), ['mint']);
    });

    test('addRanOutToList adds every ran-out item exactly once', () async {
      final bar = BarProvider();
      await bar.initialize();
      await bar.add('gin');
      await bar.add('tonic');
      await bar.markRanOut('gin');
      await bar.markRanOut('tonic', addToList: true);

      await bar.addRanOutToList();

      expect(bar.shoppingList.map((e) => e.key).toSet(), {'gin', 'tonic'});
    });

    test('applyRanOut marks every key and lists it under the party name', () async {
      final bar = BarProvider();
      await bar.initialize();
      await bar.add('gin');
      await bar.add('tonic');

      await bar.applyRanOut(['gin', 'tonic'], partyName: "Kate's Birthday");

      expect(bar.shelf, isEmpty);
      expect(bar.ranOut.length, 2);
      expect(
        bar.shoppingList.every((e) => e.context == "Kate's Birthday"),
        isTrue,
      );
    });
  });

  group('persistence', () {
    test('items, shopping list and notes round-trip across a fresh provider', () async {
      final first = BarProvider();
      await first.initialize();
      await first.add('gin');
      await first.setNote('gin', 'Bombay Sapphire');
      await first.markRanOut('gin');
      await first.addToList(BarCatalogueEntry.custom('Mint'), reason: ShoppingReason.manual);

      final second = BarProvider();
      await second.initialize();

      final gin = second.itemFor('gin')!;
      expect(gin.isStocked, isFalse);
      expect(gin.note, 'Bombay Sapphire');
      expect(second.shoppingList.single.key, 'mint');
    });
  });

  group('the sign-in nudge', () {
    test('is due once the shelf reaches the threshold, and stays seen once marked', () async {
      final bar = BarProvider();
      await bar.initialize();

      for (final key in ['a', 'b', 'c', 'd', 'e', 'f', 'g']) {
        await bar.add(key);
      }
      expect(bar.signInNudgeDue, isFalse, reason: 'seven is not yet eight');

      await bar.add('h');
      expect(bar.signInNudgeDue, isTrue);

      await bar.markSignInNudgeSeen();
      expect(bar.signInNudgeDue, isFalse);

      final second = BarProvider();
      await second.initialize();
      expect(
        second.signInNudgeDue,
        isFalse,
        reason: 'the seen flag persists across a fresh provider',
      );
    });
  });

  group('attachAccount', () {
    test('union-merges by key, local wins, and saves through flushAccountSync', () async {
      final sync = _FakeAccountSync();
      final now = DateTime.now();
      sync.stored = RemoteBar(
        items: [
          // Conflicts with the local 'gin' below — local should win, so this
          // ran-out status must not survive the merge.
          BarItem(
            key: 'gin',
            kind: BarItemKind.ingredient,
            section: BarSection.spirits,
            status: BarItemStatus.ranOut,
            addedAt: now,
          ),
          BarItem(
            key: 'tonic',
            kind: BarItemKind.ingredient,
            section: BarSection.mixers,
            addedAt: now,
          ),
        ],
      );

      final bar = BarProvider(sync: sync);
      await bar.initialize();
      await bar.add('gin');

      bar.attachAccount('uid-1');
      await bar.flushAccountSync();

      expect(bar.holdsKey('gin'), isTrue, reason: 'local wins the conflict');
      expect(bar.holdsKey('tonic'), isTrue, reason: 'the remote-only item is adopted');
      expect(sync.saveCount, greaterThan(0));
      expect(sync.saved['uid-1']!.items.map((i) => i.key).toSet(), {'gin', 'tonic'});
    });

    test('signed in at launch: attaching mid-load never duplicates items', () async {
      final first = BarProvider();
      await first.initialize();
      await first.add('gin');

      final sync = _FakeAccountSync();
      sync.stored = RemoteBar(
        items: [
          BarItem(
            key: 'gin',
            kind: BarItemKind.ingredient,
            section: BarSection.spirits,
            status: BarItemStatus.ranOut,
            addedAt: DateTime.now(),
          ),
          BarItem(
            key: 'tonic',
            kind: BarItemKind.ingredient,
            section: BarSection.mixers,
            addedAt: DateTime.now(),
          ),
        ],
      );

      // What main.dart does: initialize is fired, not awaited, and the proxy
      // attaches the already-signed-in account on the same first build.
      final bar = BarProvider(sync: sync);
      unawaited(bar.initialize());
      bar.attachAccount('uid-1');
      await bar.flushAccountSync();

      expect(bar.items.map((item) => item.key).toList(), ['gin', 'tonic']);
      expect(bar.holdsKey('gin'), isTrue, reason: 'the device copy still wins');
      expect(sync.saved['uid-1']!.items.map((i) => i.key).toList(), ['gin', 'tonic']);
    });

    test('is idempotent for the same uid', () async {
      final sync = _FakeAccountSync();
      final bar = BarProvider(sync: sync);
      await bar.initialize();

      bar.attachAccount('uid-1');
      await bar.flushAccountSync();
      final afterFirst = sync.saveCount;

      bar.attachAccount('uid-1');
      expect(sync.saveCount, afterFirst, reason: 'the same uid attaches only once');
    });

    test('a later local edit is picked up by flushAccountSync', () async {
      final sync = _FakeAccountSync();
      final bar = BarProvider(sync: sync);
      await bar.initialize();

      bar.attachAccount('uid-1');
      await bar.flushAccountSync();

      await bar.add('gin');
      await bar.flushAccountSync();

      expect(sync.saved['uid-1']!.items.map((i) => i.key), contains('gin'));
    });

    test('a failing sync never breaks the local shelf', () async {
      final bar = BarProvider(sync: _ExplodingSync());
      await bar.initialize();
      await bar.add('gin');

      bar.attachAccount('uid-1');
      await bar.flushAccountSync();

      expect(bar.holdsKey('gin'), isTrue);
    });
  });

  group('loadCatalogue', () {
    test('merges the catalogue with the starters, Firestore entry winning the key', () async {
      final ginFromCatalogue = BarCatalogueEntry(
        key: 'gin',
        kind: BarItemKind.ingredient,
        section: BarSection.spirits,
        sourceId: 'doc123',
        title: const {'en': 'London dry gin'},
      );
      final source = _FakeCatalogueSource([ginFromCatalogue]);
      final bar = BarProvider(catalogue: source);

      await bar.loadCatalogue();

      final merged = bar.entryFor('gin')!;
      expect(merged.sourceId, 'doc123', reason: 'the Firestore entry wins the key');
      expect(merged.starterId, 'gin', reason: 'but keeps its starter id');
      // A starter that never made it into the catalogue is still searchable.
      expect(bar.entryFor('shaker'), isNotNull);
      expect(bar.catalogueFailed, isFalse);
    });

    test('survives a throwing source, leaving the starters in place', () async {
      final source = _FakeCatalogueSource([])..shouldThrow = true;
      final bar = BarProvider(catalogue: source);

      await bar.loadCatalogue();

      expect(bar.catalogueFailed, isTrue);
      expect(bar.catalogue.length, kShelfStarters.length);
      expect(bar.entryFor('gin'), isNotNull);
    });
  });

  group('BarStats', () {
    test('figures on a small hand-built catalogue', () {
      final gin = _ingredient('gin');
      final tonic = _ingredient('tonic', category: IngredientCategory.mixer);
      final lime = _ingredient('lime', category: IngredientCategory.fruit);
      final tequila = _ingredient('tequila');
      final shaker = _equipment('shaker');

      final ginTonic = _cocktail(
        'gin-tonic',
        ingredients: [gin, tonic],
        equipments: [shaker],
        popularity: 10,
      );
      final ginFizz = _cocktail(
        'gin-fizz',
        ingredients: [gin, tonic, lime],
        equipments: [shaker],
        popularity: 20,
      );
      final margarita = _cocktail('margarita', ingredients: [lime, tequila]);

      final shelf = {'gin', 'tonic'};
      final stats = BarStats.compute([ginTonic, ginFizz, margarita], shelf);

      expect(stats.hasCatalogue, isTrue);
      expect(stats.makeableCount, 1);
      expect(stats.usedInMakeable('gin'), 1);
      expect(stats.usedInMakeable('tonic'), 1);
      expect(stats.usedInMakeable('shaker'), 1);
      expect(stats.usedInMakeable('lime'), 0);
      expect(stats.blockedBy('lime'), 1, reason: 'only gin-fizz is exactly one away');
      expect(stats.missingIn('lime'), 2, reason: 'gin-fizz and margarita both need it');
      expect(stats.missingIn('tequila'), 1);
      expect(stats.blockedBy('tequila'), 0, reason: 'margarita is missing two things, not one');
      expect(stats.makeableUsing('gin').map((c) => c.id), ['gin-tonic']);

      expect(BarStats.compute(const [], shelf).hasCatalogue, isFalse);
      expect(BarStats.empty.hasCatalogue, isFalse);
    });
  });

  group('searchBarCatalogue', () {
    String nameOf(BarCatalogueEntry entry) => entry.title['en'] ?? entry.key;

    test('ranks prefix matches first, then shorter names, and marks the range', () {
      final entries = [
        const BarCatalogueEntry(
          key: 'virgin-mojito',
          kind: BarItemKind.custom,
          section: BarSection.other,
          title: {'en': 'Virgin Mojito'},
        ),
        const BarCatalogueEntry(
          key: 'gin-fizz',
          kind: BarItemKind.custom,
          section: BarSection.other,
          title: {'en': 'Gin Fizz'},
        ),
        const BarCatalogueEntry(
          key: 'gin',
          kind: BarItemKind.custom,
          section: BarSection.other,
          title: {'en': 'Gin'},
        ),
        const BarCatalogueEntry(
          key: 'tonic',
          kind: BarItemKind.custom,
          section: BarSection.other,
          title: {'en': 'Tonic Water'},
        ),
      ];

      final results = searchBarCatalogue(entries, 'gin', nameOf: nameOf);

      expect(results.map((m) => m.entry.key), ['gin', 'gin-fizz', 'virgin-mojito']);
      expect(results.first.start, 0);
      expect(results.first.end, 3);

      final virgin = results.last;
      expect(virgin.start, 3);
      expect(virgin.end, 6);
    });

    test('folds diacritics and case', () {
      final entries = [
        const BarCatalogueEntry(
          key: 'creme-de-cassis',
          kind: BarItemKind.custom,
          section: BarSection.other,
          title: {'en': 'Crème de Cassis'},
        ),
      ];

      final results = searchBarCatalogue(entries, 'CREME', nameOf: nameOf);

      expect(results, hasLength(1));
      expect(results.single.start, 0);
    });

    test('an empty query matches nothing', () {
      final entries = [BarCatalogueEntry.custom('Gin')];
      expect(searchBarCatalogue(entries, '   ', nameOf: nameOf), isEmpty);
    });
  });

  group('shoppingListText', () {
    test('lists unticked entries with an optional reason and footer', () {
      final now = DateTime.now();
      final entries = [
        ShoppingEntry(
          key: 'lime',
          kind: BarItemKind.ingredient,
          section: BarSection.fresh,
          title: const {'en': 'Lime'},
          reason: ShoppingReason.ranOut,
          addedAt: now,
        ),
        ShoppingEntry(
          key: 'mint',
          kind: BarItemKind.ingredient,
          section: BarSection.fresh,
          title: const {'en': 'Mint'},
          reason: ShoppingReason.manual,
          ticked: true,
          addedAt: now,
        ),
      ];

      final text = shoppingListText(
        entries,
        heading: 'PartyBar — shopping list',
        nameOf: (e) => e.title['en']!,
        whyOf: (e) => e.reason == ShoppingReason.ranOut ? 'ran out' : null,
        footer: 'Sent from PartyBar',
      );

      expect(text, contains('PartyBar — shopping list'));
      expect(text, contains('Lime — ran out'));
      expect(text, isNot(contains('Mint')), reason: 'ticked entries do not print');
      expect(text, contains('Sent from PartyBar'));
    });
  });
}

class _ExplodingSync implements BarAccountSync {
  @override
  Future<RemoteBar?> loadBar(String uid) async => throw Exception('offline');

  @override
  Future<void> saveBar(String uid, RemoteBar bar) async => throw Exception('offline');
}
