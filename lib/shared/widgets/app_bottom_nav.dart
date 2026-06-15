import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/l10n_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_decorations.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/widgets/guest_bottom_sheet.dart';
import '../../features/chat/providers/chat_provider.dart';

/// Floating glass nav — souqly-redesign-studio FloatingGlassNavBar pattern.
class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key, required this.child});

  final Widget child;

  int _indexForLocation(String location) {
    if (location.startsWith(AppRoutes.search)) return 1;
    if (location.startsWith(AppRoutes.conversations)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexForLocation(location);
    final isGuest = ref.watch(isGuestProvider);
    final unreadAsync = ref.watch(unreadCountProvider);
    final unread = unreadAsync.value ?? 0;
    final strings = ref.watch(appLocalizationsProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: child,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDecorations.navRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.navFill,
                borderRadius: BorderRadius.circular(AppDecorations.navRadius),
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
                boxShadow: AppDecorations.navShadow,
              ),
              child: SizedBox(
                height: 72,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: strings.home,
                      selected: index == 0,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.go(AppRoutes.home);
                      },
                    ),
                    _NavItem(
                      icon: Icons.search_rounded,
                      label: strings.search,
                      selected: index == 1,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.go(AppRoutes.search);
                      },
                    ),
                    _CenterAddButton(
                      onTap: () async {
                        HapticFeedback.selectionClick();
                        final authed = await requireAuth(context, ref);
                        if (authed && context.mounted) {
                          context.push(AppRoutes.post);
                        }
                      },
                    ),
                    _NavItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: strings.messages,
                      selected: index == 3,
                      badgeCount: unread,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        if (isGuest) {
                          showGuestBottomSheet(context);
                          return;
                        }
                        context.go(AppRoutes.conversations);
                      },
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      label: strings.profile,
                      selected: index == 4,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        if (isGuest) {
                          showGuestBottomSheet(context);
                          return;
                        }
                        context.go(AppRoutes.profile);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    final size = selected ? 26.0 : 22.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: color, size: size),
              if (badgeCount > 0)
                Positioned(
                  top: -4,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterAddButton extends StatelessWidget {
  const _CenterAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            gradient: AppColors.premiumGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x60005F54),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
