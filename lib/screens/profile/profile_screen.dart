import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:party_bar/providers/locale_provider.dart';
import 'package:party_bar/models/shared_types.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Language',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const LanguageSwitcher(),
          ],
        ),
      ),
    );
  }
}

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

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
