import 'package:flutter/material.dart';
import 'package:party_bar/utils/localization_helper.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../widgets/settings/lang_settings.dart';
import '../../widgets/settings/sign_in.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navigationSettings), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.language,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const LangSettings(),
            const SizedBox(height: 16),
            Text(
              l10n.authentication,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const SignInMenuItem(),
          ],
        ),
      ),
    );
  }
}
