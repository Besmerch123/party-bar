import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../../utils/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Cocktail> featuredCocktails;
  late List<Cocktail> popularCocktails;
  late Map<CocktailCategory, List<Cocktail>> categorizedCocktails;
  bool isAuthenticated = true; // Mock authentication state

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Mock featured cocktails (first 3 popular ones)
    featuredCocktails = MockData.getPopularCocktails().take(3).toList();

    // Mock popular cocktails
    popularCocktails = MockData.getPopularCocktails();

    // Categorize cocktails for quick access
    categorizedCocktails = {};
    for (final category in CocktailCategory.values) {
      final cocktails = MockData.getCocktailsByCategory(category);
      if (cocktails.isNotEmpty) {
        categorizedCocktails[category] = cocktails.take(3).toList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PartyBar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to explore screen
              if (context.mounted) {
                // We'll need to update this when we have proper tab navigation
                // For now, this is a placeholder
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifications(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadData();
          });
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildFeaturedSection(),
              const SizedBox(height: 24),
              _buildCategoriesSection(),
              const SizedBox(height: 24),
              if (isAuthenticated) ...[
                _buildRecentActivitySection(),
                const SizedBox(height: 24),
              ],
              _buildPopularSection(),
              const SizedBox(height: 80), // Bottom padding for FABs
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildWelcomeSection() {
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
                ? 'Welcome back, ${MockData.users.first.name}!'
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
                '${MockData.cocktails.length} cocktails available',
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

  Widget _buildFeaturedSection() {
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
            itemCount: featuredCocktails.length,
            itemBuilder: (context, index) {
              return _buildFeaturedCocktailCard(featuredCocktails[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCocktailCard(Cocktail cocktail) {
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
                      _getCategoryColor(cocktail.category).withOpacity(0.8),
                      _getCategoryColor(cocktail.category),
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
                        cocktail.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cocktail.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${cocktail.prepTimeMinutes}m',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          _buildDifficultyBadge(cocktail.difficulty),
                        ],
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

  Widget _buildCategoriesSection() {
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
            itemCount: categorizedCocktails.keys.length,
            itemBuilder: (context, index) {
              final category = categorizedCocktails.keys.elementAt(index);
              final cocktails = categorizedCocktails[category]!;
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
              _getCategoryColor(category).withOpacity(0.8),
              _getCategoryColor(category),
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
              Icon(_getCategoryIcon(category), color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                _getCategoryDisplayName(category),
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

  Widget _buildRecentActivitySection() {
    // Mock recent activity data
    final recentOrders = MockData.orders.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: recentOrders.map((order) {
                final cocktail = MockData.getCocktailById(order.cocktailId);
                return _buildActivityItem(
                  title: cocktail?.name ?? 'Unknown Cocktail',
                  subtitle: 'Ordered ${_getTimeAgo(order.createdAt)}',
                  status: order.status,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required OrderStatus status,
  }) {
    Color statusColor;
    String statusText;

    switch (status) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case OrderStatus.preparing:
        statusColor = Colors.blue;
        statusText = 'Preparing';
        break;
      case OrderStatus.ready:
        statusColor = Colors.green;
        statusText = 'Ready';
        break;
      case OrderStatus.delivered:
        statusColor = Colors.grey;
        statusText = 'Delivered';
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Cocktails',
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
          itemCount: popularCocktails.take(5).length,
          itemBuilder: (context, index) {
            return _buildPopularCocktailItem(popularCocktails[index]);
          },
        ),
      ],
    );
  }

  Widget _buildPopularCocktailItem(Cocktail cocktail) {
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
                      _getCategoryColor(cocktail.category).withOpacity(0.8),
                      _getCategoryColor(cocktail.category),
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
                      cocktail.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${cocktail.prepTimeMinutes}m • ${_getDifficultyDisplayName(cocktail.difficulty)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.star, color: Colors.amber, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "create_party",
          onPressed: () => context.push(AppRoutes.createParty),
          backgroundColor: Colors.orange,
          child: const Icon(Icons.party_mode),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: "join_party",
          onPressed: () => context.push(AppRoutes.joinParty),
          backgroundColor: Colors.purple,
          child: const Icon(Icons.celebration),
        ),
      ],
    );
  }

  Widget _buildDifficultyBadge(CocktailDifficulty difficulty) {
    Color color;
    switch (difficulty) {
      case CocktailDifficulty.easy:
        color = Colors.green;
        break;
      case CocktailDifficulty.medium:
        color = Colors.orange;
        break;
      case CocktailDifficulty.hard:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        _getDifficultyDisplayName(difficulty),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getCategoryColor(CocktailCategory category) {
    switch (category) {
      case CocktailCategory.classic:
        return Colors.brown;
      case CocktailCategory.modern:
        return Colors.purple;
      case CocktailCategory.tropical:
        return Colors.orange;
      case CocktailCategory.martini:
        return Colors.blue;
      case CocktailCategory.whiskey:
        return Colors.amber;
      case CocktailCategory.vodka:
        return Colors.cyan;
      case CocktailCategory.rum:
        return Colors.deepOrange;
      case CocktailCategory.gin:
        return Colors.teal;
      case CocktailCategory.shots:
        return Colors.red;
      case CocktailCategory.mocktail:
        return Colors.green;
    }
  }

  IconData _getCategoryIcon(CocktailCategory category) {
    switch (category) {
      case CocktailCategory.classic:
        return Icons.history;
      case CocktailCategory.modern:
        return Icons.auto_awesome;
      case CocktailCategory.tropical:
        return Icons.wb_sunny;
      case CocktailCategory.martini:
        return Icons.wine_bar;
      case CocktailCategory.whiskey:
        return Icons.local_bar;
      case CocktailCategory.vodka:
        return Icons.ac_unit;
      case CocktailCategory.rum:
        return Icons.sailing;
      case CocktailCategory.gin:
        return Icons.local_florist;
      case CocktailCategory.shots:
        return Icons.flash_on;
      case CocktailCategory.mocktail:
        return Icons.eco;
    }
  }

  String _getCategoryDisplayName(CocktailCategory category) {
    switch (category) {
      case CocktailCategory.classic:
        return 'Classic';
      case CocktailCategory.modern:
        return 'Modern';
      case CocktailCategory.tropical:
        return 'Tropical';
      case CocktailCategory.martini:
        return 'Martini';
      case CocktailCategory.whiskey:
        return 'Whiskey';
      case CocktailCategory.vodka:
        return 'Vodka';
      case CocktailCategory.rum:
        return 'Rum';
      case CocktailCategory.gin:
        return 'Gin';
      case CocktailCategory.shots:
        return 'Shots';
      case CocktailCategory.mocktail:
        return 'Mocktail';
    }
  }

  String _getDifficultyDisplayName(CocktailDifficulty difficulty) {
    switch (difficulty) {
      case CocktailDifficulty.easy:
        return 'Easy';
      case CocktailDifficulty.medium:
        return 'Medium';
      case CocktailDifficulty.hard:
        return 'Hard';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text('No new notifications'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
