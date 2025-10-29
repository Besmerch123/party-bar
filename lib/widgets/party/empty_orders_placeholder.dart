import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';

/// Placeholder widget shown when there are no orders
class EmptyOrdersPlaceholder extends StatelessWidget {
  const EmptyOrdersPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 60,
            color: Theme.of(context).primaryColorLight,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noPendingOrders,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          Text(
            l10n.ordersWillAppear,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
        ],
      ),
    );
  }
}
