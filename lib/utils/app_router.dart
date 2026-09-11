import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:party_bar/utils/localization_helper.dart';
import '../models/auth.dart';
import '../screens/party/party_invite_screen.dart';
import '../screens/screens.dart';
import '../widgets/auth/auth_guard.dart';
import '../widgets/common/app_bottom_nav.dart';
import '../models/models.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String explore = '/explore';
  static const String cocktailDetails = '/cocktail';

  /// Search, results and the zero-results answer — one screen, three states.
  static const String exploreSearch = '/explore/search';

  /// The guided pour. Pushed as '$makeItNow/$cocktailId' with the cocktail
  /// itself as `extra`, so the screen never re-fetches what the detail
  /// screen already has.
  static const String makeItNow = '/cocktail/make';
  static const String partyHub = '/party';
  static const String joinParty = '/party/join';
  static const String createParty = '/party/create';
  static const String partyDetails = '/party/details';

  /// Flow 05 · screen 09 — the QR and share link, reached with the [Party]
  /// as `extra` from Go live, the live hub and Manage.
  static const String partyInvite = '/party/invite';
  static const String activePartyHost = '/party/active/host';
  static const String activePartyGuest = '/party/active/guest';
  static const String profile = '/profile';
  static const String settings = '/settings';

  /// Flow 03. The cold sign-in screen; the barrier that usually stands in for
  /// it is a sheet over whatever it interrupted, not a route.
  static const String auth = '/auth';

  /// Asked only of a provider that did not hand us a name.
  static const String authName = '/auth/name';

  /// The guest lane, which never creates an account at all.
  static const String authGuest = '/auth/guest';

  /// Flow 04. The shelf itself — `MainNavigationWrapper(initialIndex: 1)`.
  static const String myBar = '/bar';

  /// Screens 02 and the shopping list's own search, told apart by
  /// `?mode=list`.
  static const String barSearch = '/bar/search';

  static const String shoppingList = '/bar/list';

  /// Screen 08, reached with a [RanOutArgs] as `extra` when a party just
  /// ended, or cold with none from My bar.
  static const String barRanOut = '/bar/ran-out';
}

