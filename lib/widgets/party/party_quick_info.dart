import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';

class PartyQuickInfo extends StatelessWidget {
  const PartyQuickInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: .3), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.partyQuickInfo,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: .8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
