import 'package:flutter/material.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/party/join_party_header.dart';
import '../../widgets/party/join_party_form.dart';
import '../../widgets/party/join_party_help.dart';

class JoinPartyScreen extends StatelessWidget {
  const JoinPartyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.joinPartyTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const JoinPartyHeader(),
              const SizedBox(height: 40),
              Expanded(
                child: Column(
                  children: [
                    JoinPartyForm(),
                    const Spacer(),
                    const JoinPartyHelp(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
