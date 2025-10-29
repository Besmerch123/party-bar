import 'package:flutter/material.dart';
import 'package:party_bar/models/models.dart';
import 'package:party_bar/utils/localization_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:party_bar/utils/app_router.dart';

/// Widget to control party status (Start/Pause/End)
class PartyStatusControl extends StatelessWidget {
  final Party party;
  final String currentUserId;
  final Function(PartyStatus newStatus) onStatusChange;
  final bool isUpdating;

  const PartyStatusControl({
    super.key,
    required this.party,
    required this.currentUserId,
    required this.onStatusChange,
    this.isUpdating = false,
  });

  static MaterialColor getStatusColor(PartyStatus status) {
    switch (status) {
      case PartyStatus.active:
        return Colors.green;
      case PartyStatus.paused:
        return Colors.orange;
      case PartyStatus.ended:
        return Colors.red;
      case PartyStatus.idle:
        return Colors.blue;
    }
  }

  static String getStatusLabel(BuildContext context, PartyStatus status) {
    switch (status) {
      case PartyStatus.active:
        return context.l10n.partyActive;
      case PartyStatus.paused:
        return context.l10n.partyPaused;
      case PartyStatus.ended:
        return context.l10n.partyEnded;
      case PartyStatus.idle:
        return context.l10n.partyIdle;
    }
  }

  static IconData getStatusIcon(PartyStatus status) {
    switch (status) {
      case PartyStatus.active:
        return Icons.play_circle_filled;
      case PartyStatus.paused:
        return Icons.pause_circle_filled;
      case PartyStatus.ended:
        return Icons.stop_circle;
      case PartyStatus.idle:
        return Icons.hourglass_empty;
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

  void _navigateToActiveParty(BuildContext context) {
    final bool isHost = currentUserId == party.hostId;

    if (isHost) {
      // Navigate to host dashboard
      context.push('${AppRoutes.activePartyHost}/${party.id}', extra: party);
    } else {
      // Navigate to guest screen
      // For guests, we need the party code and guest name
      // You might want to pass guest name from somewhere or prompt for it
      context.push(
        AppRoutes.activePartyGuest,
        extra: {
          'partyCode': party.joinCode,
          'guestName': 'Guest', // TODO: Get actual guest name from user profile
        },
      );
    }
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
                Icon(Icons.power_settings_new),
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
                color: PartyStatusControl.getStatusColor(
                  party.status,
                ).withValues(alpha: .1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: PartyStatusControl.getStatusColor(party.status),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PartyStatusControl.getStatusIcon(party.status),
                    color: PartyStatusControl.getStatusColor(party.status),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    PartyStatusControl.getStatusLabel(context, party.status),
                    style: TextStyle(
                      color: PartyStatusControl.getStatusColor(party.status),
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
                  if (party.status == PartyStatus.paused)
                    ElevatedButton.icon(
                      onPressed: () => onStatusChange(PartyStatus.active),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(context.l10n.resumeParty),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (party.status == PartyStatus.active)
                    OutlinedButton.icon(
                      onPressed: () => onStatusChange(PartyStatus.paused),
                      icon: const Icon(Icons.pause),
                      label: Text(context.l10n.pauseParty),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                    ),
                  if (party.status != PartyStatus.ended)
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
            // Navigation Button
            if (party.status == PartyStatus.active) ...[
              const Divider(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToActiveParty(context),
                  icon: Icon(
                    currentUserId == party.hostId
                        ? Icons.dashboard
                        : Icons.local_bar,
                  ),
                  label: Text(
                    currentUserId == party.hostId
                        ? context.l10n.goToHostDashboard
                        : context.l10n.goToPartyMenu,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
