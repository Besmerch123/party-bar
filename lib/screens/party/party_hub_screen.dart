import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/auth.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_barrier_sheet.dart';
import '../../widgets/party/party_hub_header.dart';
import '../../widgets/party/party_action_card.dart';
import '../../widgets/party/party_quick_info.dart';

class PartyHubScreen extends StatelessWidget {
  const PartyHubScreen({super.key});

  /// Hosting is one of the three things that needs an owner, so this is a
  /// place the barrier can appear. It appears as a sheet over the hub rather
  /// than by walking someone into a screen that tells them no — the route
  /// guard behind it is the backstop for a cold deep link, not the way anyone
  /// should meet this.
  Future<void> _createParty(BuildContext context) async {
    final auth = context.read<AuthenticationProvider>();

    if (auth.isAuthenticated) {
      context.push(AppRoutes.createParty);
      return;
    }

    final signedIn = await showAuthBarrierSheet(
      context,
      reason: AuthReason.hostParty,
      redirectPath: AppRoutes.createParty,
    );

    // False covers both "not now" and the email lane, which is mid-flight and
    // will land on the redirect itself.
    if (signedIn && context.mounted) context.push(AppRoutes.createParty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.partyHub), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const PartyHubHeader(),
              const SizedBox(height: 40),

              // Join Party Card — unguarded. A guest orders on a name alone.
              PartyActionCard(
                title: context.l10n.joinParty,
                subtitle: context.l10n.joinPartySubtitle,
                icon: Icons.people,
                color: Colors.blue,
                onTap: () {
                  context.push(AppRoutes.joinParty);
                },
              ),

              const SizedBox(height: 20),

              // Create Party Card
              PartyActionCard(
                title: context.l10n.createParty,
                subtitle: context.l10n.createPartySubtitle,
                icon: Icons.add_circle,
                color: Colors.deepPurple,
                onTap: () => _createParty(context),
              ),

              const SizedBox(height: 40),

              const PartyQuickInfo(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