GoRouter createAppRouter({required bool showWelcome}) {
  return GoRouter(
    initialLocation: showWelcome ? AppRoutes.welcome : AppRoutes.explore,
    routes: [
      // Welcome and Onboarding
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main App Navigation
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainNavigationWrapper(),
      ),
      GoRoute(
        path: AppRoutes.explore,
        builder: (context, state) =>
            const MainNavigationWrapper(initialIndex: 2),
      ),
      GoRoute(
        path: AppRoutes.myBar,
        builder: (context, state) =>
            const MainNavigationWrapper(initialIndex: 1),
      ),

      // Flow 04 - My bar. Search adds in place as you type, whichever list
      // it is adding to; the list itself and the once-a-party check are
      // their own screens.
      GoRoute(
        path: AppRoutes.barSearch,
        builder: (context, state) => BarSearchScreen(
          mode: state.uri.queryParameters['mode'] == 'list'
              ? BarSearchMode.list
              : BarSearchMode.shelf,
        ),
      ),
      GoRoute(
        path: AppRoutes.shoppingList,
        builder: (context, state) => const ShoppingListScreen(),
      ),
      GoRoute(
        path: AppRoutes.barRanOut,
        builder: (context, state) =>
            RanOutScreen(args: state.extra as RanOutArgs?),
      ),

      // Explore search, results and the zero-results answer — one screen
      // reading the same query state as the feed behind it.
      GoRoute(
        path: AppRoutes.exploreSearch,
        builder: (context, state) => const ExploreSearchScreen(),
      ),

      // Cocktail Routes
      GoRoute(
        path: '${AppRoutes.cocktailDetails}/:id',
        builder: (context, state) {
          final cocktailId = state.pathParameters['id']!;
          return CocktailDetailsScreen(cocktailId: cocktailId);
        },
      ),

      // The guided pour. Reached from a cocktail already on screen, so the
      // cocktail travels as `extra` rather than being fetched a second time;
      // arriving without one (a cold deep link) falls back to the detail
      // screen, which knows how to load it.
      GoRoute(
        path: '${AppRoutes.makeItNow}/:id',
        builder: (context, state) {
          final cocktail = state.extra;
          if (cocktail is! Cocktail) {
            return CocktailDetailsScreen(
              cocktailId: state.pathParameters['id']!,
            );
          }
          return MakeItNowScreen(cocktail: cocktail);
        },
      ),

      // Party Routes (Protected)
      // Joining is not guarded. A guest orders on a name alone — screens 08
      // and 09 of flow 03 assume no account is ever created here.
      GoRoute(
        path: AppRoutes.joinParty,
        builder: (context, state) => const JoinPartyScreen(),
      ),

      // Hosting is. A party needs an owner so a link can point at it.
      GoRoute(
        path: AppRoutes.createParty,
        builder: (context, state) => AuthGuard(
          redirectPath: AppRoutes.createParty,
          reason: AuthReason.hostParty,
          child: const CreatePartyScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.partyDetails}/:id',
        builder: (context, state) {
          final partyId = state.pathParameters['id']!;
          final partyDetailsPath = '${AppRoutes.partyDetails}/$partyId';
          return AuthGuard(
            redirectPath: partyDetailsPath,
            reason: AuthReason.hostParty,
            child: PartyDetailsScreen(partyId: partyId),
          );
        },
      ),
      // A cold link carries no party, and falls back to the details screen,
      // which knows how to load one.
      GoRoute(
        path: '${AppRoutes.partyInvite}/:id',
        builder: (context, state) {
          final partyId = state.pathParameters['id']!;
          final party = state.extra;
          return AuthGuard(
            redirectPath: '${AppRoutes.partyInvite}/$partyId',
            reason: AuthReason.hostParty,
            child: party is Party
                ? PartyInviteScreen(party: party)
                : PartyDetailsScreen(partyId: partyId),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.activePartyHost}/:id',
        builder: (context, state) {
          final partyId = state.pathParameters['id']!;
          final party = state.extra as Party;
          return AuthGuard(
            redirectPath: '${AppRoutes.activePartyHost}/$partyId',
            reason: AuthReason.hostParty,
            child: ActivePartyHostScreen(party: party),
          );
        },
      ),
      // Unguarded, for the same reason as joining.
      GoRoute(
        path: '${AppRoutes.activePartyGuest}/:id',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final guestName = extras['guestName']! as String;
          final party = extras['party'] as Party;
          return ActivePartyGuestScreen(party: party, guestName: guestName);
        },
      ),

      // Profile Routes
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      // Flow 03 — auth.
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => AuthScreen(
          redirectPath: state.uri.queryParameters['redirect'],
          reason: authReasonFrom(state),
        ),
      ),
      GoRoute(
        path: AppRoutes.authName,
        builder: (context, state) => const NameYourselfScreen(),
      ),

      // The guest lane. Reached from a party link or the join screen, which
      // is why the party it belongs to travels in the query rather than as
      // `extra` — a cold deep link has no extra.
      GoRoute(
        path: AppRoutes.authGuest,
        builder: (context, state) => GuestNameScreen(
          partyName: state.uri.queryParameters['party'],
          hostName: state.uri.queryParameters['host'],
        ),
      ),
    ],
  );
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant MainNavigationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A route elsewhere can re-point at this same wrapper with a different
    // tab — `context.go(AppRoutes.myBar)` from a screen that is not one of
    // the four tabs — and that has to land on the right one rather than
    // wherever this instance happened to be left.
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() => _selectedIndex = widget.initialIndex);
    }
  }

  final List<Widget> _screens = const [
    PartyHubScreen(),
    MyBarScreen(),
    ExploreScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          AppNavDestination(
            icon: Icons.nightlife_outlined,
            activeIcon: Icons.nightlife,
            label: context.l10n.navigationParty,
          ),
          AppNavDestination(
            icon: Icons.local_bar_outlined,
            activeIcon: Icons.local_bar,
            label: context.l10n.navigationMyBar,
          ),
          AppNavDestination(
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            label: context.l10n.navigationExplore,
          ),
          AppNavDestination(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: context.l10n.navigationSettings,
          ),
        ],
      ),
    );
  }
}
