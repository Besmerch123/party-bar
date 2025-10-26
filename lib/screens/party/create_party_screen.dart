import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../widgets/party/create_party_form.dart';
import 'active_party_host_screen.dart';

class CreatePartyScreen extends StatelessWidget {
  const CreatePartyScreen({super.key});

  void _onPartyCreated(BuildContext context, Party party) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ActivePartyHostScreen(party: party),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createPartyTitle)),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              margin: const EdgeInsets.all(20),
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
                  Icon(
                    Icons.add_circle,
                    size: 60,
                    color: Colors.deepPurple.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.createYourParty,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.createPartyDescription,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: CreatePartyForm(
                onPartyCreated: (party) => _onPartyCreated(context, party),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
