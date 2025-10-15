import 'package:flutter/material.dart';
import '../../models/equipment.dart';

class EquipmentList extends StatelessWidget {
  final List<Equipment> equipment;

  const EquipmentList({super.key, required this.equipment});

  @override
  Widget build(BuildContext context) {
    if (equipment.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Equipment',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: equipment.length,
          itemBuilder: (context, index) {
            return _buildEquipmentItem(context, equipment[index]);
          },
        ),
      ],
    );
  }

  Widget _buildEquipmentItem(BuildContext context, Equipment equipment) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 80,
            child: Center(
              child: equipment.image?.isNotEmpty ?? false
                  ? Image.network(
                      equipment.image!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.local_bar,
                      size: 40,
                      color: Colors.white.withValues(alpha: .8),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              equipment.title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
