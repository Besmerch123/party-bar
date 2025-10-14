import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../data/cocktail_repository.dart';
import '../../providers/locale_provider.dart';
import '../../widgets//common//image_widget.dart';

class CocktailDetailsScreen extends StatefulWidget {
  final String cocktailId;

  const CocktailDetailsScreen({super.key, required this.cocktailId});

  @override
  State<CocktailDetailsScreen> createState() => _CocktailDetailsScreenState();
}

class _CocktailDetailsScreenState extends State<CocktailDetailsScreen> {
  final CocktailRepository _cocktailRepo = CocktailRepository();
  final IngredientRepository _ingredientRepo = IngredientRepository();
  final EquipmentRepository _equipmentRepo = EquipmentRepository();

  CocktailDocument? _cocktailDoc;
  List<Ingredient> ingredients = [];
  List<Equipment> equipments = [];
  bool isFavorite = false;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCocktail();
  }

  Future<void> _loadCocktail() async {
    // Only show loading on first load or when explicitly refreshing
    if (_cocktailDoc == null) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final locale = context.read<LocaleProvider>().currentLocale;

      // Fetch cocktail document (untranslated)
      final fetchedCocktailDoc = await _cocktailRepo.getCocktailDocument(
        widget.cocktailId,
      );

      if (fetchedCocktailDoc == null) {
        setState(() {
          errorMessage = 'Cocktail not found';
          isLoading = false;
        });
        return;
      }

      final (id, doc) = fetchedCocktailDoc;

      // Fetch related ingredients and equipment in parallel for better performance
      final results = await Future.wait([
        _ingredientRepo.getIngredientsByPaths(doc.ingredients, locale: locale),
        _equipmentRepo.getEquipmentsByPaths(doc.equipments, locale: locale),
      ]);

      setState(() {
        _cocktailDoc = doc;
        ingredients = results[0] as List<Ingredient>;
        equipments = results[1] as List<Equipment>;
        isLoading = false;
        // TODO: Check favorites from user preferences/Firestore
        isFavorite = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading cocktail: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cocktail Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null || _cocktailDoc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cocktail Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? 'Cocktail not found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadCocktail,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Translate cocktail on-demand based on current locale
    final locale = context.watch<LocaleProvider>().currentLocale;
    final cocktail = _cocktailDoc!.toEntity(widget.cocktailId, locale);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(cocktail),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(cocktail),
                  const SizedBox(height: 24),
                  _buildCategories(cocktail),
                  const SizedBox(height: 24),
                  _buildIngredients(cocktail),
                  const SizedBox(height: 24),
                  _buildEquipment(),
                  const SizedBox(height: 80), // Bottom padding for FAB
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Cocktail cocktail) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            ImageWidget(imageUrl: cocktail.image),

            // Gradient overlay for better text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
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

  Widget _buildHeader(Cocktail cocktail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cocktail.title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          cocktail.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories(Cocktail cocktail) {
    if (cocktail.categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cocktail.categories
              .map(
                (category) => Chip(
                  label: Text(_getCategoryDisplayName(category)),
                  avatar: Icon(
                    Icons.local_bar,
                    size: 18,
                    color: _getCategoryColor(category),
                  ),
                  backgroundColor: _getCategoryColor(category).withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: _getCategoryColor(category),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildIngredients(Cocktail cocktail) {
    if (ingredients.isEmpty) {
      return const SizedBox.shrink();
    }

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
              children: ingredients
                  .map(
                    (ingredient) => _buildIngredientItem(ingredient, cocktail),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(Ingredient ingredient, Cocktail cocktail) {
    final primaryCategory = cocktail.categories.isNotEmpty
        ? cocktail.categories.first
        : CocktailCategory.classic;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getCategoryColor(primaryCategory),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  _getIngredientCategoryName(ingredient.category),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipment() {
    if (equipments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Equipment',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: equipments
                  .map((equipment) => _buildEquipmentItem(equipment))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentItem(Equipment equipment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.construction,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              equipment.title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(CocktailCategory category) {
    switch (category) {
      case CocktailCategory.classic:
        return Colors.brown;
      case CocktailCategory.signature:
        return Colors.purple;
      case CocktailCategory.seasonal:
        return Colors.orange;
      case CocktailCategory.frozen:
        return Colors.blue;
      case CocktailCategory.mocktail:
        return Colors.green;
      case CocktailCategory.shot:
        return Colors.red;
      case CocktailCategory.long:
        return Colors.cyan;
      case CocktailCategory.punch:
        return Colors.pink;
      case CocktailCategory.tiki:
        return Colors.deepOrange;
      case CocktailCategory.highball:
        return Colors.teal;
      case CocktailCategory.lowball:
        return Colors.amber;
    }
  }

  String _getCategoryDisplayName(CocktailCategory category) {
    switch (category) {
      case CocktailCategory.classic:
        return 'Classic';
      case CocktailCategory.signature:
        return 'Signature';
      case CocktailCategory.seasonal:
        return 'Seasonal';
      case CocktailCategory.frozen:
        return 'Frozen';
      case CocktailCategory.mocktail:
        return 'Mocktail';
      case CocktailCategory.shot:
        return 'Shot';
      case CocktailCategory.long:
        return 'Long Drink';
      case CocktailCategory.punch:
        return 'Punch';
      case CocktailCategory.tiki:
        return 'Tiki';
      case CocktailCategory.highball:
        return 'Highball';
      case CocktailCategory.lowball:
        return 'Lowball';
    }
  }

  String _getIngredientCategoryName(IngredientCategory category) {
    switch (category) {
      case IngredientCategory.spirit:
        return 'Spirit';
      case IngredientCategory.liqueur:
        return 'Liqueur';
      case IngredientCategory.mixer:
        return 'Mixer';
      case IngredientCategory.syrup:
        return 'Syrup';
      case IngredientCategory.bitters:
        return 'Bitters';
      case IngredientCategory.garnish:
        return 'Garnish';
      case IngredientCategory.fruit:
        return 'Fruit';
      case IngredientCategory.herb:
        return 'Herb';
      case IngredientCategory.spice:
        return 'Spice';
      case IngredientCategory.other:
        return 'Other';
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
    // Get the translated cocktail for sharing
    final locale = context.read<LocaleProvider>().currentLocale;
    final cocktail = _cocktailDoc!.toEntity(widget.cocktailId, locale);

    final ingredientsList = ingredients.map((i) => '• ${i.title}').join('\n');
    final equipmentsList = equipments.map((e) => '• ${e.title}').join('\n');
    final categoriesList = cocktail.categories
        .map((c) => _getCategoryDisplayName(c))
        .join(', ');

    final shareText =
        '''
🍸 ${cocktail.title}

${cocktail.description}

� Categories: $categoriesList

� Ingredients:
$ingredientsList

�️ Equipment:
$equipmentsList

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
    final ingredientsList = ingredients.map((i) => '• ${i.title}').join('\n');

    Clipboard.setData(ClipboardData(text: ingredientsList));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ingredients copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
