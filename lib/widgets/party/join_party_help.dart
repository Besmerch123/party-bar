import 'package:flutter/material.dart';
import '../../utils/localization_helper.dart';

class JoinPartyHelp extends StatelessWidget {
  const JoinPartyHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.help_outline, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.askHostForCode,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
