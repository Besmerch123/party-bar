# PartyBar

A cocktail-party host/guest app: hosts run a live bar off their own shelf, guests
order into a queue, everyone gets a recap afterward. The Flutter app is the
product; the admin panel and functions exist to keep its catalogue fed.

## Layout

- `/lib` — the Flutter app. Everything below is about this.
- `/admin` — a Nuxt panel for managing the cocktail/ingredient/equipment catalogue.
- `/functions` — Firebase Cloud Functions (Node), mostly catalogue CRUD and
  Elasticsearch sync for the admin panel and the app's search.
- `/android`, `/ios` — native shells. Touch these for platform config
  (deep links, permissions, signing), not for app logic.

Node work under `/admin` and `/functions` uses `pnpm`; see `README.md` for the
Cloud Run IAM step that deploying `/functions` requires.

## Commands

Run these from the repo root.

```bash
flutter pub get                # after pulling or editing pubspec.yaml
flutter run                    # run on a connected device/emulator
flutter analyze                # 0 issues on a clean tree; 2 asset_directory_does_not_exist
                                # warnings are a known worktree artifact (assets/ is untracked)
flutter test                   # 474 tests
flutter gen-l10n               # regenerate lib/generated/l10n after editing an ARB file
```

`flutter run`/`flutter test` regenerate localizations automatically on build;
run `flutter gen-l10n` by hand only when you need the generated getters before
the next build (e.g. an IDE complaining a key doesn't exist yet).

## Architecture: models → data → services → providers → screens/widgets

- **models** (`lib/models/`) decode. Firestore, SharedPreferences and Elastic
  responses all become typed Dart objects here, and this is the only layer
  that should know a field might arrive as three different shapes. Every date
  field goes through `firestoreDate`/`firestoreDateOr` in
  `lib/models/shared_types.dart` — the same field can legitimately hold a
  Firestore `Timestamp`, an `int` of epoch millis, or an ISO-8601 string
  depending on which code path wrote it, and four call sites used to disagree
  about that before it was unified. Decode dates through the codec; don't add
  another `is Timestamp` check next to it.
- **data** (`lib/data/`, the repositories) talk to Firestore/local storage and
  hand back models. A repository is allowed real logic — batching a
  `whereIn` query past Firestore's limit of 10, walking a round to tally what's
  still pouring — but it should not be a place to add business rules that
  belong one layer up, and it should not re-wrap a model's own decoding.
- **services** (`lib/services/`) are for things that are not "fetch/write a
  document": generating a join code, resolving who the current user is,
  guest-identity bookkeeping, one real algorithm (`OrderService.cancelRound`).
  **A service that just try/catches around a repository call of the same
  name and rethrows is not pulling its weight.** This grooming pass deleted
  exactly that: `CocktailService` was four methods, each a logged rethrow
  around `CocktailRepository`, with zero callers needing the indirection —
  and thinned `OrderService` from 14 methods to the one (`cancelRound`) that
  actually carries logic, repointing 13 pass-through call sites straight at
  `OrderRepository`. Before adding a service method, check whether it's
  actually delegating with no added behavior — if so, call the repository
  directly instead of growing the tier back.
- **providers** (`lib/providers/`) are `ChangeNotifier`s screens watch via
  `provider`. They own UI-facing state and orchestrate services/repositories;
  see the state management section below for the shape of the chain in
  `main.dart`. Providers must be constructible without touching
  Firebase — tests build them bare, with fakes standing in for whatever they'd
  otherwise reach for. Several providers/services (e.g. `AuthenticationProvider`,
  `AccountService`, `PartyService`) take an optional constructor parameter for
  exactly this; default it to the real implementation and never pass it in
  production code.
- **screens** (`lib/screens/`) and **widgets** (`lib/widgets/`) are the UI.
  Screens are routed destinations; widgets are what they're built from.
  Nothing under here should reach into Firestore/Firebase Auth directly —
  go through a repository, service or provider.

## State management

`provider` throughout, wired in `lib/main.dart`'s `MultiProvider`. The one
piece worth understanding before touching it is the `ChangeNotifierProxyProvider`
chain:

```
AuthenticationProvider
        │  attachAccount(auth.user?.uid)
        ▼
   BarProvider  ──── syncShelf(bar.shelf) ────▶  ExploreProvider
```

The shelf is local-first and an account *claims* it rather than *owning* it —
`BarProvider.attachAccount` runs the same whether someone was already signed
in or just signed in this session, so signing in doesn't fork the shelf's
behavior. `ExploreProvider` in turn follows the shelf rather than owning a
copy of it: the bar is the source of truth for what's makeable, and a search
re-derives whenever the shelf changes. If you add a provider that depends on
another provider's state, prefer this proxy shape over having the dependent
provider read the other one ad hoc.

## Routing

`go_router`, built in `lib/utils/app_router.dart`. Every path lives on
`AppRoutes` as a named constant — route to `AppRoutes.foo`, never a literal
string. Read the doc comment on a route constant before using it; several
encode a real decision (which screens are `AuthGuard`-protected and why,
what travels as `extra` vs. a query parameter, what a cold deep link falls
back to when the `extra` it expects isn't there). The four bottom-nav tabs
(Party/My bar/Explore/Settings) live inside one `MainNavigationWrapper` as an
`IndexedStack`, reached via `AppRoutes.home`/`explore`/`myBar` with an
`initialIndex`, not as separate routes.

Guarding: `AuthGuard` wraps a route's `child` and takes a `reason` +
`redirectPath` so the auth screen knows what it interrupted and where to
return. Guest-facing routes (joining, an active guest party, a guest's own
recap) are deliberately unguarded — a guest never had an account to check.

## Design system (`lib/theme/`)

Named "Nightfeed / Signal". Three files: `app_colors.dart`, `app_typography.dart`,
`app_geometry.dart` (spacing/radius/sizes/motion), plus `app_theme.dart` wiring
them into a single dark `ThemeData`.

**Ink ramp** — text/icon opacity over the dark ground, from `AppColors`:
`ink` (full) → `inkBody` (.6) → `inkMeta` (.45) → `inkFaint` (.35) → `inkGhost`
(.3) → `hairline` (.12, dividers/borders only). Reach for the named step, not
an ad-hoc `AppColors.ink.withValues(alpha: 0.4)` — a recent pass folded ~146
drifted alpha call sites and only named the clusters that were genuinely one
thing; a fresh ad-hoc value is exactly the drift that pass was cleaning up.
`ready`/`low` are status-only colors and must never be used decoratively;
`danger` is for irreversible actions, never a warning.

**Type scale** — `AppTypography`: `display` → `title` → `titleCompact`
(screens sharing a bar with nav chrome) → `heading` → `section` → `cardTitle`
→ `body` → `meta` → `caption` (a notch below `meta`) → `label` (always
uppercase) → `buttonPrimary`/`buttonSecondary` → `measure`/`mono` (Space Mono,
reserved for quantities/codes/timers — never sentences). Use a named role
rather than `AppTypography.body.copyWith(fontSize: ...)`; if you need a size
the scale doesn't have, that's a sign to check whether an existing role
already fits before inventing a one-off. The app renders at up to 1.5x text
scale — **never fix an overflow by shrinking a font**; fix the layout
(`Flexible`/`Wrap`/`SingleChildScrollView`, an actual width budget). Plus
Jakarta Sans is missing a few Cyrillic glyphs (í/ï render as tofu in every
weight); `AppTypography`'s fallback chain already covers this — don't
reintroduce a raw `GoogleFonts.plusJakartaSans(...)` that skips it.

**Geometry** — `AppSpacing` (`xs`/`sm`/`md`/`lg` plus `screenEdge`/`cardInset`)
and `AppRadius` (`tile`/`card`/`sheet`/`pill`) over arbitrary numbers.
`AppSizes.minTap` (44) is the floor for anything tappable — a small icon
button still needs a tap target that size.

**Don't restate the theme.** `AppTheme.dark` already sets
`scaffoldBackgroundColor` and an `AppBarTheme` with a transparent background
and no surface tint; a `Scaffold(backgroundColor: AppColors.ground)` or an
`AppBar(surfaceTintColor: Colors.transparent)` is a no-op the theme already
guarantees (a recent pass removed 49 and 10 of exactly these). The exception
is a screen whose body extends behind the app bar over a photo — there an
explicit background is doing real work, not restating the default.

**Reuse the shared shells.** Settings sub-pages (language, measures,
notifications, account & data) go through `SettingsSubpageScaffold`
(`lib/widgets/settings/settings_subpage.dart`) rather than rebuilding the
back-button app bar + title + optional intro line by hand. Bottom sheets go
through `showAppSheet` (`lib/widgets/common/app_sheet.dart`), which fixes the
transparent-route/`isScrollControlled`/safe-area trio every sheet in the app
shares — reach for it (or `showHostSheet`, which now delegates to it) instead
of inlining those three arguments again.

## Localization

Covered in full in `LOCALIZATION.md`; the short version — every user-facing
string in the UI goes through `AppLocalizations`/ARB, never a literal string
in a `Text()`. Add a key to both `lib/l10n/app_en.arb` and `app_uk.arb`, run
`flutter gen-l10n`, then call it as `context.l10n.yourKey`. Dynamic content
that comes from Firestore (a cocktail's title, an ingredient's name) is an
`I18nField` (`Map<String, String>` keyed by locale code) and is rendered with
`.translate(context)`, not through the ARB system.

## Testing

- Widget/layout tests share a harness at `test/support/harness.dart`:
  `testSizes` (an iPhone 14 Pro and a deliberately cramped 320-wide phone),
  `standardTextScales` (`[1.0, 1.5]`), and `pumpLocaleAware` for screens that
  need nothing but a `LocaleProvider`. The convention for a `*_layout_test.dart`
  is to assert every screen holds together at both sizes crossed with both
  scales, with `expect(tester.takeException(), isNull)` — a screen isn't
  considered covered until it's been checked at 1.5x on the small phone.
  Pump helpers and fakes that differ in real ways between test files (different
  provider sets, different fallback behavior) are deliberately *not* shared —
  don't force two files' fakes into one just because they look similar.
- Anything that would otherwise touch Firebase gets a fake instead of hitting
  real Firestore/Auth. The pattern: the screen/provider takes an optional
  constructor parameter for its service (`AccountService? accountService`),
  defaulting to a real instance; tests pass a `_FakeAccountService extends
  AccountService` that overrides just the methods the test needs. See
  `test/settings_flow_test.dart` for a worked example with several fakes
  side by side.
- `flutter analyze` should stay at 0 issues outside the known asset-directory
  warnings; don't add a `// ignore:` to route around a real lint.

## Flows

The app was built as a sequence of numbered flows, and both code comments and
commit messages reference them — `Flow 07 · screen 02`, `Flow 09 · screen 04`,
etc. If a doc comment or commit message cites a flow/screen number, treat it
as the source of truth for *why* something is shaped the way it is, not just
what it does:

1. Welcome/onboarding
2. (Explore — the first cocktail feed, handed off from onboarding)
3. Auth — Google/Apple sign-in only; the email lane was deleted 2026-09-10
4. My bar — the shelf, search, shopping list, "ran out"
5. Host party — building and running a live bar
6. Order & pour — the guest-facing queue and the host's pour flow
7. Join a party — the three doors (slow/fast/returning) into a live party
8. After the party — the recap, which is a place guests and hosts return to,
   not a one-time screen
9. Settings — language, measures, notifications, account & data, profile

When you're not sure why a screen does something counter-intuitive, check
whether a nearby comment or the commit that introduced it cites a flow number
before assuming it's a bug.
