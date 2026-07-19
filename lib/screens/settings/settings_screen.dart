import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/dicebear_avatars.dart';
import '../../core/l10n/l10n_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/utils/result.dart';
import '../../core/providers/session_reset.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../features/payment/payment_method_sheet.dart';
import '../../features/payment/zaincash_checkout_screen.dart';
import '../../features/payment/zaincash_service.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../../widgets/user_avatar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _pageBg = AppColors.background;
  // Dark-theme tokens (screen was originally authored for a light theme).
  static const _labelDark = AppColors.textDark;
  static const _labelMuted = AppColors.textMuted;
  static const _chevronColor = AppColors.textLight;

  bool _loading = true;
  String _name = '';
  String _email = '';
  String _avatarSeed = DiceBearAvatars.defaultSeed;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _appVersion = info.version);
  }

  Future<void> _loadUserData() async {
    final strings = ref.read(appLocalizationsProvider);
    try {
      if (!SupabaseConfig.isConfigured) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final user = supabase.auth.currentUser;
      if (user == null) {
        if (mounted) context.go(AppRoutes.phone);
        return;
      }

      setState(() => _loading = true);

      final profile = await supabase
          .from('profiles')
          .select('full_name, avatar_seed')
          .eq('id', user.id)
          .single();

      if (!mounted) return;
      setState(() {
        _name = (profile['full_name'] as String?)?.trim().isNotEmpty == true
            ? profile['full_name'] as String
            : (user.userMetadata?['full_name'] as String?) ??
                (user.userMetadata?['display_name'] as String?) ??
                strings.defaultUser;
        _email = user.email ?? user.phone ?? '';
        _avatarSeed = DiceBearAvatars.resolveSeed(
          profile['avatar_seed'] as String?,
        );
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _confirmLogout() async {
    final strings = ref.read(appLocalizationsProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          strings.logoutConfirmTitle,
          style: AppFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          strings.logoutConfirmBodyExtended,
          style: AppFonts.cairo(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(strings.cancel, style: AppFonts.cairo()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              strings.logoutAction,
              style: AppFonts.cairo(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final container = ref.container;
    await supabase.auth.signOut();
    invalidateSessionProviders(container);
    if (mounted) context.go(AppRoutes.phone);
  }

  Future<void> _confirmDeleteAccount() async {
    final strings = ref.read(appLocalizationsProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          strings.deleteAccountTitle,
          style: AppFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          strings.deleteAccountConfirmBody,
          style: AppFonts.cairo(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(strings.cancel, style: AppFonts.cairo()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              strings.delete,
              style: AppFonts.cairo(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await supabase.from('profiles').delete().eq('id', userId);
    } catch (_) {
      final result =
          await ref.read(profileNotifierProvider.notifier).deleteAccount();
      if (!mounted) return;
      switch (result) {
        case Success():
          break;
        case Failure(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          return;
      }
      if (mounted) context.go(AppRoutes.phone);
      return;
    }

    final container = ref.container;
    await supabase.auth.signOut();
    invalidateSessionProviders(container);
    if (mounted) context.go(AppRoutes.phone);
  }

  /// Shows the list of available payment methods. ZainCash is live; the others
  /// are placeholders shown as "قريباً" until those merchant accounts exist.
  Future<void> _startPaymentCheckout() async {
    final chose = await showPaymentMethodSheet(context);
    if (chose && mounted) _startZainCashCheckout();
  }

  Future<void> _startZainCashCheckout() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Fixed test amount; swap for a user-entered amount once wired into a real
    // purchase flow.
    const testAmount = 1000; // IQD

    final service = ZainCashService();
    messenger.showSnackBar(
      const SnackBar(content: Text('جارٍ تجهيز عملية الدفع...')),
    );

    final init = await service.startCheckout(amount: testAmount);

    switch (init) {
      case Success(:final value):
        final status = await navigator.push<ZainCashOrderStatus>(
          MaterialPageRoute(
            builder: (_) => ZainCashCheckoutScreen(
              checkout: value,
              service: service,
            ),
          ),
        );
        if (!mounted) return;
        if (status == null) {
          messenger.showSnackBar(
            const SnackBar(content: Text('تم إلغاء عملية الدفع')),
          );
        } else if (status.isPaid) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('تم الدفع بنجاح ✓  (${status.transactionId ?? ''})'),
            ),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(content: Text('لم يكتمل الدفع: ${status.status}')),
          );
        }
      case Failure(:final message):
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showAboutSheet() {
    final strings = ref.read(appLocalizationsProvider);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              strings.aboutApp,
              style: AppFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _labelDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              strings.aboutAppDescription,
              textAlign: TextAlign.center,
              style: AppFonts.cairo(
                fontSize: 14,
                color: _labelMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              strings.versionLabel(_appVersion),
              style: AppFonts.cairo(
                fontSize: 13,
                color: _chevronColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appLocalizationsProvider);
    final currentLanguage = localeDisplayName(
      normalizeAppLocale(ref.watch(localeProvider)).languageCode,
    );

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: AppBackButton(onPressed: () => context.pop()),
        title: Text(
          strings.settings,
          style: AppFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _labelDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _loading ? _ProfileCardShimmer() : _ProfileCard(
              name: _name,
              email: _email,
              avatarSeed: _avatarSeed,
              onTap: () => context.push(AppRoutes.editProfile),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 8),
              child: Text(
                strings.otherSettings,
                style: AppFonts.cairo(
                  fontSize: 13,
                  color: _labelMuted,
                ),
              ),
            ),
            _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: Icons.person_outline,
                  label: strings.accountDetails,
                  onTap: () => context.push(AppRoutes.editProfile),
                ),
                const _SettingsDivider(),
                _SettingsRow(
                  icon: Icons.lock_outline,
                  label: strings.passwordSettings,
                  onTap: () => context.push(AppRoutes.resetPassword),
                ),
                const _SettingsDivider(),
                _SettingsRow(
                  icon: Icons.notifications_none,
                  label: strings.notifications,
                  onTap: () => context.push(AppRoutes.notificationsSettings),
                ),
                const _SettingsDivider(),
                _SettingsRow(
                  icon: Icons.language,
                  label: strings.chooseLanguage,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentLanguage,
                        style: AppFonts.cairo(
                          fontSize: 13,
                          color: _labelMuted,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_left,
                        color: Color(0xFFBBBBBB),
                        size: 18,
                      ),
                    ],
                  ),
                  onTap: () => context.push('${AppRoutes.language}?onboarding=false'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: Icons.info_outline,
                  label: strings.aboutApp,
                  onTap: _showAboutSheet,
                ),
                const _SettingsDivider(),
                _SettingsRow(
                  icon: Icons.help_outline,
                  label: strings.helpFaq,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          strings.comingSoon,
                          style: AppFonts.cairo(fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                ),
                const _SettingsDivider(),
                _SettingsRow(
                  icon: Icons.support_agent_outlined,
                  label: strings.contactSupport,
                  onTap: () => context.push(AppRoutes.supportChat),
                ),
                const _SettingsDivider(),
                _SettingsRow(
                  icon: Icons.delete_outline,
                  label: strings.deleteAccount,
                  iconColor: Colors.red,
                  labelColor: Colors.red,
                  trailing: const Icon(
                    Icons.chevron_left,
                    color: Colors.red,
                    size: 18,
                  ),
                  onTap: _confirmDeleteAccount,
                ),
              ],
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 16),
              _SettingsGroup(
                children: [
                  _SettingsRow(
                    icon: Icons.account_balance_wallet_outlined,
                    label: strings.startPayment,
                    onTap: _startPaymentCheckout,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: Icons.logout,
                  label: strings.logout,
                  iconColor: Colors.red,
                  labelColor: Colors.red,
                  iconContainerOpacity: 0.12,
                  trailing: const Icon(
                    Icons.chevron_left,
                    color: Colors.red,
                    size: 18,
                  ),
                  onTap: _confirmLogout,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.email,
    required this.avatarSeed,
    required this.onTap,
  });

  final String name;
  final String email;
  final String avatarSeed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fieldCarbon,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _SettingsAvatar(avatarSeed: avatarSeed, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: AppFonts.cairo(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          ShimmerBox(width: 48, height: 48, borderRadius: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120, height: 16),
                SizedBox(height: 8),
                ShimmerBox(width: 160, height: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsAvatar extends StatelessWidget {
  const _SettingsAvatar({
    required this.avatarSeed,
    required this.size,
  });

  final String avatarSeed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return UserAvatar(avatarSeed: avatarSeed, size: size);
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.borderLight,
      indent: 16,
      endIndent: 16,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.iconColor = AppColors.primary,
    this.labelColor = AppColors.textDark,
    this.iconContainerOpacity = 0.15,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color labelColor;
  final double iconContainerOpacity;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: iconContainerOpacity),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppFonts.cairo(
                      fontSize: 14,
                      color: labelColor,
                    ),
                  ),
                ),
                trailing ??
                    const Icon(
                      Icons.chevron_left,
                      color: Color(0xFFBBBBBB),
                      size: 18,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
