import 'package:flutter/material.dart';

/// Section header for grouping orders by status
class OrderSection extends StatelessWidget {
  final String title;
  final int count;
  final MaterialColor color;
  final List<Widget> children;

  const OrderSection({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, color: color, size: 12),
            const SizedBox(width: 8),
            Text(
              '$title ($count)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}
