import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/models.dart';

class ActivePartyHostScreen extends StatefulWidget {
  final Party party;

  const ActivePartyHostScreen({super.key, required this.party});

  @override
  State<ActivePartyHostScreen> createState() => _ActivePartyHostScreenState();
}

class _ActivePartyHostScreenState extends State<ActivePartyHostScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<CocktailOrder> _orders = [];
  bool _partyActive = true;

  // Mock available cocktails
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _generateMockOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateMockOrders() {
    // Generate some mock orders for demonstration
    final mockOrders = [
      CocktailOrder(
        id: 'order1',
        partyId: widget.party.id,
        cocktailId: '1',
        guestName: 'Alice',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        status: OrderStatus.pending,
        specialRequests: 'Extra lime please',
      ),
      CocktailOrder(
        id: 'order2',
        partyId: widget.party.id,
        cocktailId: '2',
        guestName: 'Bob',
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
        status: OrderStatus.preparing,
      ),
      CocktailOrder(
        id: 'order3',
        partyId: widget.party.id,
        cocktailId: '1',
        guestName: 'Charlie',
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
        status: OrderStatus.ready,
      ),
    ];

    setState(() {
      _orders.addAll(mockOrders);
    });
  }

  void _updateOrderStatus(CocktailOrder order, OrderStatus newStatus) {
    setState(() {
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _orders[index] = order.copyWith(status: newStatus);
      }
    });

    final cocktail = _availableCocktails.firstWhere(
      (c) => c.id == order.cocktailId,
      orElse: () => _availableCocktails.first,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${cocktail.name} for ${order.guestName} marked as ${newStatus.name}',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sharePartyCode() {
    Clipboard.setData(ClipboardData(text: widget.party.joinCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Party code copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Party QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'QR CODE\n(Mock)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Code: ${widget.party.joinCode}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: _sharePartyCode,
            child: const Text('Share Code'),
          ),
        ],
      ),
    );
  }

  void _toggleParty() {
    setState(() {
      _partyActive = !_partyActive;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Party ${_partyActive ? 'resumed' : 'paused'}'),
        backgroundColor: _partyActive ? Colors.green : Colors.orange,
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
            Text(widget.party.name),
            Text(
              'Host Dashboard',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showQRCode,
            icon: const Icon(Icons.qr_code),
            tooltip: 'Show QR Code',
          ),
          IconButton(
            onPressed: _sharePartyCode,
            icon: const Icon(Icons.share),
            tooltip: 'Share Party Code',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _toggleParty,
                child: Row(
                  children: [
                    Icon(_partyActive ? Icons.pause : Icons.play_arrow),
                    const SizedBox(width: 8),
                    Text(_partyActive ? 'Pause Party' : 'Resume Party'),
                  ],
                ),
              ),
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.stop),
                    SizedBox(width: 8),
                    Text('End Party'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long),
                  const SizedBox(width: 4),
                  Text(
                    'Orders (${_orders.where((o) => o.status != OrderStatus.delivered).length})',
                  ),
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.analytics),
                  SizedBox(width: 4),
                  Text('Stats'),
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_bar),
                  SizedBox(width: 4),
                  Text('Menu'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOrdersTab(), _buildStatsTab(), _buildMenuTab()],
      ),
    );
  }

  Widget _buildOrdersTab() {
    final pendingOrders = _orders
        .where((o) => o.status == OrderStatus.pending)
        .toList();
    final preparingOrders = _orders
        .where((o) => o.status == OrderStatus.preparing)
        .toList();
    final readyOrders = _orders
        .where((o) => o.status == OrderStatus.ready)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Party Status
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: _partyActive ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _partyActive
                  ? Colors.green.shade200
                  : Colors.orange.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _partyActive ? Icons.celebration : Icons.pause_circle,
                color: _partyActive
                    ? Colors.green.shade600
                    : Colors.orange.shade600,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _partyActive ? 'Party Active' : 'Party Paused',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _partyActive
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                      ),
                    ),
                    Text(
                      'Code: ${widget.party.joinCode}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _partyActive
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _sharePartyCode,
                icon: const Icon(Icons.share, size: 16),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _partyActive
                      ? Colors.green.shade600
                      : Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Pending Orders
        if (pendingOrders.isNotEmpty) ...[
          _buildOrderSection('New Orders', pendingOrders, Colors.orange),
          const SizedBox(height: 20),
        ],

        // Preparing Orders
        if (preparingOrders.isNotEmpty) ...[
          _buildOrderSection('Preparing', preparingOrders, Colors.blue),
          const SizedBox(height: 20),
        ],

        // Ready Orders
        if (readyOrders.isNotEmpty) ...[
          _buildOrderSection('Ready for Pickup', readyOrders, Colors.green),
          const SizedBox(height: 20),
        ],

        // No orders message
        if (_orders.where((o) => o.status != OrderStatus.delivered).isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.hourglass_empty,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No pending orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'Orders will appear here as guests place them',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOrderSection(
    String title,
    List<CocktailOrder> orders,
    MaterialColor color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, color: color, size: 12),
            const SizedBox(width: 8),
            Text(
              '$title (${orders.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...orders.map((order) => _buildOrderCard(order, color)),
      ],
    );
  }

  Widget _buildOrderCard(CocktailOrder order, MaterialColor accentColor) {
    final cocktail = _availableCocktails.firstWhere(
      (c) => c.id == order.cocktailId,
      orElse: () => _availableCocktails.first,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accentColor.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_bar,
                    color: accentColor.shade700,
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'For: ${order.guestName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Ordered: ${_formatTime(order.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${cocktail.prepTimeMinutes} min',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            if (order.specialRequests?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, color: Colors.amber.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.specialRequests!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(children: [...(_getNextStatusButtons(order, accentColor))]),
          ],
        ),
      ),
    );
  }

  List<Widget> _getNextStatusButtons(
    CocktailOrder order,
    MaterialColor accentColor,
  ) {
    switch (order.status) {
      case OrderStatus.pending:
        return [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateOrderStatus(order, OrderStatus.preparing),
              icon: const Icon(Icons.play_arrow, size: 16),
              label: const Text('Start Preparing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ];
      case OrderStatus.preparing:
        return [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateOrderStatus(order, OrderStatus.ready),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Mark Ready'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ];
      case OrderStatus.ready:
        return [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateOrderStatus(order, OrderStatus.delivered),
              icon: const Icon(Icons.local_shipping, size: 16),
              label: const Text('Mark Delivered'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildStatsTab() {
    final totalOrders = _orders.length;
    final completedOrders = _orders
        .where((o) => o.status == OrderStatus.delivered)
        .length;
    final pendingOrders = _orders
        .where((o) => o.status == OrderStatus.pending)
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Party Overview
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Party Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(
                      'Total Orders',
                      totalOrders.toString(),
                      Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Completed',
                      completedOrders.toString(),
                      Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(
                      'Pending',
                      pendingOrders.toString(),
                      Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Active Time',
                      _getActiveTime(),
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Popular Cocktails
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Popular Cocktails',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...(_getPopularCocktails().map(
                  (entry) => _buildPopularCocktailItem(entry),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, MaterialColor color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.shade200),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 12, color: color.shade600)),
          ],
        ),
      ),
    );
  }

  List<MapEntry<String, int>> _getPopularCocktails() {
    final cocktailCounts = <String, int>{};
    for (final order in _orders) {
      final cocktail = _availableCocktails.firstWhere(
        (c) => c.id == order.cocktailId,
        orElse: () => _availableCocktails.first,
      );
      cocktailCounts[cocktail.name] = (cocktailCounts[cocktail.name] ?? 0) + 1;
    }
    final sortedEntries = cocktailCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(3).toList();
  }

  Widget _buildPopularCocktailItem(MapEntry<String, int> entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.local_bar, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(child: Text(entry.key)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${entry.value}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTab() {
    final availableCocktails = _availableCocktails
        .where((c) => widget.party.availableCocktailIds.contains(c.id))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Available Cocktails (${availableCocktails.length})',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...availableCocktails.map(
          (cocktail) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.local_bar, color: Colors.purple.shade600),
              ),
              title: Text(cocktail.name),
              subtitle: Text(
                '${cocktail.difficulty.name.substring(0, 1).toUpperCase() + cocktail.difficulty.name.substring(1)} • ${cocktail.prepTimeMinutes} min',
              ),
              trailing: Text(
                '${_orders.where((o) => o.cocktailId == cocktail.id).length} orders',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  String _getActiveTime() {
    final duration = DateTime.now().difference(widget.party.createdAt);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
