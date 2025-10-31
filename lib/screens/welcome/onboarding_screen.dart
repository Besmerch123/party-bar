import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';

class OnboardingData {
  final String Function(BuildContext) title;
  final String Function(BuildContext) description;
  final IconData icon;
  final Color color;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingData> _getPages(BuildContext context) {
    return [
      OnboardingData(
        title: (ctx) => context.l10n.onboardingTitle1,
        description: (ctx) => context.l10n.onboardingDescription1,
        icon: Icons.local_bar,
        color: Colors.blue,
      ),
      OnboardingData(
        title: (ctx) => context.l10n.onboardingTitle2,
        description: (ctx) => context.l10n.onboardingDescription2,
        icon: Icons.celebration,
        color: Colors.purple,
      ),
      OnboardingData(
        title: (ctx) => context.l10n.onboardingTitle3,
        description: (ctx) => context.l10n.onboardingDescription3,
        icon: Icons.party_mode,
        color: Colors.orange,
      ),
      OnboardingData(
        title: (ctx) => context.l10n.onboardingTitle4,
        description: (ctx) => context.l10n.onboardingDescription4,
        icon: Icons.collections,
        color: Colors.green,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: Text(
                      context.l10n.skip,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  Text(
                    context.l10n.pageOfPages(_currentPage + 1, pages.length),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Page Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: page.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(page.icon, size: 60, color: page.color),
                        ),

                        const SizedBox(height: 40),

                        // Title
                        Text(
                          page.title(context),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          page.description(context),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      context.go(AppRoutes.home);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage < pages.length - 1
                        ? context.l10n.next
                        : context.l10n.getStarted,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
