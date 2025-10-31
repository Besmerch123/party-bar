import 'package:flutter/material.dart';
import '../../utils/localization_helper.dart';
import 'hosted_parties_bottom_sheet.dart';

class PartyQuickInfo extends StatelessWidget {
  const PartyQuickInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: .3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.partyQuickInfo,
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => HostedPartiesBottomSheet.show(context),
              icon: const Icon(Icons.history, size: 18),
              label: Text(context.l10n.viewMyParties),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.amber.shade700,
                side: BorderSide(color: Colors.amber.withValues(alpha: .5)),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
