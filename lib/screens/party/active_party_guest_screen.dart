import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../explore/cocktail_details_screen.dart';

class ActivePartyGuestScreen extends StatefulWidget {
  final String partyCode;
  final String guestName;

  const ActivePartyGuestScreen({
    super.key,
    required this.partyCode,
    required this.guestName,
  });

  @override
  State<ActivePartyGuestScreen> createState() => _ActivePartyGuestScreenState();
}

class _ActivePartyGuestScreenState extends State<ActivePartyGuestScreen> {
  final List<CocktailOrder> _currentOrders = [];
  bool _isOrdering = false;

  // Mock party data
  final Party _mockParty = Party(
    id: 'party123',
    name: 'Sarah\'s Birthday Bash',
    hostId: 'host123',
    hostName: 'Sarah',
    availableCocktailIds: ['1', '2', '3', '4', '5'],
    joinCode: 'PARTY123',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    totalOrders: 15,
    description: 'Birthday party with amazing cocktails!',
  );

  // Mock available cocktails for this party
  final List<Cocktail> _availableCocktails = [
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
  ];

  void _orderCocktail(Cocktail cocktail) async {
    setState(() {
      _isOrdering = true;
    });

    // Simulate ordering
    await Future.delayed(const Duration(seconds: 1));

    final order = CocktailOrder(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      partyId: _mockParty.id,
      cocktailId: cocktail.id,
      guestName: widget.guestName,
      createdAt: DateTime.now(),
    );

    setState(() {
      _currentOrders.add(order);
      _isOrdering = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${cocktail.name} ordered successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showOrderDialog(Cocktail cocktail) {
    final specialRequestsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order ${cocktail.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to order ${cocktail.name}?'),
            const SizedBox(height: 16),
            TextField(
              controller: specialRequestsController,
              decoration: const InputDecoration(
                labelText: 'Special requests (optional)',
                hintText: 'e.g., extra lime, no sugar...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _orderCocktail(cocktail);
            },
            child: const Text('Order'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_mockParty.name),
            Text(
              'Welcome, ${widget.guestName}!',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Party Info'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Party: ${_mockParty.name}'),
                      Text('Host: ${_mockParty.hostName}'),
                      Text('Code: ${_mockParty.joinCode}'),
                      Text('Total Orders: ${_mockParty.totalOrders}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          // Current Orders Status
          if (_currentOrders.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Your Orders (${_currentOrders.length})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...(_currentOrders.take(3).map((order) {
                    final cocktail = _availableCocktails.firstWhere(
                      (c) => c.id == order.cocktailId,
                      orElse: () => _availableCocktails.first,
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(cocktail.name)),
                          Text(
                            _getStatusText(order.status),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(order.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  })),
                  if (_currentOrders.length > 3)
                    Text(
                      'and ${_currentOrders.length - 3} more...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
          ],

          // Available Cocktails Menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Available Cocktails',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...(_availableCocktails.map(
                  (cocktail) => _buildCocktailCard(cocktail),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCocktailCard(Cocktail cocktail) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_bar,
                    color: Colors.purple.shade600,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cocktail.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        cocktail.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${cocktail.prepTimeMinutes} min',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(cocktail.difficulty),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              cocktail.difficulty.name
                                      .substring(0, 1)
                                      .toUpperCase() +
                                  cocktail.difficulty.name.substring(1),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CocktailDetailsScreen(cocktailId: cocktail.id),
                        ),
                      );
                    },
                    child: const Text('View Recipe'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isOrdering
                        ? null
                        : () => _showOrderDialog(cocktail),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: _isOrdering
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Order'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
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
}
