import 'package:flutter/material.dart';

/// Card widget displaying a single party statistic
class PartyStatsCard extends StatelessWidget {
  final String label;
  final String value;
  final MaterialColor color;

  const PartyStatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.shade200),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
