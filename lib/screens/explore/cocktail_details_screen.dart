import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';

class CocktailDetailsScreen extends StatefulWidget {
  final String cocktailId;

  const CocktailDetailsScreen({super.key, required this.cocktailId});

  @override
  State<CocktailDetailsScreen> createState() => _CocktailDetailsScreenState();
}

class _CocktailDetailsScreenState extends State<CocktailDetailsScreen> {
  Cocktail? cocktail;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadCocktail();
  }

  void _loadCocktail() {
    cocktail = MockData.getCocktailById(widget.cocktailId);
    if (cocktail != null) {
      // Check if it's in favorites (mock logic)
      isFavorite = MockData.users.first.favoriteCoktailIds.contains(
        cocktail!.id,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (cocktail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cocktail Details')),
        body: const Center(child: Text('Cocktail not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildQuickInfo(),
                  const SizedBox(height: 24),
                  _buildIngredients(),
                  const SizedBox(height: 24),
                  _buildInstructions(),
                  const SizedBox(height: 24),
                  _buildTags(),
                  const SizedBox(height: 80), // Bottom padding for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addToOrder(),
        icon: const Icon(Icons.add),
        label: const Text('Add to Order'),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getCategoryColor(cocktail!.category).withOpacity(0.8),
                _getCategoryColor(cocktail!.category),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_bar,
                      size: 80,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getCategoryDisplayName(cocktail!.category),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (cocktail!.isPopular)
                const Positioned(
                  top: 100,
                  right: 20,
                  child: Icon(Icons.star, color: Colors.amber, size: 32),
                ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: () => _toggleFavorite(),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareCocktail(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cocktail!.name,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          cocktail!.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(
              icon: Icons.timer,
              label: 'Prep Time',
              value: '${cocktail!.prepTimeMinutes} min',
            ),
            _buildInfoItem(
              icon: Icons.bar_chart,
              label: 'Difficulty',
              value: _getDifficultyDisplayName(cocktail!.difficulty),
              color: _getDifficultyColor(cocktail!.difficulty),
            ),
            _buildInfoItem(
              icon: Icons.local_bar,
              label: 'ABV',
              value: cocktail!.alcoholContent > 0
                  ? '${cocktail!.alcoholContent.toStringAsFixed(0)}%'
                  : 'Non-Alcoholic',
              color: cocktail!.alcoholContent > 0
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ingredients',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _copyIngredients(),
              tooltip: 'Copy ingredients list',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: cocktail!.ingredients
                  .map((ingredient) => _buildIngredientItem(ingredient))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(CocktailIngredient ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getCategoryColor(cocktail!.category),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              ingredient.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: ingredient.isOptional ? TextDecoration.none : null,
                color: ingredient.isOptional
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                    : null,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${ingredient.amount}${ingredient.unit != null ? ' ${ingredient.unit}' : ''}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          if (ingredient.isOptional)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Optional',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Instructions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _copyInstructions(),
              tooltip: 'Copy instructions',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: cocktail!.instructions.asMap().entries.map((entry) {
                final index = entry.key;
                final instruction = entry.value;
                return _buildInstructionStep(index + 1, instruction);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(int stepNumber, String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _getCategoryColor(cocktail!.category),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    if (cocktail!.tags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cocktail!.tags
              .map(
                (tag) => Chip(
                  label: Text(tag),
                  backgroundColor: _getCategoryColor(
                    cocktail!.category,
                  ).withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: _getCategoryColor(cocktail!.category),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
              .toList(),
        ),
      ],
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

  Color _getDifficultyColor(CocktailDifficulty difficulty) {
    switch (difficulty) {
      case CocktailDifficulty.easy:
        return Colors.green;
      case CocktailDifficulty.medium:
        return Colors.orange;
      case CocktailDifficulty.hard:
        return Colors.red;
    }
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _toggleFavorite(),
        ),
      ),
    );
  }

  void _shareCocktail() {
    final ingredients = cocktail!.ingredients
        .map(
          (i) =>
              '• ${i.name}: ${i.amount}${i.unit != null ? ' ${i.unit}' : ''}',
        )
        .join('\n');

    final instructions = cocktail!.instructions
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');

    final shareText =
        '''
🍸 ${cocktail!.name}

${cocktail!.description}

📋 Ingredients:
$ingredients

📝 Instructions:
$instructions

⏱️ Prep Time: ${cocktail!.prepTimeMinutes} minutes
📊 Difficulty: ${_getDifficultyDisplayName(cocktail!.difficulty)}
🥃 ABV: ${cocktail!.alcoholContent > 0 ? '${cocktail!.alcoholContent.toStringAsFixed(0)}%' : 'Non-Alcoholic'}

Made with PartyBar App 🎉
''';

    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recipe copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyIngredients() {
    final ingredients = cocktail!.ingredients
        .map(
          (i) =>
              '• ${i.name}: ${i.amount}${i.unit != null ? ' ${i.unit}' : ''}${i.isOptional ? ' (optional)' : ''}',
        )
        .join('\n');

    Clipboard.setData(ClipboardData(text: ingredients));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ingredients copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyInstructions() {
    final instructions = cocktail!.instructions
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');

    Clipboard.setData(ClipboardData(text: instructions));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Instructions copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addToOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${cocktail!.name} added to order queue!'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'View Orders',
          onPressed: () {
            // Navigate to orders or party screen
          },
        ),
      ),
    );
  }
}
