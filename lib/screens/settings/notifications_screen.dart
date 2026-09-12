import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../services/account_service.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/settings/settings_rows.dart';
import '../../widgets/settings/settings_subpage.dart';

/// Flow 09 · screen 06 — three things worth a buzz, and nothing else.
///
/// There is no push infrastructure behind these switches yet — no FCM
/// tokens, no send path — so flipping one only ever changes what is written
/// to this account's document. The one notification the app already fires
/// (the pour flow's own "drink ready" moment) is unaffected either way,
/// since nothing reads this field yet. Still worth shipping the row: the
/// document is the seam a real send path will read from later, and someone
/// signed in today should be able to say what they'd want.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, AccountService? accountService})
    : _accountService = accountService;

  /// Test seam only: production always leaves this null and gets a real
  /// [AccountService]. Nothing in the app passes this.
  final AccountService? _accountService;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final AccountService _accountService = widget._accountService ?? AccountService();

  String get _uid => context.read<AuthenticationProvider>().user!.uid;

  // A field, not a `build()`-time expression: `StreamBuilder` resubscribes
  // whenever it is handed a stream that is not identical (`==`) to the one
  // it already holds, and a fresh `.snapshots()` call is never identical to
  // the last one — a rebuild would otherwise tear down the live listener at
  // the exact moment a write is waiting on it to hear back.
  late final Stream<User?> _profile = _accountService.watchProfile(_uid);

  Future<void> _set({bool? drinkReady, bool? newOrder, bool? recapMorning}) =>
      _accountService.updateProfile(
        _uid,
        notifyDrinkReady: drinkReady,
        notifyNewOrder: newOrder,
        notifyRecapMorning: recapMorning,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return StreamBuilder<User?>(
      stream: _profile,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final drinkReady = user?.notifyDrinkReady ?? true;
        final newOrder = user?.notifyNewOrder ?? true;
        final recapMorning = user?.notifyRecapMorning ?? false;

        return SettingsSubpageScaffold(
          title: l10n.settingsNotifications,
          body: l10n.settingsNotificationsBody,
          children: [
            SettingsRowGroup(
              children: [
                SettingsToggleRow(
                  title: l10n.settingsNotifyDrinkReady,
                  subtitle: l10n.settingsNotifyDrinkReadyCaption,
                  value: drinkReady,
                  onChanged: (value) => _set(drinkReady: value),
                ),
                SettingsToggleRow(
                  title: l10n.settingsNotifyNewOrder,
                  subtitle: l10n.settingsNotifyNewOrderCaption,
                  value: newOrder,
                  onChanged: (value) => _set(newOrder: value),
                ),
                SettingsToggleRow(
                  title: l10n.settingsNotifyRecap,
                  subtitle: l10n.settingsNotifyRecapCaption,
                  value: recapMorning,
                  onChanged: (value) => _set(recapMorning: value),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SettingsRowGroup(
              children: [
                SettingsInfoRowGroupItem(
                  icon: Icons.block,
                  text: l10n.settingsNotifyNoteNever,
                ),
                SettingsInfoRowGroupItem(
                  icon: Icons.bedtime_outlined,
                  text: l10n.settingsNotifyNoteNoQuietHours,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.settingsNotifyFootnote,
              textAlign: TextAlign.center,
              style: AppTypography.meta.copyWith(
                fontSize: 11.5,
                color: AppColors.inkFaint,
              ),
            ),
          ],
        );
      },
    );
  }
}
