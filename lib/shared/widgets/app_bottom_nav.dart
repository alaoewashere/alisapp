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
import '../../core/utils/navigation_guard.dart';

/// Layout metrics for the floating shell bottom nav (positioning only).
abstract final class AppBottomNavLayout {
  static const barHeight = 72.0;
  static const sideMargin = 20.0;
  /// Small gap above the home indicator, on top of [MediaQuery.padding.bottom].
  static const safeBottomGap = 8.0;
  /// Center "+" button [Transform.translate] — visual only; within [barHeight].
  static const fabOverhang = 10.0;

  static double _bottomInset(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom;

  /// Padding around the floating nav pill (horizontal + above home indicator).
  static EdgeInsets barOuterPadding(BuildContext context) {
    final inset = _bottomInset(context);
    return EdgeInsets.fromLTRB(
      sideMargin,
      0,
      sideMargin,
      inset + safeBottomGap,
    );
  }

  /// Scroll-end clearance only — tight fit above the nav bar (not a static gap).
  static double scrollBottomPadding(BuildContext context) {
    final inset = _bottomInset(context);
    return barHeight + inset + safeBottomGap;
  }
}

/// Invisible until the user scrolls to the end — clears the floating nav bar.
class AppBottomNavScrollSpacer extends StatelessWidget {
  const AppBottomNavScrollSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: AppBottomNavLayout.scrollBottomPadding(context));
  }
}

/// Sliver variant for [CustomScrollView] tab screens.
class AppBottomNavSliverSpacer extends StatelessWidget {
  const AppBottomNavSliverSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: AppBottomNavScrollSpacer());
  }
}

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

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: child,
      bottomNavigationBar: Padding(
        padding: AppBottomNavLayout.barOuterPadding(context),
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
                height: AppBottomNavLayout.barHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      key: const Key('bottom_nav_home'),
                      icon: Icons.home_rounded,
                      label: strings.home,
                      selected: index == 0,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.goGuarded(AppRoutes.home);
                      },
                    ),
                    _NavItem(
                      key: const Key('bottom_nav_search'),
                      icon: Icons.search_rounded,
                      label: strings.search,
                      selected: index == 1,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.goGuarded(AppRoutes.search);
                      },
                    ),
                    _CenterAddButton(
                      onTap: () async {
                        HapticFeedback.selectionClick();
                        final authed = await requireAuth(context, ref);
                        if (authed && context.mounted) {
                          context.pushGuarded(AppRoutes.post);
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
                        context.goGuarded(AppRoutes.conversations);
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
                        context.goGuarded(AppRoutes.profile);
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
    super.key,
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
    final iconColor = selected ? AppColors.canvas : AppColors.textMuted;

    return GestureDetector(
      key: key,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 16 : 11,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.volt : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x4DD4FF3A),
                    blurRadius: 14,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: iconColor, size: 22),
                if (badgeCount > 0)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.heartAccent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? AppColors.volt : AppColors.navFill,
                          width: 1.5,
                        ),
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
            // Label only appears for the active tab — animates in/out.
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.canvas,
                          height: 1,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
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
                color: Color(0x66D4FF3A),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: AppColors.canvas, size: 30),
        ),
      ),
    );
  }
}
