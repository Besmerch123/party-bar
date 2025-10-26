import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:party_bar/utils/localization_helper.dart';
import 'package:share_plus/share_plus.dart';

/// Widget to display and share party invitation code
class PartyInvitationCode extends StatelessWidget {
  final String joinCode;
  final String partyName;

  const PartyInvitationCode({
    super.key,
    required this.joinCode,
    required this.partyName,
  });

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: joinCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.codeCopied),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareCode() {
    Share.share(
      'Join my party "$partyName"!\nUse code: $joinCode',
      subject: 'Party Invitation',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code_2),
                const SizedBox(width: 8),
                Text(
                  context.l10n.invitationCode,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  joinCode,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyCode(context),
                    icon: const Icon(Icons.copy),
                    label: Text(context.l10n.copyCode),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareCode,
                    icon: const Icon(Icons.share),
                    label: Text(context.l10n.shareCode),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
