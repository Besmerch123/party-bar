import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:party_bar/widgets/cocktails/cocktail_categories.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../data/cocktail_repository.dart';
import '../../providers/locale_provider.dart';
import '../../utils/app_router.dart';

/// Data class to hold all home screen data (untranslated)
class _HomeData {
  final List<(String id, CocktailDocument doc)> featuredCocktails;
  final List<(String id, CocktailDocument doc)> popularCocktails;
  final Map<CocktailCategory, List<(String id, CocktailDocument doc)>>
  categorizedCocktails;
  final int totalCocktails;

  const _HomeData({
    required this.featuredCocktails,
    required this.popularCocktails,
    required this.categorizedCocktails,
    required this.totalCocktails,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CocktailRepository _cocktailRepository = CocktailRepository();

  late Future<_HomeData> _homeDataFuture;
  bool isAuthenticated = true; // TODO: Get from auth provider

  @override
  void initState() {
    super.initState();
    _homeDataFuture = _loadData();
  }

  Future<_HomeData> _loadData() async {
    // Fetch all cocktail documents (untranslated)
    final allCocktailDocs = await _cocktailRepository.getAllCocktailDocuments();

    // Sort by creation date and take latest 3 for featured
    final sortedByDate = List<(String, CocktailDocument)>.from(allCocktailDocs)
      ..sort((a, b) {
        final aDate = a.$2.createdAt.toDate();
        final bDate = b.$2.createdAt.toDate();
        return bDate.compareTo(aDate);
      });
    final featured = sortedByDate.take(3).toList();

    // Take latest 5 for popular section (simplified)
    final popular = sortedByDate.take(5).toList();

    // Categorize cocktails
    final categorized = <CocktailCategory, List<(String, CocktailDocument)>>{};
    for (final category in CocktailCategory.values) {
      final cocktails = allCocktailDocs
          .where((c) => c.$2.categories.contains(category))
          .take(3)
          .toList();
      if (cocktails.isNotEmpty) {
        categorized[category] = cocktails;
      }
    }

    return _HomeData(
      featuredCocktails: featured,
      popularCocktails: popular,
      categorizedCocktails: categorized,
      totalCocktails: allCocktailDocs.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PartyBar'), centerTitle: true),
      body: FutureBuilder<_HomeData>(
        future: _homeDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading data: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _homeDataFuture = _loadData();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _homeDataFuture = _loadData();
              });
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(data),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildFeaturedSection(data),
                  const SizedBox(height: 24),
                  _buildCategoriesSection(data),
                  const SizedBox(height: 24),
                  _buildPopularSection(data),
                  const SizedBox(height: 80), // Bottom padding for FABs
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(_HomeData data) {
    final currentHour = DateTime.now().hour;
    String greeting;
    if (currentHour < 12) {
      greeting = 'Good Morning';
    } else if (currentHour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAuthenticated
                ? 'Welcome back!' // Simplified - no user data yet
                : 'Ready to create amazing cocktail experiences?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.local_bar, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '${data.totalCocktails} cocktails available',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.celebration,
                label: 'Join Party',
                subtitle: 'Enter party code',
                color: Colors.purple,
                onTap: () => context.push(AppRoutes.joinParty),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.party_mode,
                label: 'Create Party',
                subtitle: 'Host your event',
                color: Colors.orange,
                onTap: () => context.push(AppRoutes.createParty),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(_HomeData data) {
    if (data.featuredCocktails.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Today',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Navigate to explore screen - placeholder for now
                // In a real app, this could navigate to explore with featured filter
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.featuredCocktails.length,
            itemBuilder: (context, index) {
              final (id, doc) = data.featuredCocktails[index];
              final locale = context.watch<LocaleProvider>().currentLocale;
              final cocktail = doc.toEntity(id, locale);
              return _buildFeaturedCocktailCard(cocktail);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCocktailCard(Cocktail cocktail) {
    // Get first category or use classic as fallback
    final category = cocktail.categories.isNotEmpty
        ? cocktail.categories.first
        : CocktailCategory.classic;

    return GestureDetector(
      onTap: () => context.push('${AppRoutes.cocktailDetails}/${cocktail.id}'),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CocktailCategories.getCategoryColor(
                        category,
                      ).withValues(alpha: .8),
                      CocktailCategories.getCategoryColor(category),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.local_bar,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Featured',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cocktail.title.translate(context),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cocktail.description.translate(context),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Simplified - no prep time or difficulty in current model
                      Text(
                        CocktailCategories.getCategoryDisplayName(category),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(_HomeData data) {
    if (data.categorizedCocktails.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Browse Categories',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.categorizedCocktails.keys.length,
            itemBuilder: (context, index) {
              final category = data.categorizedCocktails.keys.elementAt(index);
              final cocktails = data.categorizedCocktails[category]!;
              return _buildCategoryCard(category, cocktails.length);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(CocktailCategory category, int count) {
    return GestureDetector(
      onTap: () {
        // Navigate to explore screen with category filter - placeholder for now
        // In a real app, this could navigate to explore with this category selected
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              CocktailCategories.getCategoryColor(
                category,
              ).withValues(alpha: 0.8),
              CocktailCategories.getCategoryColor(category),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CocktailCategories.getCategoryIcon(category),
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                CocktailCategories.getCategoryDisplayName(category),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '$count cocktails',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularSection(_HomeData data) {
    if (data.popularCocktails.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Latest Cocktails',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Navigate to explore screen - placeholder for now
                // In a real app, this could navigate to explore with popular filter
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.popularCocktails.length,
          itemBuilder: (context, index) {
            final (id, doc) = data.popularCocktails[index];
            final locale = context.watch<LocaleProvider>().currentLocale;
            final cocktail = doc.toEntity(id, locale);
            return _buildPopularCocktailItem(cocktail);
          },
        ),
      ],
    );
  }

  Widget _buildPopularCocktailItem(Cocktail cocktail) {
    final category = cocktail.categories.isNotEmpty
        ? cocktail.categories.first
        : CocktailCategory.classic;

    return GestureDetector(
      onTap: () => context.push('${AppRoutes.cocktailDetails}/${cocktail.id}'),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CocktailCategories.getCategoryColor(
                        category,
                      ).withValues(alpha: .8),
                      CocktailCategories.getCategoryColor(category),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_bar,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cocktail.title.translate(context),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CocktailCategories.getCategoryDisplayName(category),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CocktailCategories.getCategoryIcon(category),
                color: CocktailCategories.getCategoryColor(category),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
