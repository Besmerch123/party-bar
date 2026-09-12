import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/bar_catalogue_repository.dart';
import '../models/bar.dart';
import '../models/bar_item.dart';
import '../models/ingredient.dart';
import '../models/onboarding.dart';
import '../models/shopping_list.dart';
import '../services/account_service.dart';

/// The shelf, on the device — and, once someone signs in, on the account.
///
/// Flow 01 collected a few bottles before an account existed, and flow 02
/// spends them: "makeable with my bar" is free, signed out, and is the reason
/// to come back. Flow 04 is where the shelf becomes a real screen — search to
/// add, a binary stocked/ran-out switch, a shopping list — but the shape
/// underneath stays what it always was: [barKey] strings the catalogue can
/// re-seed underneath without breaking, kept locally first and claimed by an
/// account rather than owned by one.
///
/// Constructing this provider must never touch Firebase — tests build it
/// bare, with fakes standing in for the catalogue and the account. The
/// defaults for both are resolved lazily, the first time something actually
/// needs them.
class BarProvider extends ChangeNotifier {
  BarProvider({BarCatalogueSource? catalogue, BarAccountSync? sync})
    : _catalogueOverride = catalogue,
      _syncOverride = sync;

  /// Where the shelf lives on the device. Public because signing in claims
  /// this shelf into the account, and [AuthenticationProvider] reads it
  /// without owning it — and because it is the one key this provider has
  /// always written, upgrade or not.
  static const shelfKey = 'bar_shelf';

  static const _itemsKey = 'bar_items';
  static const _shoppingListKey = 'bar_shopping_list';
  static const _signInNudgeSeenKey = 'bar_sign_in_nudge_seen';

  /// The key flow 01 writes. Read once, to seed a shelf that has never been
  /// saved; after that the two drift apart and [shelfKey] wins.
  static const _onboardingBottlesKey = 'onboarding_bottles';

  /// How long a local edit sits before it is pushed to the account — long
  /// enough that ticking five things on the shopping list is one write, not
  /// five.
  static const _syncDebounce = Duration(seconds: 1);

  final BarCatalogueSource? _catalogueOverride;
  final BarAccountSync? _syncOverride;

  BarCatalogueSource? _catalogue;
  BarCatalogueSource get _resolvedCatalogue =>
      _catalogue ??= _catalogueOverride ?? FirestoreBarCatalogue();

  BarAccountSync? _sync;
  BarAccountSync get _resolvedSync => _sync ??= _syncOverride ?? AccountService();

  final List<BarItem> _items = [];
  final List<ShoppingEntry> _shoppingList = [];

  Future<void>? _initFuture;
  bool _isInitialized = false;
  bool _signInNudgeSeen = false;

  List<BarCatalogueEntry> _fetchedCatalogue = const [];
  Map<String, BarCatalogueEntry> _catalogueMap = {
    for (final starter in kShelfStarters) starter.key: starter,
  };
  bool _catalogueLoading = false;
  bool _catalogueLoaded = false;
  bool _catalogueFailed = false;

  String? _uid;
  Future<void>? _attachFuture;
  Timer? _syncTimer;

  // -------------------------------------------------------------- the shelf

  /// Every key currently stocked. Compare against [ingredientKeys], never raw
  /// ids — and never against a ran-out item, which this deliberately excludes
  /// so an empty bottle stops counting as makeable.
  Set<String> get shelf => {
    for (final item in _items)
      if (item.isStocked) item.key,
  };

  bool get isInitialized => _isInitialized;

  bool get isEmpty => !_items.any((item) => item.isStocked);

  int get bottleCount => shelf.length;

  bool holds(Ingredient ingredient) =>
      ingredientKeys(ingredient).any(shelf.contains);

  bool holdsKey(String raw) => shelf.contains(barKey(raw));

  /// Safe to call more than once, and safe to race: an account attaching at
  /// launch awaits the same load rather than merging into a bar that has not
  /// been read off the device yet.
  Future<void> initialize() => _initFuture ??= _initialize();

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _signInNudgeSeen = prefs.getBool(_signInNudgeSeenKey) ?? false;

    // Anything already in memory was edited this session and wins; the saved
    // copy only fills in what is not there.
    final savedList = prefs.getString(_shoppingListKey);
    if (savedList != null) {
      for (final entry in _decodeShoppingList(savedList)) {
        if (!isOnList(entry.key)) _shoppingList.add(entry);
      }
    }

