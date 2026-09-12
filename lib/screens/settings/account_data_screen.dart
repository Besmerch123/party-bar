import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/party_service.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/settings/delete_account_sheet.dart';
import '../../widgets/settings/settings_rows.dart';

/// Flow 09 · screen 07 — leaving, counted out loud.
///
/// Sign-out is refused while a hosted party is still live: there is nowhere
/// for its queue to go once the host who could see it signs out.
class AccountDataScreen extends StatefulWidget {
  const AccountDataScreen({super.key});

  @override
  State<AccountDataScreen> createState() => _AccountDataScreenState();
}

class _AccountDataScreenState extends State<AccountDataScreen> {
  final _partyService = PartyService();

  void _comingSoon() {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }

  Future<void> _signOut() async {
    final l10n = context.l10n;
    final auth = context.read<AuthenticationProvider>();

    final hosted = await _partyService.getHostedParties().first;
    final live = hosted.where((p) => p.isLive).firstOrNull;

    if (!mounted) return;

    if (live != null) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.sheet,
          title: Text(l10n.settingsSignOutBlockedTitle, style: AppTypography.cardTitle),
          content: Text(
            l10n.settingsSignOutBlockedBody,
            style: AppTypography.body.copyWith(fontSize: 12.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('${AppRoutes.activePartyHost}/${live.id}', extra: live);
              },
              child: Text(l10n.settingsSignOutBlockedAction),
            ),
          ],
        ),
      );
      return;
    }

    await auth.signOut();
    if (mounted) context.go(AppRoutes.settings);
  }

  Future<void> _delete() async {
    final deleted = await showDeleteAccountSheet(context);
    if (deleted == true && mounted) context.go(AppRoutes.explore);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthenticationProvider>();
    final user = auth.user;
    final since = user?.metadata.creationTime;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(
        backgroundColor: AppColors.ground,
        surfaceTintColor: Colors.transparent,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, 0, AppSpacing.screenEdge, 30),
          children: [
            Text(l10n.settingsAccountData, style: AppTypography.title.copyWith(fontSize: 30, height: 1)),
            const SizedBox(height: 20),
            SettingsRowGroup(
              children: [
                SettingsRow(
                  icon: Icons.mail_outline,
                  label: user?.email ?? '',
                  value: since == null
                      ? null
                      : l10n.settingsAccountSince(DateFormat.yMMMd(locale).format(since)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SettingsRowGroup(
              children: [
                SettingsRow(
                  icon: Icons.download_outlined,
                  label: l10n.settingsDownloadData,
                  onTap: _comingSoon,
                ),
                SettingsRow(
                  icon: Icons.gavel_outlined,
                  label: l10n.settingsTermsPrivacy,
                  onTap: _comingSoon,
                ),
                SettingsRow(
                  icon: Icons.forum_outlined,
                  label: l10n.settingsSendFeedback,
                  onTap: _comingSoon,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SettingsRowGroup(
              children: [
                SettingsRow(
                  icon: Icons.logout,
                  label: l10n.logout,
                  iconColor: AppColors.ink.withValues(alpha: .6),
                  onTap: _signOut,
                ),
                SettingsRow(
                  icon: Icons.delete_forever_outlined,
                  label: l10n.settingsDeleteAccount,
                  iconColor: AppColors.danger,
                  labelColor: AppColors.dangerLight,
                  onTap: _delete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
