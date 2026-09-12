import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/shared_types.dart';
import '../../providers/locale_provider.dart';
import '../../theme/theme.dart';
import '../../utils/language_labels.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/settings/settings_rows.dart';

/// Flow 09 · screen 04 — EN / UK, plus the device default as a real option.
///
/// [LocaleProvider.setLocale] is a manual pick and always wins; the "Follow
/// my phone" switch is the only thing that hands the choice back to the
/// device, and it only ever fires when someone actually flips it.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.watch<LocaleProvider>();
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;

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
            Text(l10n.language, style: AppTypography.title.copyWith(fontSize: 30, height: 1)),
            const SizedBox(height: 14),
            Text(
              l10n.settingsLanguageBody,
              style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.ink.withValues(alpha: .6)),
            ),
            const SizedBox(height: 22),
            for (final value in SupportedLocale.values) ...[
              _LanguageOption(
                flag: value == SupportedLocale.en ? '🇬🇧' : '🇺🇦',
                name: languageDisplayName(value),
                selected: !locale.followsSystem && locale.currentLocale == value,
                onTap: () => locale.setLocale(value),
              ),
              const SizedBox(height: 10),
            ],
            SettingsToggleRow(
              title: l10n.settingsLanguageFollowsPhone,
              subtitle: l10n.settingsLanguageFollowsPhoneCaption(languageDisplayName(_localeOf(deviceLocale))),
              value: locale.followsSystem,
              onChanged: (value) => locale.setFollowSystem(value, deviceLocale: deviceLocale),
            ),
            const SizedBox(height: 18),
            SettingsInfoRow(icon: Icons.group_outlined, text: l10n.settingsLanguageNoteGuests),
            const SizedBox(height: 10),
            SettingsInfoRow(icon: Icons.edit_note_outlined, text: l10n.settingsLanguageNoteOwnRecipes),
          ],
        ),
      ),
    );
  }

  SupportedLocale _localeOf(Locale locale) =>
      locale.languageCode == 'uk' ? SupportedLocale.uk : SupportedLocale.en;
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.flag,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.signalWash : AppColors.sheet,
      borderRadius: AppRadius.cardAll,
      child: InkWell(
        borderRadius: AppRadius.cardAll,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.cardAll,
            border: selected ? Border.all(color: AppColors.signal.withValues(alpha: .55), width: 1.5) : null,
          ),
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 15),
              Expanded(
                child: Text(name, style: AppTypography.section.copyWith(fontSize: 15)),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 22,
                color: selected ? AppColors.signalLight : AppColors.ink.withValues(alpha: .22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