    final savedItems = prefs.getString(_itemsKey);
    if (savedItems != null) {
      for (final item in _decodeItems(savedItems)) {
        if (itemFor(item.key) == null) _items.add(item);
      }
    } else {
      await _migrateFromShelfOnly(prefs);
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// The pre-Flow-04 install only ever had [shelfKey] (or, before its first
  /// save, whatever onboarding ticked). Either way every key it held was
  /// stocked — binary stock is all that shape could mean — so this just
  /// upgrades each one into a [BarItem], matching it against the starter
  /// catalogue where it can for a section and a picture.
  Future<void> _migrateFromShelfOnly(SharedPreferences prefs) async {
    final saved = prefs.getStringList(shelfKey);

    final List<String> keys;
    if (saved == null) {
      final knownIds = kStarterBottles.map((bottle) => bottle.id).toSet();
      keys = (prefs.getStringList(_onboardingBottlesKey) ?? const [])
          .where(knownIds.contains)
          .map(barKey)
          .toList();
    } else {
      keys = saved.map(barKey).toList();
    }

    if (keys.isEmpty) return;

    final now = DateTime.now();
    _items.addAll(keys.map((key) => _migratedItem(key, now)));
    await _persist();
  }

  BarItem _migratedItem(String key, DateTime now) {
    final starter = _matchStarter(key);
    if (starter != null) return BarItem.fromEntry(starter, now: now);
    return BarItem(
      key: key,
      kind: BarItemKind.ingredient,
      section: BarSection.other,
      addedAt: now,
    );
  }

  /// Matches a bare key against [kShelfStarters] first, then the wider
  /// [kStarterBottles] (onboarding offers a few — `sweetVermouth`,
  /// `angostura`, `mint` — that never made the shelf's own suggestion list).
  BarCatalogueEntry? _matchStarter(String key) {
    final onShelf = kShelfStarters.where((entry) => entry.key == key).firstOrNull;
    if (onShelf != null) return onShelf;

    final bottle = kStarterBottles
        .where((bottle) => barKey(bottle.id) == key)
        .firstOrNull;
    if (bottle == null) return null;

    return BarCatalogueEntry(
      key: key,
      kind: BarItemKind.ingredient,
      section: starterSection(bottle.id),
      starterId: bottle.id,
      image: bottle.image,
      cocktailCount: bottle.cocktailCount,
    );
  }

  /// Adds [raw] as a stocked bottle, or restocks it if it had run out.
  /// Kept for the callers that predate the item model — search and the item
  /// sheet use [addEntry] instead, which carries a catalogue entry's picture
  /// and title along.
  Future<void> add(String raw) async {
    final key = barKey(raw);
    final existing = itemFor(key);
    if (existing != null) {
      if (existing.isStocked) return;
      await restock(key);
      return;
    }

    final entry =
        entryFor(key) ??
        _matchStarter(key) ??
        BarCatalogueEntry(
          key: key,
          kind: BarItemKind.ingredient,
          section: BarSection.other,
        );
    await addEntry(entry);
  }

  Future<void> addIngredient(Ingredient ingredient) =>
      add(ingredient.slug ?? ingredient.id);

  /// Removes [raw] from the bar entirely — the pre-Flow-04 meaning, kept for
  /// existing callers. [markRanOut] is the flow 04 equivalent that keeps the
  /// item around instead of deleting it.
  Future<void> remove(String raw) => removeItem(barKey(raw));

  Future<void> toggle(String raw) => holdsKey(raw) ? remove(raw) : add(raw);

  // ---------------------------------------------------------------- items

  /// Everything on the bar, stocked and ran out, in the order each item
  /// first joined.
  List<BarItem> get items => List.unmodifiable(_items);

  List<BarItem> get stocked =>
      _items.where((item) => item.isStocked).toList(growable: false);

  List<BarItem> get ranOut =>
      _items.where((item) => !item.isStocked).toList(growable: false);

  bool get hasItems => _items.isNotEmpty;

  BarItem? itemFor(String key) =>
      _items.where((item) => item.key == key).firstOrNull;

  Future<void> addEntry(BarCatalogueEntry entry) => addEntries([entry]);

  Future<void> addEntries(Iterable<BarCatalogueEntry> entries) async {
    final now = DateTime.now();
    var changed = false;

    for (final entry in entries) {
      final existing = itemFor(entry.key);
      if (existing != null) {
        if (existing.isStocked) continue;
        _upsert(
          existing.copyWith(status: BarItemStatus.stocked, statusChangedAt: now),
        );
      } else {
        _upsert(BarItem.fromEntry(entry, now: now));
      }
      _rememberCatalogueEntry(entry);
      changed = true;
    }

    if (!changed) return;
    notifyListeners();
    await _persist();
    _scheduleSync();
  }

  /// A bottle the catalogue has never heard of. Returns the entry so the
  /// caller (the search screen) can navigate straight to its item sheet.
  Future<BarCatalogueEntry> addCustom(String name) async {
    final entry = BarCatalogueEntry.custom(name);
    await addEntry(entry);
    return entry;
  }

  Future<void> markRanOut(String key, {bool addToList = false, String? context}) async {
    final existing = itemFor(key);
    if (existing == null || !existing.isStocked) return;

    final updated = existing.copyWith(
      status: BarItemStatus.ranOut,
      statusChangedAt: DateTime.now(),
    );
    _upsert(updated);
    if (addToList) {
      _addToList(updated.toEntry(), reason: ShoppingReason.ranOut, context: context);
    }

    notifyListeners();
    await _persist();
    _scheduleSync();
  }

  Future<void> restock(String key) async {
    final existing = itemFor(key);
    if (existing == null || existing.isStocked) return;

    _upsert(
      existing.copyWith(
        status: BarItemStatus.stocked,
        statusChangedAt: DateTime.now(),
      ),
    );
    notifyListeners();
    await _persist();
    _scheduleSync();
  }

  /// The row's one-tap flip. A no-op for a key nothing is tracking yet — use
  /// [addEntry] to put something on the bar for the first time.
  Future<void> toggleStocked(String key) {
    final existing = itemFor(key);
    if (existing == null) return Future<void>.value();
    return existing.isStocked ? markRanOut(key) : restock(key);
  }

  /// A blank or whitespace-only [note] clears it.
  Future<void> setNote(String key, String? note) async {
    final existing = itemFor(key);
    if (existing == null) return;

    final trimmed = note?.trim();
    final clear = trimmed == null || trimmed.isEmpty;
    if (clear ? existing.note == null : existing.note == trimmed) return;

    _upsert(existing.copyWith(note: trimmed, clearNote: clear));
    notifyListeners();
    await _persist();
    _scheduleSync();
  }

  /// Gone from the bar entirely — the shopping list keeps its own copy, if it
  /// had one, so removing a bottle does not also erase it from what to buy.
  Future<void> removeItem(String key) async {
    final index = _items.indexWhere((item) => item.key == key);
    if (index < 0) return;

    _items.removeAt(index);
    notifyListeners();
    await _persist();
    _scheduleSync();
  }

  /// Screen 08: marks every one of [keys] as ran out and puts it on the
  /// shopping list, all under [partyName].
  Future<void> applyRanOut(Iterable<String> keys, {String? partyName}) async {
    var changed = false;
    final now = DateTime.now();

    for (final key in keys) {
      final existing = itemFor(key);
      if (existing == null || !existing.isStocked) continue;

      final updated = existing.copyWith(
        status: BarItemStatus.ranOut,
        statusChangedAt: now,
      );
      _upsert(updated);
      _addToList(updated.toEntry(), reason: ShoppingReason.ranOut, context: partyName);
      changed = true;
    }

    if (!changed) return;
    notifyListeners();
    await _persist();
    _scheduleSync();
  }

  void _upsert(BarItem item) {
    final index = _items.indexWhere((existing) => existing.key == item.key);
    if (index >= 0) {
      _items[index] = item;
    } else {
      _items.add(item);
    }
  }

  // ---------------------------------------------------------- shopping list

  List<ShoppingEntry> get shoppingList => List.unmodifiable(_shoppingList);

  bool isOnList(String key) => _shoppingList.any((entry) => entry.key == key);

  Future<void> addToList(
    BarCatalogueEntry entry, {
    required ShoppingReason reason,
    String? context,
  }) async {
    _addToList(entry, reason: reason, context: context);
    notifyListeners();
    await _persist();
    _scheduleSync();
  }

  /// No duplicate keys — re-adding an entry that is already on the list just
  /// unticks it, rather than appending a second row for the same bottle.
  void _addToList(BarCatalogueEntry entry, {required ShoppingReason reason, String? context}) {
    final index = _shoppingList.indexWhere((existing) => existing.key == entry.key);
    if (index >= 0) {
      if (!_shoppingList[index].ticked) return;
      _shoppingList[index] = _shoppingList[index].copyWith(ticked: false);
      return;
    }

    _shoppingList.add(
      ShoppingEntry.fromEntry(entry, reason: reason, context: context, now: DateTime.now()),
    );
    _rememberCatalogueEntry(entry);
  }

  Future<void> addRanOutToList() async {
    var changed = false;
    for (final item in ranOut) {
      if (isOnList(item.key)) continue;
      _shoppingList.add(
        ShoppingEntry.fromEntry(
          item.toEntry(),
          reason: ShoppingReason.ranOut,
          now: DateTime.now(),
        ),
      );
      changed = true;
    }

    if (!changed) return;
    notifyListeners();
    await _persist();
    _scheduleSync();
  }

  /// Ticking stocks the item — adding it to the bar first if nothing is
  /// tracking it yet. Unticking puts it back to ran out; it never un-adds a
  /// bottle that was already on the shelf some other way.
  Future<void> toggleTick(String key) async {
    final index = _shoppingList.indexWhere((entry) => entry.key == key);
    if (index < 0) return;

    final entry = _shoppingList[index];
    final ticking = !entry.ticked;
    _shoppingList[index] = entry.copyWith(ticked: ticking);

    final now = DateTime.now();
    final existingItem = itemFor(key);
    if (ticking) {
      if (existingItem != null) {
        _upsert(
          existingItem.copyWith(status: BarItemStatus.stocked, statusChangedAt: now),
        );
      } else {
        _upsert(BarItem.fromEntry(entry.toEntry(), now: now));
      }
    } else if (existingItem != null && existingItem.isStocked) {
      _upsert(
        existingItem.copyWith(status: BarItemStatus.ranOut, statusChangedAt: now),
      );
    }

    notifyListeners();
    await _persist();
    _scheduleSync();
  }

  Future<void> removeFromList(String key) async {
    final index = _shoppingList.indexWhere((entry) => entry.key == key);
    if (index < 0) return;

    _shoppingList.removeAt(index);
    notifyListeners();
    await _persist();
    _scheduleSync();
  }

  Future<void> clearTicked() async {
    final before = _shoppingList.length;
    _shoppingList.removeWhere((entry) => entry.ticked);
    if (_shoppingList.length == before) return;

    notifyListeners();
    await _persist();
    _scheduleSync();
  }

  Future<void> clearList() async {
    if (_shoppingList.isEmpty) return;
    _shoppingList.clear();
    notifyListeners();
    await _persist();
    _scheduleSync();
  }

  /// Flow 09 · screen 07 — deleting an account empties the shelf on this
  /// phone too. Never pushed to the account: the document that would have
  /// received it is what just got deleted.
  Future<void> clearEverything() async {
    _items.clear();
    _shoppingList.clear();
    notifyListeners();
    await _persist();
  }

  // -------------------------------------------------------------- catalogue

  /// Firestore's ingredients and equipment, plus [kShelfStarters], deduped by
  /// key. A Firestore entry wins the merge — it has a real picture and title
  /// — but keeps the starter's [BarCatalogueEntry.starterId] so it still
  /// counts as one of the twelve suggestions.
  List<BarCatalogueEntry> get catalogue => _catalogueMap.values.toList(growable: false);

  bool get catalogueLoading => _catalogueLoading;
  bool get catalogueFailed => _catalogueFailed;

  BarCatalogueEntry? entryFor(String key) =>
      _catalogueMap[key] ?? itemFor(key)?.toEntry();

  /// Idempotent: once the catalogue has loaded, later calls are a no-op, so
  /// every screen that might need it can call this in a post-frame callback
  /// without racing the others. A failure leaves the starters in place and
  /// can be retried — there is no offline flag to get stuck behind.
  Future<void> loadCatalogue() async {
    if (_catalogueLoading || _catalogueLoaded) return;

    _catalogueLoading = true;
    _catalogueFailed = false;
    notifyListeners();

    try {
      _fetchedCatalogue = await _resolvedCatalogue.load();
      _rebuildCatalogueMap();
      _catalogueLoaded = true;
    } catch (e) {
      _catalogueFailed = true;
      debugPrint('Could not load the bar catalogue: $e');
    } finally {
      _catalogueLoading = false;
      notifyListeners();
    }
  }

  void _rebuildCatalogueMap() {
    final map = <String, BarCatalogueEntry>{
      for (final starter in kShelfStarters) starter.key: starter,
    };

    for (final entry in _fetchedCatalogue) {
      final starter = map[entry.key];
      map[entry.key] = (starter != null && entry.starterId == null)
          ? BarCatalogueEntry(
              key: entry.key,
              kind: entry.kind,
              section: entry.section,
              sourceId: entry.sourceId,
              starterId: starter.starterId,
              title: entry.title,
              image: entry.image,
              cocktailCount: entry.cocktailCount,
            )
          : entry;
    }

    _catalogueMap = map;
  }

  /// Keeps a custom, catalogue-less entry findable by [entryFor] after it is
  /// created — Firestore has never heard of it, so nothing else would.
  void _rememberCatalogueEntry(BarCatalogueEntry entry) {
    if (entry.kind != BarItemKind.custom) return;
    _catalogueMap = {..._catalogueMap, entry.key: entry};
  }

  // ------------------------------------------------------------- sign-in nudge

  /// The one sign-in moment in this flow: once, when the shelf is worth
  /// losing. Never a gate, never repeated.
  bool get signInNudgeDue =>
      bottleCount >= kBarSignInNudgeThreshold && !_signInNudgeSeen;

  Future<void> markSignInNudgeSeen() async {
    if (_signInNudgeSeen) return;
    _signInNudgeSeen = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signInNudgeSeenKey, true);
  }

