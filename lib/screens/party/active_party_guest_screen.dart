import 'package:flutter/material.dart';
import 'package:party_bar/data/cocktail_repository.dart';
import 'package:party_bar/services/order_service.dart';
import 'package:party_bar/utils/localization_helper.dart';
import 'package:party_bar/widgets/party/order_cocktail_dialog.dart';
import 'package:party_bar/widgets/party/party_menu_tab.dart';
import 'package:party_bar/widgets/party/party_orders_tab.dart';
import 'package:party_bar/widgets/party/party_stats_tab.dart';

import '../../models/models.dart';

class ActivePartyGuestScreen extends StatefulWidget {
  final Party party;
  final String guestName;

  const ActivePartyGuestScreen({
    super.key,
    required this.party,
    required this.guestName,
  });

  @override
  State<ActivePartyGuestScreen> createState() => _ActivePartyGuestScreenState();
}

class _ActivePartyGuestScreenState extends State<ActivePartyGuestScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final OrderService _orderService = OrderService();
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

  Future<void> _showOrderDialog(BuildContext context, Cocktail cocktail) async {
    final specialRequests = await showDialog<String>(
      context: context,
      builder: (context) =>
          OrderCocktailDialog(cocktail: cocktail, onConfirm: () {}),
    );

    // User cancelled the dialog
    if (specialRequests == null) return;

    // Place the order
    await _placeOrder(cocktail, specialRequests);
  }

  /// Place an order for a cocktail
  Future<void> _placeOrder(Cocktail cocktail, String specialRequests) async {
    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _orderService.createOrder(
        partyId: widget.party.id,
        cocktailId: cocktail.id,
        guestName: widget.guestName,
        specialRequests: specialRequests.isEmpty ? null : specialRequests,
      );

      if (!mounted) return;

      // Close loading indicator
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.orderConfirmation(cocktail.title.translate(context)),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Switch to the Orders tab to show the new order
      _tabController.animateTo(1);
    } catch (e) {
      if (!mounted) return;

      // Close loading indicator
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.errorWithMessage(e.toString())),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
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
      renderItemTrailing: (cocktail) => IconButton(
        icon: const Icon(Icons.add_circle_outline),
        color: Theme.of(context).colorScheme.primary,
        tooltip: context.l10n.orderNow,
        onPressed: () => _showOrderDialog(context, cocktail),
      ),
    );
  }
}
