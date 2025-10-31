import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/order_service.dart';
import '../../services/party_service.dart';
import '../../data/cocktail_repository.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/party/party_menu_tab.dart';
import '../../widgets/party/party_orders_tab.dart';
import '../../widgets/party/party_stats_tab.dart';

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
            children: [_buildMenuTab(), _buildOrdersTab(), _buildStatsTab()],
          );
        },
      ),
    );
  }

  Widget _buildOrdersTab() {
    return PartyOrdersTab(
      party: widget.party,
      orders: _orders,
      availableCocktails: _availableCocktails,
      onUpdateOrderStatus: _updateOrderStatus,
      role: Role.host,
    );
  }

  Widget _buildStatsTab() {
    return PartyStatsTab(
      party: widget.party,
      orders: _orders,
      availableCocktails: _availableCocktails,
    );
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
}
