import 'package:flutter/material.dart';
import 'package:party_bar/widgets/party/party_status_control.dart';
import '../../utils/localization_helper.dart';
import '../../models/models.dart';

/// Banner widget showing party status and quick actions for host
class PartyHostStatusBanner extends StatelessWidget {
  final Party party;
  final VoidCallback onShareCode;
  final VoidCallback? onShowQRCode;

  const PartyHostStatusBanner({
    super.key,
    required this.party,
    required this.onShareCode,
    this.onShowQRCode,
  });

  @override
  Widget build(BuildContext context) {
    final color = PartyStatusControl.getStatusColor(party.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            PartyStatusControl.getStatusIcon(party.status),
            color: color.shade600,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PartyStatusControl.getStatusLabel(context, party.status),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color.shade800,
                  ),
                ),
                Text(
                  context.l10n.code(party.joinCode),
                  style: TextStyle(fontSize: 14, color: color.shade700),
                ),
              ],
            ),
          ),
          if (onShowQRCode != null)
            IconButton(
              onPressed: onShowQRCode,
              icon: Icon(Icons.qr_code, color: color.shade700),
            ),
          IconButton(
            onPressed: onShareCode,
            icon: const Icon(Icons.share, size: 16),
            style: ElevatedButton.styleFrom(
              backgroundColor: color.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
