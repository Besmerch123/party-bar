import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:party_bar/utils/localization_helper.dart';
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
  static const String activePartyHost = '/party/active/host';
  static const String activePartyGuest = '/party/active/guest';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String auth = '/auth';
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
            const MainNavigationWrapper(initialIndex: 1),
      ),

      // Cocktail Routes
      GoRoute(
        path: '${AppRoutes.cocktailDetails}/:id',
        builder: (context, state) {
          final cocktailId = state.pathParameters['id']!;
          return CocktailDetailsScreen(cocktailId: cocktailId);
        },
      ),

      // Party Routes (Protected)
      GoRoute(
        path: AppRoutes.joinParty,
        builder: (context, state) => AuthGuard(
          redirectPath: AppRoutes.joinParty,
          child: const JoinPartyScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.createParty,
        builder: (context, state) => AuthGuard(
          redirectPath: AppRoutes.createParty,
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
            child: PartyDetailsScreen(partyId: partyId),
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
            child: ActivePartyHostScreen(party: party),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.activePartyGuest}/:id',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final guestName = extras['guestName']! as String;
          final party = extras['party'] as Party;
          final partyId = state.pathParameters['id']!;
          return AuthGuard(
            redirectPath: '${AppRoutes.activePartyGuest}/$partyId',
            child: ActivePartyGuestScreen(party: party, guestName: guestName),
          );
        },
      ),

      // Profile Routes
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) {
          final redirectPath = state.uri.queryParameters['redirect'];
          return AuthScreen(redirectPath: redirectPath);
        },
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

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const PartyHubScreen(),
    const SettingsScreen(),
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
            label: context.l10n.navigationHome,
          ),
          AppNavDestination(
            icon: Icons.local_bar_outlined,
            activeIcon: Icons.local_bar,
            label: context.l10n.navigationExplore,
          ),
          AppNavDestination(
            icon: Icons.celebration_outlined,
            activeIcon: Icons.celebration,
            label: context.l10n.navigationParty,
          ),
          AppNavDestination(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: context.l10n.navigationSettings,
          ),
        ],
      ),
    );
  }
}
