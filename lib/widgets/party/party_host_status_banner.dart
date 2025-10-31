import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:party_bar/widgets/party/party_status_control.dart';
import '../../utils/localization_helper.dart';
import '../../models/models.dart';

/// Banner widget showing party status and quick actions for host
class PartyHostStatusBanner extends StatelessWidget {
  final Party party;

  const PartyHostStatusBanner({super.key, required this.party});

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
          IconButton(
            onPressed: () => _showQRCode(context),
            icon: Icon(Icons.qr_code, color: color.shade700),
          ),
          IconButton(
            onPressed: () => _sharePartyCode(context),
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

  void _sharePartyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: party.joinCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.partyCopiedToClipboard),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showQRCode(BuildContext context) {
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
              context.l10n.code(party.joinCode),
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
            onPressed: () => _sharePartyCode(context),
            child: Text(context.l10n.shareCode),
          ),
        ],
      ),
    );
  }
}
