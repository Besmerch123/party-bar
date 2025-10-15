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
      title: 'Mojito',
      description: 'Fresh mint, lime, and rum cocktail',
      image: '',
      ingredients: [],
      equipments: [],
      categories: [CocktailCategory.classic, CocktailCategory.long],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Cocktail(
      id: '2',
      title: 'Margarita',
      description: 'Classic tequila cocktail with lime',
      image: '',
      ingredients: [],
      equipments: [],
      categories: [CocktailCategory.classic, CocktailCategory.lowball],
      createdAt: DateTime.now().subtract(const Duration(days: 28)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Cocktail(
      id: '3',
      title: 'Old Fashioned',
      description: 'Classic whiskey cocktail',
      image: '',
      ingredients: [],
      equipments: [],
      categories: [CocktailCategory.classic, CocktailCategory.lowball],
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Cocktail(
      id: '4',
      title: 'Piña Colada',
      description: 'Tropical coconut and pineapple cocktail',
      image: '',
      ingredients: [],
      equipments: [],
      categories: [CocktailCategory.tiki, CocktailCategory.frozen],
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Cocktail(
      id: '5',
      title: 'Negroni',
      description: 'Bitter Italian cocktail',
      image: '',
      ingredients: [],
      equipments: [],
      categories: [CocktailCategory.classic, CocktailCategory.lowball],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Cocktail(
      id: '6',
      title: 'Cosmopolitan',
      description: 'Pink vodka cocktail made famous in the 90s',
      image: '',
      ingredients: [],
      equipments: [],
      categories: [CocktailCategory.classic],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
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
                                  (c) => c.categories.contains(
                                    CocktailCategory.classic,
                                  ),
                                )
                                .map((c) => c.id),
                          );
                        });
                      }),
                      _buildQuickSelectButton('Tiki & Frozen', () {
                        setState(() {
                          _selectedCocktailIds.addAll(
                            _allCocktails
                                .where(
                                  (c) =>
                                      c.categories.contains(
                                        CocktailCategory.tiki,
                                      ) ||
                                      c.categories.contains(
                                        CocktailCategory.frozen,
                                      ),
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
                      cocktail.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.deepPurple.shade800
                            : Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      cocktail.categories.isNotEmpty
                          ? cocktail.categories
                                .map(
                                  (c) =>
                                      c.name.substring(0, 1).toUpperCase() +
                                      c.name.substring(1),
                                )
                                .join(' • ')
                          : 'Cocktail',
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
