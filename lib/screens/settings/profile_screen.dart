import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bar_provider.dart';
import '../../services/account_service.dart';
import '../../services/party_service.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/settings/settings_rows.dart';
import '../../widgets/settings/text_prompt.dart';
import 'settings_screen.dart' show kAppVersion, showAboutPartyBarDialog;

/// Flow 09 · screen 03 — one question: what do guests read?
///
/// Name and avatar, previewed nowhere fancier than the list they came from.
/// Not a bio, not a stats page — the footer is the one exception, and it
/// only ever reads numbers the recap screens already own.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _accountService = AccountService();
  final _partyService = PartyService();

  // A field, not a `build()`-time call: `setState` runs often on this screen
  // (every keystroke's debounce, every allergen edit) and a fresh
  // `.getHostedParties()` each time would tear down and re-attach the
  // footer's listener on every one of them.
  late final Stream<List<Party>> _hosted = _partyService.getHostedParties();

  late final TextEditingController _nameController;
  List<String> _allergens = const [];
  bool _saving = false;
  bool _justSaved = false;
  Timer? _saveDebounce;
  Timer? _savedFlash;

  String get _uid => context.read<AuthenticationProvider>().user!.uid;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: context.read<AuthenticationProvider>().displayName,
    );
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _accountService.getProfile(_uid);
    if (!mounted || profile == null) return;
    setState(() => _allergens = profile.allergens);
  }

  void _onNameChanged(String value) {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 700), () => _saveName(value));
  }

  Future<void> _saveName(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    setState(() => _saving = true);
    await context.read<AuthenticationProvider>().saveDisplayName(trimmed);
    await _accountService.updateProfile(_uid, name: trimmed);
    if (!mounted) return;
    setState(() => _saving = false);
    _flashSaved();
  }

  void _flashSaved() {
    _savedFlash?.cancel();
    setState(() => _justSaved = true);
    _savedFlash = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _justSaved = false);
    });
  }

  Future<void> _addAllergen() async {
    final l10n = context.l10n;
    final value = await promptForText(
      context,
      title: l10n.profileAddAllergen,
      hint: l10n.profileAllergenHint,
    );
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty || _allergens.contains(trimmed)) return;

    setState(() => _allergens = [..._allergens, trimmed]);
    await _accountService.updateProfile(_uid, allergens: _allergens);
    if (mounted) _flashSaved();
  }

  Future<void> _removeAllergen(String allergen) async {
    setState(() => _allergens = _allergens.where((a) => a != allergen).toList());
    await _accountService.updateProfile(_uid, allergens: _allergens);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _savedFlash?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthenticationProvider>();
    final bar = context.watch<BarProvider>();

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(
        backgroundColor: AppColors.ground,
        surfaceTintColor: Colors.transparent,
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: AnimatedOpacity(
                opacity: _justSaved || _saving ? 1 : 0,
                duration: AppMotion.tap,
                child: Text(
                  _saving ? l10n.profileSaving : l10n.profileSaved,
                  style: AppTypography.meta.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink.withValues(alpha: .35),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, 4, AppSpacing.screenEdge, 30),
          children: [
            Center(
              child: Column(
                children: [
                  _ProfileAvatar(
                    initial: _nameController.text,
                    photoUrl: auth.user?.photoURL,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.comingSoon)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      l10n.profileIntro,
                      textAlign: TextAlign.center,
                      style: AppTypography.meta.copyWith(
                        fontSize: 12,
                        color: AppColors.ink.withValues(alpha: .45),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Text(l10n.profileNameLabel.toUpperCase(), style: AppTypography.label),
            const SizedBox(height: 9),
            Container(
              decoration: BoxDecoration(color: AppColors.sheet, borderRadius: AppRadius.tileAll),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _nameController,
                onChanged: _onNameChanged,
                maxLength: 24,
                style: AppTypography.section.copyWith(fontSize: 17),
                decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(l10n.profileAllergensLabel.toUpperCase(), style: AppTypography.label),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final allergen in _allergens)
                  _AllergenChip(label: allergen, onRemove: () => _removeAllergen(allergen)),
                _AddAllergenChip(onTap: _addAllergen),
              ],
            ),
            const SizedBox(height: 10),
            SettingsInfoRow(icon: Icons.visibility_outlined, text: l10n.profileAllergensCaveat),
            const SizedBox(height: 20),
            SettingsRowGroup(
              children: [
                SettingsRow(
                  icon: Icons.local_bar_outlined,
                  label: l10n.navigationMyBar,
                  value: '${bar.bottleCount}',
                  onTap: () => context.go(AppRoutes.myBar),
                ),
                SettingsRow(
                  icon: Icons.info_outline,
                  label: l10n.settingsAbout,
                  value: kAppVersion,
                  onTap: () => showAboutPartyBarDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            StreamBuilder<List<Party>>(
              stream: _hosted,
              builder: (context, snapshot) {
                final nights = (snapshot.data ?? const []).where((p) => p.isEnded).toList();
                if (nights.isEmpty) return const SizedBox.shrink();

                final locale = Localizations.localeOf(context).toLanguageTag();
                final poured = nights.fold<int>(
                  0,
                  (sum, party) => sum + (party.drinksPoured ?? party.totalOrders),
                );
                final since = DateFormat.MMMM(locale).format(
                  nights.map((p) => p.createdAt).reduce((a, b) => a.isBefore(b) ? a : b),
                );

                return Text(
                  l10n.profileFooterStats(
                    since,
                    l10n.nightsParties(nights.length),
                    l10n.nightsDrinks(poured),
                  ),
                  textAlign: TextAlign.center,
                  style: AppTypography.meta.copyWith(
                    fontSize: 11.5,
                    color: AppColors.ink.withValues(alpha: .35),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.initial, required this.photoUrl, required this.onTap});

  final String initial;
  final String? photoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final letter = initial.trim().isEmpty ? '?' : initial.trim()[0].toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.signal, Color(0xFF1B2E6E)],
              ),
              shape: BoxShape.circle,
            ),
            child: photoUrl == null
                ? Text(letter, style: AppTypography.title.copyWith(fontSize: 34))
                : ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: photoUrl!,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          Text(letter, style: AppTypography.title.copyWith(fontSize: 34)),
                    ),
                  ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ground, width: 3),
              ),
              child: const Icon(Icons.photo_camera, size: 16, color: AppColors.ground),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllergenChip extends StatelessWidget {
  const _AllergenChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lowWash,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        onTap: onRemove,
        borderRadius: AppRadius.pillAll,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 9, 9, 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.cardTitle.copyWith(fontSize: 12, color: const Color(0xFFF5C97A)),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.close, size: 14, color: Color(0xFFF5C97A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddAllergenChip extends StatelessWidget {
  const _AddAllergenChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: AppColors.fillSubtle,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 15, color: AppColors.ink.withValues(alpha: .5)),
              const SizedBox(width: 5),
              Text(
                l10n.profileAddAllergen,
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 12,
                  color: AppColors.ink.withValues(alpha: .5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
