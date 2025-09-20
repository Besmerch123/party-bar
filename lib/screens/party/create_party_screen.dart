import 'package:flutter/material.dart';

import '../../models/models.dart';
import 'active_party_host_screen.dart';

class CreatePartyScreen extends StatefulWidget {
  const CreatePartyScreen({super.key});

  @override
  State<CreatePartyScreen> createState() => _CreatePartyScreenState();
}

class _CreatePartyScreenState extends State<CreatePartyScreen> {
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final Set<String> _selectedCocktailIds = {};
  bool _isCreating = false;

  // Mock available cocktails to choose from
  final List<Cocktail> _allCocktails = [
    Cocktail(
      id: '1',
      name: 'Mojito',
      description: 'Fresh mint, lime, and rum cocktail',
      ingredients: [
        CocktailIngredient(name: 'White rum', amount: '2 oz'),
        CocktailIngredient(name: 'Fresh mint', amount: '10 leaves'),
        CocktailIngredient(name: 'Lime juice', amount: '1 oz'),
        CocktailIngredient(name: 'Sugar', amount: '1 tsp'),
        CocktailIngredient(name: 'Soda water', amount: '3 oz'),
      ],
      instructions: [
        'Muddle mint and lime',
        'Add rum and sugar',
        'Top with soda water',
      ],
      difficulty: CocktailDifficulty.easy,
      category: CocktailCategory.classic,
      imageUrl: 'https://example.com/mojito.jpg',
      prepTimeMinutes: 5,
      alcoholContent: 15.0,
    ),
    Cocktail(
      id: '2',
      name: 'Margarita',
      description: 'Classic tequila cocktail with lime',
      ingredients: [
        CocktailIngredient(name: 'Tequila', amount: '2 oz'),
        CocktailIngredient(name: 'Triple sec', amount: '1 oz'),
        CocktailIngredient(name: 'Lime juice', amount: '1 oz'),
        CocktailIngredient(name: 'Salt', amount: 'for rim'),
      ],
      instructions: [
        'Rim glass with salt',
        'Shake ingredients with ice',
        'Strain into glass',
      ],
      difficulty: CocktailDifficulty.easy,
      category: CocktailCategory.classic,
      imageUrl: 'https://example.com/margarita.jpg',
      prepTimeMinutes: 3,
      alcoholContent: 18.0,
    ),
    Cocktail(
      id: '3',
      name: 'Old Fashioned',
      description: 'Classic whiskey cocktail',
      ingredients: [
        CocktailIngredient(name: 'Bourbon', amount: '2 oz'),
        CocktailIngredient(name: 'Sugar', amount: '1 cube'),
        CocktailIngredient(name: 'Angostura bitters', amount: '2 dashes'),
        CocktailIngredient(name: 'Orange peel', amount: '1 twist'),
      ],
      instructions: [
        'Muddle sugar and bitters',
        'Add whiskey and ice',
        'Garnish with orange',
      ],
      difficulty: CocktailDifficulty.medium,
      category: CocktailCategory.classic,
      imageUrl: 'https://example.com/oldfashioned.jpg',
      prepTimeMinutes: 4,
      alcoholContent: 25.0,
    ),
    Cocktail(
      id: '4',
      name: 'Piña Colada',
      description: 'Tropical coconut and pineapple cocktail',
      ingredients: [
        CocktailIngredient(name: 'White rum', amount: '2 oz'),
        CocktailIngredient(name: 'Coconut cream', amount: '2 oz'),
        CocktailIngredient(name: 'Pineapple juice', amount: '4 oz'),
      ],
      instructions: [
        'Blend all ingredients with ice',
        'Serve in hurricane glass',
      ],
      difficulty: CocktailDifficulty.easy,
      category: CocktailCategory.tropical,
      imageUrl: 'https://example.com/pinacolada.jpg',
      prepTimeMinutes: 3,
      alcoholContent: 12.0,
    ),
    Cocktail(
      id: '5',
      name: 'Negroni',
      description: 'Bitter Italian cocktail',
      ingredients: [
        CocktailIngredient(name: 'Gin', amount: '1 oz'),
        CocktailIngredient(name: 'Campari', amount: '1 oz'),
        CocktailIngredient(name: 'Sweet vermouth', amount: '1 oz'),
      ],
      instructions: [
        'Stir ingredients with ice',
        'Strain over ice',
        'Garnish with orange',
      ],
      difficulty: CocktailDifficulty.medium,
      category: CocktailCategory.classic,
      imageUrl: 'https://example.com/negroni.jpg',
      prepTimeMinutes: 2,
      alcoholContent: 24.0,
    ),
    Cocktail(
      id: '6',
      name: 'Cosmopolitan',
      description: 'Pink vodka cocktail',
      ingredients: [
        CocktailIngredient(name: 'Vodka', amount: '1.5 oz'),
        CocktailIngredient(name: 'Triple sec', amount: '0.5 oz'),
        CocktailIngredient(name: 'Cranberry juice', amount: '0.5 oz'),
        CocktailIngredient(name: 'Lime juice', amount: '0.25 oz'),
      ],
      instructions: ['Shake ingredients with ice', 'Strain into martini glass'],
      difficulty: CocktailDifficulty.easy,
      category: CocktailCategory.modern,
      imageUrl: 'https://example.com/cosmopolitan.jpg',
      prepTimeMinutes: 3,
      alcoholContent: 20.0,
    ),
  ];

