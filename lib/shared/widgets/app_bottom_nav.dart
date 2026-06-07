import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_provider.dart';
import '../../core/router/app_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/widgets/guest_bottom_sheet.dart';
import '../../features/chat/providers/chat_provider.dart';

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
      body: child,
      floatingActionButton: SizedBox(
        width: 52,
        height: 52,
        child: FloatingActionButton(
          onPressed: () async {
            final authed = await requireAuth(context, ref);
            if (authed && context.mounted) {
              context.push(AppRoutes.post);
            }
          },
          elevation: 4,
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: strings.home,
                selected: index == 0,
                onTap: () => context.go(AppRoutes.home),
              ),
              _NavItem(
                icon: Icons.search,
                selectedIcon: Icons.search,
                label: strings.search,
                selected: index == 1,
                onTap: () => context.go(AppRoutes.search),
              ),
              const SizedBox(width: 48),
              _NavItem(
                icon: Icons.chat_bubble_outline,
                selectedIcon: Icons.chat_bubble,
                label: strings.messages,
                selected: index == 3,
                badgeCount: unread,
                onTap: () {
                  if (isGuest) {
                    showGuestBottomSheet(context);
                    return;
                  }
                  context.go(AppRoutes.conversations);
                },
              ),
              _NavItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: strings.profile,
                selected: index == 4,
                onTap: () {
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
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(selected ? selectedIcon : icon, color: color, size: 24),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
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
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
