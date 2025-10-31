import 'package:flutter/material.dart';
import '../../utils/localization_helper.dart';

class JoinPartyHeader extends StatelessWidget {
  const JoinPartyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.people, size: 60, color: Colors.blue.shade400),
          const SizedBox(height: 16),
          Text(
            context.l10n.joinTheParty,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.enterPartyCodeToOrder,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
