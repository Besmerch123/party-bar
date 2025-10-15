import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../data/cocktail_repository.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/cocktails/cocktail_categories.dart';
import '../../widgets/cocktails/cocktail_ingredients.dart';
import '../../widgets/cocktails/preparation_steps.dart';
import '../../widgets/cocktails/equipment_list.dart';

class CocktailDetailsScreen extends StatefulWidget {
  final String cocktailId;

  const CocktailDetailsScreen({super.key, required this.cocktailId});

  @override
  State<CocktailDetailsScreen> createState() => _CocktailDetailsScreenState();
}

class _CocktailDetailsScreenState extends State<CocktailDetailsScreen> {
  final CocktailRepository _cocktailRepo = CocktailRepository();

  Cocktail? _cocktail;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCocktail();
  }

  Future<void> _loadCocktail() async {
    // Only show loading on first load or when explicitly refreshing
    if (_cocktail == null) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final locale = context.read<LocaleProvider>().currentLocale;

      // Fetch cocktail document (untranslated)
      final fetchedCocktail = await _cocktailRepo.getCocktail(
        widget.cocktailId,
        locale: locale,
      );

      if (fetchedCocktail == null) {
        setState(() {
          errorMessage = 'Cocktail not found';
          isLoading = false;
        });
        return;
      }

      setState(() {
        _cocktail = fetchedCocktail;
        isLoading = false;
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

    if (errorMessage != null || _cocktail == null) {
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

    final cocktail = _cocktail!;

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
                  CocktailCategories(categories: cocktail.categories),
                  const SizedBox(height: 24),
                  PreparationSteps(steps: cocktail.preparationSteps),
                  const SizedBox(height: 24),
                  CocktailIngredients(ingredients: cocktail.ingredients),
                  const SizedBox(height: 24),
                  EquipmentList(equipment: cocktail.equipments),
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
            _buildCoverImage(cocktail.image),

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
          icon: const Icon(Icons.share),
          onPressed: () => _shareCocktail(),
        ),
      ],
    );
  }

  Widget _buildCoverImage(String? imageUrl) {
    return imageUrl?.isNotEmpty == true
        ? Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to icon if image fails to load
              return Container(
                color: Colors.grey[300],
                child: Icon(Icons.local_bar, size: 80, color: Colors.grey[600]),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          )
        : Container(
            color: Colors.grey[300],
            child: Icon(Icons.local_bar, color: Colors.grey[600]),
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
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: .8),
          ),
        ),
      ],
    );
  }

  void _shareCocktail() {
    final cocktail = _cocktail!;

    final ingredientsList = cocktail.ingredients
        .map((i) => '• ${i.title}')
        .join('\n');
    final equipmentsList = cocktail.equipments
        .map((e) => '• ${e.title}')
        .join('\n');
    final categoriesList = cocktail.categories
        .map((c) => CocktailCategories.getCategoryDisplayName(c))
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
}