  // ------------------------------------------------------------------ account

  /// Called from a [ChangeNotifierProxyProvider]'s `update`, which runs
  /// during build — so this never awaits and never calls [notifyListeners]
  /// before returning. The actual sync happens in the background; a build
  /// that ran a moment before someone signed in is allowed to be a moment
  /// stale.
  void attachAccount(String? uid) {
    if (uid == _uid) return;

    _uid = uid;
    _syncTimer?.cancel();
    _syncTimer = null;

    if (uid == null) {
      _attachFuture = null;
      return;
    }

    _attachFuture = _syncOnAttach(uid);
  }

  Future<void> _syncOnAttach(String uid) async {
    var changed = false;
    try {
      // Someone already signed in at launch attaches on the very first build,
      // before the device copy has been read — merging into an empty bar then
      // would duplicate every item once the local load lands.
      await initialize();

      final remote = await _resolvedSync.loadBar(uid);
      // Someone signed out, or into a different account, while this was in
      // flight — the result belongs to nobody now.
      if (_uid != uid) return;

      if (remote != null) {
        changed = _mergeRemote(remote);
        if (changed) await _persist();
      }

      await _resolvedSync.saveBar(uid, _remoteSnapshot());
    } catch (e) {
      // A failed sync must never break the local shelf — the bottles are
      // still on the phone, and the next attach tries again.
      debugPrint('Could not sync the bar to the account: $e');
    }

    if (changed) notifyListeners();
  }

