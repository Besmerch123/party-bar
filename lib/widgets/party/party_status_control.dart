import 'package:flutter/material.dart';
import 'package:party_bar/models/models.dart';
import 'package:party_bar/utils/localization_helper.dart';

/// Widget to control party status (Start/Pause/End)
class PartyStatusControl extends StatelessWidget {
  final PartyStatus currentStatus;
  final Function(PartyStatus newStatus) onStatusChange;
  final bool isUpdating;

  const PartyStatusControl({
    super.key,
    required this.currentStatus,
    required this.onStatusChange,
    this.isUpdating = false,
  });

  Color _getStatusColor(BuildContext context) {
    switch (currentStatus) {
      case PartyStatus.active:
        return Colors.green;
      case PartyStatus.paused:
        return Colors.orange;
      case PartyStatus.ended:
        return Colors.red;
    }
  }

  String _getStatusLabel(BuildContext context) {
    switch (currentStatus) {
      case PartyStatus.active:
        return context.l10n.partyActive;
      case PartyStatus.paused:
        return context.l10n.partyPaused;
      case PartyStatus.ended:
        return context.l10n.partyEnded;
    }
  }

  IconData _getStatusIcon() {
    switch (currentStatus) {
      case PartyStatus.active:
        return Icons.play_circle_filled;
      case PartyStatus.paused:
        return Icons.pause_circle_filled;
      case PartyStatus.ended:
        return Icons.stop_circle;
    }
  }

  void _showEndPartyConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.endParty),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.confirmEndParty),
            const SizedBox(height: 8),
            Text(
              context.l10n.confirmEndPartyMessage,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onStatusChange(PartyStatus.ended);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l10n.endParty),
          ),
        ],
      ),
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
                Icon(
                  Icons.power_settings_new,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.partyStatus,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Current Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getStatusColor(context), width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(context),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusLabel(context),
                    style: TextStyle(
                      color: _getStatusColor(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            if (isUpdating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (currentStatus == PartyStatus.paused)
                    ElevatedButton.icon(
                      onPressed: () => onStatusChange(PartyStatus.active),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(context.l10n.resumeParty),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (currentStatus == PartyStatus.active)
                    OutlinedButton.icon(
                      onPressed: () => onStatusChange(PartyStatus.paused),
                      icon: const Icon(Icons.pause),
                      label: Text(context.l10n.pauseParty),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                    ),
                  if (currentStatus != PartyStatus.ended)
                    OutlinedButton.icon(
                      onPressed: () => _showEndPartyConfirmation(context),
                      icon: const Icon(Icons.stop),
                      label: Text(context.l10n.endParty),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
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
