import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/localization_helper.dart';
import 'order_card.dart';
import 'order_section.dart';
import 'party_host_status_banner.dart';
import 'empty_orders_placeholder.dart';

enum Role { guest, host }

/// A widget that displays the orders tab for a party, showing pending,
/// preparing, and ready orders.
class PartyOrdersTab extends StatelessWidget {
  final Party party;
  final List<CocktailOrder> orders;
  final List<Cocktail> availableCocktails;
  final Function(CocktailOrder, OrderStatus)? onUpdateOrderStatus;
  final Role? role;

  const PartyOrdersTab({
    super.key,
    required this.party,
    required this.orders,
    required this.availableCocktails,
    this.onUpdateOrderStatus,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    final pendingOrders = orders
        .where((o) => o.status == OrderStatus.pending)
        .toList();
    final preparingOrders = orders
        .where((o) => o.status == OrderStatus.preparing)
        .toList();
    final readyOrders = orders
        .where((o) => o.status == OrderStatus.ready)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Party Status Banner
        if (role == Role.host) PartyHostStatusBanner(party: party),

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
        if (orders.where((o) => o.status != OrderStatus.delivered).isEmpty)
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
      cocktail = availableCocktails.firstWhere((c) => c.id == order.cocktailId);
    } catch (_) {
      // Cocktail not found in available list
      cocktail = null;
    }

    return OrderCard(
      order: order,
      cocktail: cocktail,
      accentColor: accentColor,
      onStartPreparing:
          onUpdateOrderStatus != null && order.status == OrderStatus.pending
          ? () => onUpdateOrderStatus!(order, OrderStatus.preparing)
          : null,
      onMarkReady:
          onUpdateOrderStatus != null && order.status == OrderStatus.preparing
          ? () => onUpdateOrderStatus!(order, OrderStatus.ready)
          : null,
      onMarkDelivered:
          onUpdateOrderStatus != null && order.status == OrderStatus.ready
          ? () => onUpdateOrderStatus!(order, OrderStatus.delivered)
          : null,
    );
  }
}
