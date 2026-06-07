import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/l10n_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/result.dart';
import '../providers/profile_provider.dart';
import '../widgets/language_sheet.dart';
import '../widgets/settings_tile.dart';
import '../../../shared/widgets/webview_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '…';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = info.version);
  }

  Future<void> _logout() async {
    final strings = ref.read(appLocalizationsProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(strings.logoutConfirmTitle),
        content: Text(strings.logoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.logout),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final result = await ref.read(profileNotifierProvider.notifier).signOut();
    if (!mounted) return;
    switch (result) {
      case Success():
        context.go(AppRoutes.phone);
      case Failure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  Future<void> _deleteAccount() async {
    final strings = ref.read(appLocalizationsProvider);
    final ok1 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(strings.deleteAccountTitle),
        content: Text(strings.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.continueAction),
          ),
        ],
      ),
    );
    if (ok1 != true || !mounted) return;

    final controller = TextEditingController();
    final confirmWord = strings.deleteConfirmWord;
    final ok2 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(strings.deleteConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(strings.deleteConfirmHint),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim() == confirmWord),
            child: Text(strings.deleteAccount),
          ),
        ],
      ),
    );
    controller.dispose();
    if (ok2 != true || !mounted) return;

    final result =
        await ref.read(profileNotifierProvider.notifier).deleteAccount();
    if (!mounted) return;

    switch (result) {
      case Success():
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (mounted) context.go(AppRoutes.phone);
      case Failure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر فتح الرابط')),
        );
      }
    }
  }

  void _openWebView(String title, String url) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => WebViewScreen(title: title, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appLocalizationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      body: ListView(
        children: [
          SettingsSectionHeader(title: strings.accountSection),
          SettingsTile(
            title: strings.editProfile,
            icon: Icons.person_outline,
            onTap: () => context.push(AppRoutes.editProfile),
          ),
          SettingsTile(
            title: strings.notifications,
            icon: Icons.notifications_outlined,
            onTap: () => context.push(AppRoutes.notificationsSettings),
          ),
          SettingsTile(
            title: strings.changeLanguage,
            icon: Icons.language,
            onTap: () => showLanguageSheet(context, ref),
          ),
          SettingsSectionHeader(title: strings.supportSection),
          SettingsTile(
            title: strings.contactUs,
            icon: Icons.mail_outline,
            onTap: () => _launchUrl('mailto:${AppConstants.supportEmail}'),
          ),
          SettingsTile(
            title: strings.rateApp,
            icon: Icons.star_outline,
            onTap: () => _launchUrl(AppConstants.playStoreUrl),
          ),
          SettingsTile(
            title: strings.faq,
            icon: Icons.help_outline,
            onTap: () => _openWebView(strings.faq, AppConstants.faqUrl),
          ),
          SettingsTile(
            title: strings.privacyPolicy,
            icon: Icons.privacy_tip_outlined,
            onTap: () =>
                _openWebView(strings.privacyPolicy, AppConstants.privacyPolicyUrl),
          ),
          SettingsTile(
            title: strings.termsOfUse,
            icon: Icons.description_outlined,
            onTap: () => _openWebView(strings.termsOfUse, AppConstants.termsUrl),
          ),
          SettingsSectionHeader(title: strings.appSection),
          SettingsTile(
            title: strings.version,
            icon: Icons.info_outline,
            trailing: Text(_version),
            onTap: null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: Text(strings.darkMode),
            value: false,
            onChanged: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings.comingSoon)),
              );
            },
          ),
          SettingsSectionHeader(title: strings.actionsSection),
          SettingsTile(
            title: strings.logout,
            icon: Icons.logout,
            textColor: Theme.of(context).colorScheme.error,
            onTap: _logout,
          ),
          SettingsTile(
            title: strings.deleteAccount,
            icon: Icons.delete_forever_outlined,
            textColor: Theme.of(context).colorScheme.error,
            onTap: _deleteAccount,
          ),
        ],
      ),
    );
  }
}