  /// Union by key; local wins on a conflict, since the device was just
  /// edited and the account might not have heard yet.
  bool _mergeRemote(RemoteBar remote) {
    var changed = false;

    for (final remoteItem in remote.items) {
      if (itemFor(remoteItem.key) != null) continue;
      _upsert(remoteItem);
      changed = true;
    }

    for (final remoteEntry in remote.shoppingList) {
      if (isOnList(remoteEntry.key)) continue;
      _shoppingList.add(remoteEntry);
      changed = true;
    }

    return changed;
  }

  RemoteBar _remoteSnapshot() =>
      RemoteBar(items: List.of(_items), shoppingList: List.of(_shoppingList));

  void _scheduleSync() {
    if (_uid == null) return;

    _syncTimer?.cancel();
    _syncTimer = Timer(_syncDebounce, () => unawaited(_pushSync()));
  }

  Future<void> _pushSync() async {
    // An edit made while the first attach is still loading must not push a
    // local-only snapshot over the account before the merge has happened.
    final attach = _attachFuture;
    if (attach != null) await attach;

    final uid = _uid;
    if (uid == null) return;

    try {
      await _resolvedSync.saveBar(uid, _remoteSnapshot());
    } catch (e) {
      debugPrint('Could not save the bar to the account: $e');
    }
  }

  /// Test-only: waits out the initial account sync and the debounce, so a
  /// test can assert on what actually landed rather than sleeping a second.
  @visibleForTesting
  Future<void> flushAccountSync() async {
    _syncTimer?.cancel();
    _syncTimer = null;

    final attach = _attachFuture;
    if (attach != null) await attach;

    await _pushSync();
  }

  // --------------------------------------------------------------- persistence

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(shelfKey, shelf.toList(growable: false));
    await prefs.setString(
      _itemsKey,
      jsonEncode(_items.map((item) => item.toJson()).toList()),
    );
    await prefs.setString(
      _shoppingListKey,
      jsonEncode(_shoppingList.map((entry) => entry.toJson()).toList()),
    );
  }

  List<BarItem> _decodeItems(String raw) {
    try {
      final list = jsonDecode(raw) as List;
      return list
          .whereType<Map>()
          .map((json) => BarItem.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('Could not read the saved bar: $e');
      return const [];
    }
  }

  List<ShoppingEntry> _decodeShoppingList(String raw) {
    try {
      final list = jsonDecode(raw) as List;
      return list
          .whereType<Map>()
          .map((json) => ShoppingEntry.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('Could not read the saved shopping list: $e');
      return const [];
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }
}
