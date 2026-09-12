import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/measure_unit_provider.dart';
import '../../services/account_service.dart';
import '../../services/party_service.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/language_labels.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/settings/measure_preview.dart';
import '../../widgets/settings/settings_rows.dart';
import '../../widgets/settings/text_prompt.dart';

/// Version shown on the About row. There is no `package_info_plus`
/// dependency in this project, so this is read straight from `pubspec.yaml`
/// rather than the platform — good enough for a row nobody taps to act on.
const kAppVersion = '1.0.0';

/// Flow 09 · screens 01 and 02 — six rows, one of which changes the product.
///
/// Signed in and signed out are the same screen minus two rows: measures and
/// language work with no account, "Your nights" and notifications have
/// nowhere to point without one.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, AccountService? accountService, PartyService? partyService})
    : _accountService = accountService,
      _partyService = partyService;

  /// Test seams only: production always leaves these null and gets real
  /// services. Nothing in the app passes them.
  final AccountService? _accountService;
  final PartyService? _partyService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final AccountService _accountService = widget._accountService ?? AccountService();
  late final PartyService _partyService = widget._partyService ?? PartyService();

  // Memoized rather than called straight from `build()`: a fresh
  // `.snapshots()`/`.getHostedParties()` call is never `==` to the last one,
  // so handing `StreamBuilder` a new one on every rebuild (every ml/oz
  // toggle, every auth change) tears down its live listener and re-attaches
  // — exactly when a just-sent write is waiting on that listener to hear
  // back. One stream per uid for the life of this screen instead.
  String? _streamsUid;
  Stream<User?>? _profileStream;
  Stream<List<Party>>? _hostedStream;

  Stream<User?> _profileFor(String uid) {
    _ensureStreams(uid);
    return _profileStream!;
  }

  Stream<List<Party>> _hostedFor(String uid) {
    _ensureStreams(uid);
    return _hostedStream!;
  }

  void _ensureStreams(String uid) {
    if (_streamsUid == uid) return;
    _streamsUid = uid;
    _profileStream = _accountService.watchProfile(uid);
    _hostedStream = _partyService.getHostedParties();
  }

  Future<void> _changeGuestName(BuildContext context, String? current) async {
    final l10n = context.l10n;
    final auth = context.read<AuthenticationProvider>();

    final name = await promptForText(
      context,
      title: l10n.settingsGuestNameTitle,
      initialValue: current ?? '',
      hint: l10n.settingsGuestNameHint,
    );

    if (name == null || name.trim().isEmpty || !context.mounted) return;
    await auth.setGuestName(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthenticationProvider>();
    final unit = context.watch<MeasureUnitProvider>().unit;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenEdge,
            14,
            AppSpacing.screenEdge,
            AppBottomNav.insetOf(context) + 12,
          ),
          children: [
            Text(
              l10n.navigationSettings,
              style: AppTypography.titleCompact,
            ),
            const SizedBox(height: 18),
            if (auth.isAuthenticated)
              ..._signedIn(context, l10n, auth, unit)
            else
              ..._signedOut(context, l10n, auth, unit),
            const SizedBox(height: 22),
            Text(
              l10n.settingsDisclaimer,
              textAlign: TextAlign.center,
              style: AppTypography.meta.copyWith(
                fontSize: 11.5,
                color: AppColors.inkGhost,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _signedIn(
    BuildContext context,
    AppLocalizations l10n,
    AuthenticationProvider auth,
    MeasureUnit unit,
  ) {
    final uid = auth.user!.uid;
    final photoUrl = auth.user?.photoURL;
    final name = auth.displayName.isEmpty ? l10n.settingsUnnamed : auth.displayName;

    return [
      Material(
        color: AppColors.sheet,
        borderRadius: AppRadius.cardAll,
        child: InkWell(
          borderRadius: AppRadius.cardAll,
          onTap: () => context.push(AppRoutes.profile),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _Avatar(name: name, photoUrl: photoUrl, size: 54),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.section,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        auth.user?.email ?? '',
                        style: AppTypography.meta.copyWith(
                          fontSize: 11.5,
                          color: AppColors.inkMeta,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.inkGhost,
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      _MeasuresCard(unit: unit),
      const SizedBox(height: 16),
      SettingsRowGroup(
        children: [
          SettingsRow(
            icon: Icons.translate,
            label: l10n.language,
            value: languageRowValue(context, l10n),
            onTap: () => context.push(AppRoutes.settingsLanguage),
          ),
          StreamBuilder<User?>(
            stream: _profileFor(uid),
            builder: (context, snapshot) {
              final on = snapshot.data?.notificationsOnCount ?? 2;
              return SettingsRow(
                icon: Icons.notifications_outlined,
                label: l10n.settingsNotifications,
                value: l10n.settingsNotificationsValue(on),
                onTap: () => context.push(AppRoutes.settingsNotifications),
              );
            },
          ),
          StreamBuilder<List<Party>>(
            stream: _hostedFor(uid),
            builder: (context, snapshot) {
              final count = (snapshot.data ?? const []).where((p) => p.isEnded).length;
              return SettingsRow(
                icon: Icons.history,
                label: l10n.hostYourNights,
                value: l10n.nightsParties(count),
                onTap: () => context.push(AppRoutes.partyNights),
              );
            },
          ),
        ],
      ),
      const SizedBox(height: 16),
      SettingsRowGroup(
        children: [
          SettingsRow(
            icon: Icons.shield_outlined,
            label: l10n.settingsAccountData,
            onTap: () => context.push(AppRoutes.settingsAccount),
          ),
          SettingsRow(
            icon: Icons.info_outline,
            label: l10n.settingsAbout,
            value: kAppVersion,
            onTap: () => showAboutPartyBarDialog(context),
          ),
        ],
      ),
    ];
  }

  List<Widget> _signedOut(
    BuildContext context,
    AppLocalizations l10n,
    AuthenticationProvider auth,
    MeasureUnit unit,
  ) {
    final guestName = auth.guestName;

    return [
      _SignInHero(onSignIn: () => context.push(AppRoutes.auth)),
      const SizedBox(height: 16),
      if (guestName != null) ...[
        Material(
          color: AppColors.sheet,
          borderRadius: AppRadius.cardAll,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _Avatar(name: guestName, photoUrl: null, size: 48),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(guestName, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        l10n.settingsGuestNameCaption,
                        style: AppTypography.meta.copyWith(
                          fontSize: 11.5,
                          color: AppColors.inkMeta,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _changeGuestName(context, guestName),
                  child: Text(l10n.settingsChange),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
      _MeasuresCard(unit: unit),
      const SizedBox(height: 16),
      SettingsRowGroup(
        children: [
          SettingsRow(
            icon: Icons.translate,
            label: l10n.language,
            value: languageRowValue(context, l10n),
            onTap: () => context.push(AppRoutes.settingsLanguage),
          ),
          SettingsRow(
            icon: Icons.info_outline,
            label: l10n.settingsAbout,
            value: kAppVersion,
            onTap: () => showAboutPartyBarDialog(context),
          ),
        ],
      ),
      const SizedBox(height: 16),
      SettingsInfoRow(icon: Icons.phonelink_lock_outlined, text: l10n.settingsSignedOutNote),
    ];
  }
}

class _MeasuresCard extends StatelessWidget {
  const _MeasuresCard({required this.unit});

  final MeasureUnit unit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(color: AppColors.sheet, borderRadius: AppRadius.cardAll),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.settingsMeasures, style: AppTypography.cardTitle),
              ),
              MeasureUnitSegment(
                unit: unit,
                compact: true,
                onChanged: (value) => context.read<MeasureUnitProvider>().setUnit(value),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Material(
            color: AppColors.row,
            borderRadius: AppRadius.tileAll,
            child: InkWell(
              borderRadius: AppRadius.tileAll,
              onTap: () => context.push(AppRoutes.settingsMeasures),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.fillMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_bar, size: 17, color: AppColors.signalLight),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        measurePreviewSummary(l10n, unit),
                        style: AppTypography.meta.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink.withValues(alpha: .85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 17, color: AppColors.inkGhost),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInHero extends StatelessWidget {
  const _SignInHero({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(color: AppColors.sheet, borderRadius: AppRadius.cardAll),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsNoAccountEyebrow.toUpperCase(),
            style: AppTypography.label.copyWith(color: AppColors.ink.withValues(alpha: .55)),
          ),
          const SizedBox(height: 12),
          Text(l10n.settingsNoAccountTitle, style: AppTypography.heading.copyWith(fontSize: 22)),
          const SizedBox(height: 12),
          Text(
            l10n.settingsNoAccountBody,
            style: AppTypography.body.copyWith(fontSize: 12.5, color: AppColors.inkBody),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.ground,
                shape: const StadiumBorder(),
              ),
              child: Text(
                l10n.settingsSignIn,
                style: AppTypography.buttonPrimary.copyWith(color: AppColors.ground),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.photoUrl, required this.size});

  final String name;
  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.signal, Color(0xFF1B2E6E)],
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: photoUrl == null
          ? Text(
              initial,
              style: AppTypography.heading.copyWith(fontSize: size * .35, height: 1),
            )
          : CachedNetworkImage(
              imageUrl: photoUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Text(
                initial,
                style: AppTypography.heading.copyWith(fontSize: size * .35, height: 1),
              ),
            ),
    );
  }
}

/// A row nobody needs to act on, so a dialog beats a whole screen for it.
void showAboutPartyBarDialog(BuildContext context) {
  final l10n = context.l10n;
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.sheet,
      title: Text('PartyBar', style: AppTypography.cardTitle.copyWith(fontSize: 16)),
      content: Text(
        l10n.settingsAboutBody(kAppVersion),
        style: AppTypography.body.copyWith(fontSize: 12.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.done),
        ),
      ],
    ),
  );
}
