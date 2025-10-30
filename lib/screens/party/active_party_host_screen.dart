import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/models.dart';
import '../../services/order_service.dart';
import '../../services/party_service.dart';
import '../../data/cocktail_repository.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/party/order_card.dart';
import '../../widgets/party/order_section.dart';
import '../../widgets/party/party_host_status_banner.dart';
import '../../widgets/party/empty_orders_placeholder.dart';
import '../../widgets/party/party_stats_card.dart';
import '../../widgets/party/popular_cocktails_list.dart';
import '../../widgets/party/party_menu_tab.dart';

class ActivePartyHostScreen extends StatefulWidget {
  final Party party;

  const ActivePartyHostScreen({super.key, required this.party});

  @override
  State<ActivePartyHostScreen> createState() => _ActivePartyHostScreenState();
}

class _ActivePartyHostScreenState extends State<ActivePartyHostScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final OrderService _orderService = OrderService();
  final PartyService _partyService = PartyService();
  final CocktailRepository _cocktailRepository = CocktailRepository();

  List<CocktailOrder> _orders = [];
  List<Cocktail> _availableCocktails = [];
  bool _isLoadingCocktails = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAvailableCocktails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load all available cocktails for this party
  Future<void> _loadAvailableCocktails() async {
    setState(() {
      _isLoadingCocktails = true;
      _error = null;
    });

    try {
      final cocktails = <Cocktail>[];

      // Fetch each cocktail by ID
      for (final cocktailId in widget.party.availableCocktailIds) {
        final cocktail = await _cocktailRepository.getCocktail(cocktailId);
        if (cocktail != null) {
          cocktails.add(cocktail);
        }
      }

      setState(() {
        _availableCocktails = cocktails;
        _isLoadingCocktails = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingCocktails = false;
      });
    }
  }

  /// Update order status
  Future<void> _updateOrderStatus(
    CocktailOrder order,
    OrderStatus newStatus,
  ) async {
    try {
      await _orderService.updateOrderStatus(
        widget.party.id,
        order.id,
        newStatus,
      );

      final cocktail = _availableCocktails.firstWhere(
        (c) => c.id == order.cocktailId,
        orElse: () => _availableCocktails.first,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.orderMarkedAs(
                cocktail.title.translate(context),
                order.guestName,
                newStatus.name,
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToUpdateOrder(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sharePartyCode() {
    Clipboard.setData(ClipboardData(text: widget.party.joinCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.partyCopiedToClipboard),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.partyQRCode),
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
              child: Center(
                child: Text(
                  context.l10n.qrCodeMock,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.code(widget.party.joinCode),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.close),
          ),
          ElevatedButton(
            onPressed: _sharePartyCode,
            child: Text(context.l10n.shareCode),
          ),
        ],
      ),
    );
  }

  /// Toggle party status between active and paused
  Future<void> _toggleParty() async {
    final newStatus = widget.party.status == PartyStatus.active
        ? PartyStatus.paused
        : PartyStatus.active;

    try {
      await _partyService.updatePartyStatus(widget.party.id, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == PartyStatus.active
                  ? context.l10n.partyResumed
                  : context.l10n.partyPausedMessage,
            ),
            backgroundColor: newStatus == PartyStatus.active
                ? Colors.green
                : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToUpdatePartyStatus(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(widget.party.name)],
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _toggleParty,
                child: Row(
                  children: [
                    Icon(
                      widget.party.status == PartyStatus.active
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.party.status == PartyStatus.active
                          ? context.l10n.pauseParty
                          : context.l10n.resumeParty,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Icons.stop),
                    const SizedBox(width: 8),
                    Text(context.l10n.endParty),
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
              child: StreamBuilder<List<CocktailOrder>>(
                stream: _orderService.streamPartyOrders(widget.party.id),
                builder: (context, snapshot) {
                  final activeOrders = (snapshot.data ?? [])
                      .where((o) => o.status != OrderStatus.delivered)
                      .length;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_long),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          context.l10n.ordersCount(activeOrders),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.analytics),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      context.l10n.stats,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_bar),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      context.l10n.menu,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<CocktailOrder>>(
        stream: _orderService.streamPartyOrders(widget.party.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                context.l10n.errorWithMessage(snapshot.error.toString()),
              ),
            );
          }

          // Update orders list for use in other tabs
          if (snapshot.hasData) {
            _orders = snapshot.data!;
          }

          return TabBarView(
            controller: _tabController,
            children: [_buildOrdersTab(), _buildStatsTab(), _buildMenuTab()],
          );
        },
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
        // Party Status Banner
        PartyHostStatusBanner(
          party: widget.party,
          onShareCode: _sharePartyCode,
          onShowQRCode: _showQRCode,
        ),
        const SizedBox(height: 20),

        // Pending Orders
        if (pendingOrders.isNotEmpty) ...[
          OrderSection(
            title: context.l10n.newOrders,
            count: pendingOrders.length,
            color: Colors.orange,
            children: pendingOrders
                .map(
                  (order) => _buildOrderCardWithCocktail(order, Colors.orange),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Preparing Orders
        if (preparingOrders.isNotEmpty) ...[
          OrderSection(
            title: context.l10n.preparing,
            count: preparingOrders.length,
            color: Colors.blue,
            children: preparingOrders
                .map((order) => _buildOrderCardWithCocktail(order, Colors.blue))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Ready Orders
        if (readyOrders.isNotEmpty) ...[
          OrderSection(
            title: context.l10n.readyForPickup,
            count: readyOrders.length,
            color: Colors.green,
            children: readyOrders
                .map(
                  (order) => _buildOrderCardWithCocktail(order, Colors.green),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
        ],

        // No orders message
        if (_orders.where((o) => o.status != OrderStatus.delivered).isEmpty)
          const EmptyOrdersPlaceholder(),
      ],
    );
  }

  /// Build an order card with the cocktail data
  Widget _buildOrderCardWithCocktail(
    CocktailOrder order,
    MaterialColor accentColor,
  ) {
    Cocktail? cocktail;
    try {
      cocktail = _availableCocktails.firstWhere(
        (c) => c.id == order.cocktailId,
      );
    } catch (_) {
      // Cocktail not found in available list
      cocktail = null;
    }

    return OrderCard(
      order: order,
      cocktail: cocktail,
      accentColor: accentColor,
      onStartPreparing: order.status == OrderStatus.pending
          ? () => _updateOrderStatus(order, OrderStatus.preparing)
          : null,
      onMarkReady: order.status == OrderStatus.preparing
          ? () => _updateOrderStatus(order, OrderStatus.ready)
          : null,
      onMarkDelivered: order.status == OrderStatus.ready
          ? () => _updateOrderStatus(order, OrderStatus.delivered)
          : null,
    );
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
                  context.l10n.partyOverview,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    PartyStatsCard(
                      label: context.l10n.totalOrders,
                      value: totalOrders.toString(),
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    PartyStatsCard(
                      label: context.l10n.completed,
                      value: completedOrders.toString(),
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    PartyStatsCard(
                      label: context.l10n.pending,
                      value: pendingOrders.toString(),
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    PartyStatsCard(
                      label: context.l10n.activeTime,
                      value: _getActiveTime(),
                      color: Colors.purple,
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
                  context.l10n.popularCocktails,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                PopularCocktailsList(popularCocktails: _getPopularCocktails()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<MapEntry<String, int>> _getPopularCocktails() {
    final cocktailCounts = <String, int>{};
    for (final order in _orders) {
      Cocktail? cocktail;
      try {
        cocktail = _availableCocktails.firstWhere(
          (c) => c.id == order.cocktailId,
        );
      } catch (_) {
        continue;
      }

      final name = cocktail.title.translate(context);
      cocktailCounts[name] = (cocktailCounts[name] ?? 0) + 1;
    }
    final sortedEntries = cocktailCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(3).toList();
  }

  Widget _buildMenuTab() {
    return PartyMenuTab(
      availableCocktails: _availableCocktails,
      availableCocktailIds: widget.party.availableCocktailIds,
      orders: _orders,
      isLoading: _isLoadingCocktails,
      error: _error,
      onRetry: _loadAvailableCocktails,
    );
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