  @override
  void dispose() {
    _partyNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createParty() async {
    if (_partyNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a party name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCocktailIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one cocktail'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    // Simulate party creation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final party = Party(
        id: 'party_${DateTime.now().millisecondsSinceEpoch}',
        name: _partyNameController.text.trim(),
        hostId: 'current_user_id',
        hostName: 'Current User',
        availableCocktailIds: _selectedCocktailIds.toList(),
        joinCode: _generateJoinCode(),
        createdAt: DateTime.now(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      setState(() {
        _isCreating = false;
      });

      // Navigate to active party host screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ActivePartyHostScreen(party: party),
        ),
      );
    }
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random % chars.length)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Party')),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.add_circle,
                    size: 60,
                    color: Colors.deepPurple.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Create Your Party',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set up your cocktail party and invite guests',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Party Name
                  const Text(
                    'Party Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _partyNameController,
                      decoration: InputDecoration(
                        labelText: 'Party Name *',
                        hintText: 'e.g., Sarah\'s Birthday Bash',
                        prefixIcon: Icon(
                          Icons.celebration,
                          color: Colors.deepPurple.shade400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Tell guests about your party...',
                        prefixIcon: Icon(
                          Icons.description,
                          color: Colors.deepPurple.shade400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Cocktail Selection
                  Row(
                    children: [
                      const Text(
                        'Select Available Cocktails *',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_selectedCocktailIds.length} selected',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quick Selection Buttons
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildQuickSelectButton('All Classic', () {
                        setState(() {
                          _selectedCocktailIds.addAll(
                            _allCocktails
                                .where(
                                  (c) => c.category == CocktailCategory.classic,
                                )
                                .map((c) => c.id),
                          );
                        });
                      }),
                      _buildQuickSelectButton('Easy Only', () {
                        setState(() {
                          _selectedCocktailIds.addAll(
                            _allCocktails
                                .where(
                                  (c) =>
                                      c.difficulty == CocktailDifficulty.easy,
                                )
                                .map((c) => c.id),
                          );
                        });
                      }),
                      _buildQuickSelectButton('Clear All', () {
                        setState(() {
                          _selectedCocktailIds.clear();
                        });
                      }),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Cocktail Grid
                  ...(_allCocktails.map(
                    (cocktail) => _buildCocktailSelectionCard(cocktail),
                  )),

                  const SizedBox(height: 32),

                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCreating ? null : _createParty,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: _isCreating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Create Party',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSelectButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.deepPurple.shade300),
        foregroundColor: Colors.deepPurple.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildCocktailSelectionCard(Cocktail cocktail) {
    final isSelected = _selectedCocktailIds.contains(cocktail.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.deepPurple.shade300 : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedCocktailIds.remove(cocktail.id);
            } else {
              _selectedCocktailIds.add(cocktail.id);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.deepPurple.shade100
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_bar,
                  color: isSelected
                      ? Colors.deepPurple.shade600
                      : Colors.grey.shade600,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.deepPurple.shade800
                            : Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      '${cocktail.difficulty.name.substring(0, 1).toUpperCase() + cocktail.difficulty.name.substring(1)} • ${cocktail.prepTimeMinutes} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.deepPurple.shade600
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? Colors.deepPurple.shade600
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
