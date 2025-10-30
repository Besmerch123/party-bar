import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/party/party_hub_header.dart';
import '../../widgets/party/party_action_card.dart';
import '../../widgets/party/party_quick_info.dart';

class PartyHubScreen extends StatelessWidget {
  const PartyHubScreen({super.key});

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

              // Join Party Card
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
                onTap: () {
                  context.push(AppRoutes.createParty);
                },
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
