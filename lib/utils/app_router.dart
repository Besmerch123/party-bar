import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/screens.dart';

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
  static const String myBars = '/bars';
  static const String createBar = '/bars/create';
  static const String barDetails = '/bars/details';
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

      // Party Routes
      GoRoute(
        path: AppRoutes.joinParty,
        builder: (context, state) => const JoinPartyScreen(),
      ),
      GoRoute(
        path: AppRoutes.createParty,
        builder: (context, state) => const CreatePartyScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.partyDetails}/:id',
        builder: (context, state) {
          final partyId = state.pathParameters['id']!;
          return PartyDetailsScreen(partyId: partyId);
        },
      ),

      // Bar Routes
      GoRoute(
        path: AppRoutes.createBar,
        builder: (context, state) => const CreateBarScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.barDetails}/:id',
        builder: (context, state) {
          final barId = state.pathParameters['id']!;
          return BarDetailsScreen(barId: barId);
        },
      ),

      // Profile Routes
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
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
    const MyBarsScreen(),
    const ProfileScreen(),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_bar_outlined),
            activeIcon: Icon(Icons.local_bar),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.celebration_outlined),
            activeIcon: Icon(Icons.celebration),
            label: 'Party',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_outlined),
            activeIcon: Icon(Icons.collections),
            label: 'My Bars',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
