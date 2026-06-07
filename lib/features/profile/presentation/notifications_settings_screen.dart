import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/l10n/l10n_provider.dart';

const _pushKey = 'notifications_push_enabled';
const _emailKey = 'notifications_email_enabled';

final pushNotificationsEnabledProvider =
    NotifierProvider<PushNotificationsNotifier, bool>(
  PushNotificationsNotifier.new,
);

class PushNotificationsNotifier extends Notifier<bool> {
  @override
  bool build() {
    Future.microtask(_load);
    return true;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_pushKey) ?? true;
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushKey, value);
  }
}

final emailNotificationsEnabledProvider =
    NotifierProvider<EmailNotificationsNotifier, bool>(
  EmailNotificationsNotifier.new,
);

class EmailNotificationsNotifier extends Notifier<bool> {
  @override
  bool build() {
    Future.microtask(_load);
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_emailKey) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_emailKey, value);
  }
}

class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    final push = ref.watch(pushNotificationsEnabledProvider);
    final email = ref.watch(emailNotificationsEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.notifications)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(strings.pushNotifications),
            subtitle: Text(strings.pushNotificationsSubtitle),
            value: push,
            onChanged: (v) =>
                ref.read(pushNotificationsEnabledProvider.notifier).setEnabled(v),
          ),
          SwitchListTile(
            title: Text(strings.emailNotifications),
            subtitle: Text(strings.comingSoon),
            value: email,
            onChanged: (v) =>
                ref.read(emailNotificationsEnabledProvider.notifier).setEnabled(v),
          ),
        ],
      ),
    );
  }
}
