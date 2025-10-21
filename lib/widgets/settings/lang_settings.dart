import 'package:flutter/material.dart';
import 'package:party_bar/models/shared_types.dart';
import 'package:party_bar/providers/locale_provider.dart';
import 'package:provider/provider.dart';

class LangSettings extends StatelessWidget {
  const LangSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentLocale = localeProvider.currentLocale;

    return Card(
      child: Column(
        children: [
          _LanguageOption(
            flag: '🇬🇧',
            languageName: 'English',
            isSelected: currentLocale == SupportedLocale.en,
            onTap: () => localeProvider.setLocale(SupportedLocale.en),
          ),
          const Divider(height: 1),
          _LanguageOption(
            flag: '🇺🇦',
            languageName: 'Українська',
            isSelected: currentLocale == SupportedLocale.uk,
            onTap: () => localeProvider.setLocale(SupportedLocale.uk),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String languageName;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.languageName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 32)),
      title: Text(
        languageName,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: onTap,
    );
  }
}
