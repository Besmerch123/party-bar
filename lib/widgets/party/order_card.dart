import 'package:flutter/material.dart';
import '../../utils/localization_helper.dart';
import '../../models/models.dart';

/// Card widget displaying a single cocktail order
class OrderCard extends StatelessWidget {
  final CocktailOrder order;
  final Cocktail? cocktail;
  final MaterialColor accentColor;
  final VoidCallback? onStartPreparing;
  final VoidCallback? onMarkReady;
  final VoidCallback? onMarkDelivered;

  const OrderCard({
    super.key,
    required this.order,
    this.cocktail,
    required this.accentColor,
    this.onStartPreparing,
    this.onMarkReady,
    this.onMarkDelivered,
  });

  String _formatTime(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return context.l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return context.l10n.minutesAgo(difference.inMinutes);
    } else {
      return context.l10n.hoursAgo(difference.inHours);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        cocktail?.title.translate(context) ??
                            context.l10n.unknownCocktail,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        context.l10n.forGuest(order.guestName),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        context.l10n.ordered(
                          _formatTime(context, order.createdAt),
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
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
            Row(children: _buildActionButtons(context)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    switch (order.status) {
      case OrderStatus.pending:
        return [
          if (onStartPreparing != null)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onStartPreparing,
                icon: const Icon(Icons.play_arrow, size: 16),
                label: Text(context.l10n.startPreparing),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ];
      case OrderStatus.preparing:
        return [
          if (onMarkReady != null)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onMarkReady,
                icon: const Icon(Icons.check, size: 16),
                label: Text(context.l10n.markReady),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ];
      case OrderStatus.ready:
        return [
          if (onMarkDelivered != null)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onMarkDelivered,
                icon: const Icon(Icons.local_shipping, size: 16),
                label: Text(context.l10n.markDelivered),
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
}
