import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../utils/localization_helper.dart';
import '../../models/models.dart';
import '../../services/party_service.dart';
import './party_status_control.dart';

class HostedPartiesBottomSheet extends StatelessWidget {
  const HostedPartiesBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HostedPartiesBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.myHostedParties,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Parties list
              Expanded(
                child: StreamBuilder<List<Party>>(
                  stream: PartyService().getHostedParties(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(color: Colors.red.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final parties = snapshot.data ?? [];

                    if (parties.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: parties.length,
                      itemBuilder: (context, index) {
                        final party = parties[index];
                        return _buildPartyCard(context, party);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noHostedParties,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.createFirstParty,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.push('/party/create');
              },
              icon: const Icon(Icons.add_circle_outline),
              label: Text(context.l10n.createParty),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartyCard(BuildContext context, Party party) {
    final statusColor = PartyStatusControl.getStatusColor(party.status);
    final statusIcon = PartyStatusControl.getStatusIcon(party.status);
    final dateFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          context.push('/party/details/${party.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Party name and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      party.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withValues(alpha: .3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          PartyStatusControl.getStatusLabel(
                            context,
                            party.status,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Description
              if (party.description != null &&
                  party.description!.isNotEmpty) ...[
                Text(
                  party.description!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],

              // Party info
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    Icons.calendar_today,
                    dateFormat.format(party.createdAt),
                    context,
                  ),
                  _buildInfoChip(
                    Icons.access_time,
                    timeFormat.format(party.createdAt),
                    context,
                  ),
                  _buildInfoChip(
                    Icons.confirmation_number,
                    party.joinCode,
                    context,
                  ),
                  if (party.totalOrders > 0)
                    _buildInfoChip(
                      Icons.receipt,
                      '${party.totalOrders} orders',
                      context,
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Action button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/party/details/${party.id}');
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text(context.l10n.viewDetails),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColorLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
