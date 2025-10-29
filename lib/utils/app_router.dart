import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:party_bar/utils/localization_helper.dart';
import '../screens/screens.dart';
import '../widgets/auth/auth_guard.dart';
import '../models/models.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String explore = '/explore';
  static const String cocktailDetails = '/cocktail';
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
        path: AppRoutes.activePartyGuest,
        builder: (context, state) {
          final extras = state.extra as Map<String, String>;
          final partyCode = extras['partyCode']!;
          final guestName = extras['guestName']!;
          return AuthGuard(
            redirectPath: AppRoutes.activePartyGuest,
            child: ActivePartyGuestScreen(
              partyCode: partyCode,
              guestName: guestName,
            ),
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
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: .6),
        backgroundColor: Theme.of(context).colorScheme.surface,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: context.l10n.navigationHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_bar_outlined),
            activeIcon: Icon(Icons.local_bar),
            label: context.l10n.navigationExplore,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.celebration_outlined),
            activeIcon: Icon(Icons.celebration),
            label: context.l10n.navigationParty,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: context.l10n.navigationSettings,
          ),
        ],
      ),
    );
  }
}
