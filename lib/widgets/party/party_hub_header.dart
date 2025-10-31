import 'package:flutter/material.dart';
import '../../utils/localization_helper.dart';

class PartyHubHeader extends StatelessWidget {
  const PartyHubHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.withValues(alpha: .3),
            Colors.deepPurple.withValues(alpha: .1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.deepPurple.withValues(alpha: .3)),
      ),
      child: Column(
        children: [
          Icon(Icons.celebration, size: 60, color: Colors.deepPurple.shade400),
          const SizedBox(height: 16),
          Text(
            context.l10n.welcomeToPartyBar,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade300,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.joinOrCreateParty,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: .7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
