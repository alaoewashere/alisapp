import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../providers/profile_provider.dart';
import '../widgets/my_listing_tile.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static List<String> _tabLabels(AppLocalizations strings) => [
        strings.myListingsActive,
        strings.myListingsPending,
        strings.myListingsSold,
        strings.myListingsDeleted,
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    ref
        .read(myListingsLoadedTabsProvider.notifier)
        .markLoaded(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);

    final strings = ref.watch(appLocalizationsProvider);
    final tabLabels = _tabLabels(strings);

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.myListings)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(strings.loginRequiredShort),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.push(AppRoutes.login),
                child: Text(strings.login),
              ),
            ],
          ),
        ),
      );
    }

    final countsAsync = ref.watch(myListingsCountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.myListings),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: List.generate(4, (i) {
            final count = countsAsync.maybeWhen(
              data: (c) => c[myListingStatusForTab(i)] ?? 0,
              orElse: () => 0,
            );
            return Tab(
              text: count > 0
                  ? '${tabLabels[i]} (${arabicNumber(count)})'
                  : tabLabels[i],
            );
          }),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(
          4,
          (i) => _MyListingsTabView(index: i, strings: strings),
        ),
      ),
    );
  }
}

class _MyListingsTabView extends ConsumerWidget {
  const _MyListingsTabView({required this.index, required this.strings});

  final int index;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref.watch(myListingsLoadedTabsProvider);
    if (!loaded.contains(index)) {
      return const Center(child: CircularProgressIndicator());
    }

    final status = myListingStatusForTab(index);
    final listingsAsync = ref.watch(myListingsProvider(status));

    return listingsAsync.when(
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, _) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: ShimmerBox(width: double.infinity, height: 96),
        ),
      ),
      error: (e, _) => AppErrorWidget(
        message: '$e',
        onRetry: () => ref.invalidate(myListingsProvider(status)),
      ),
      data: (listings) {
        if (listings.isEmpty) {
          return _EmptyTabState(status: status, strings: strings);
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myListingsProvider(status));
            ref.invalidate(myListingsCountsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (_, i) => MyListingTile(
              listing: listings[i],
              statusKey: status,
            ),
          ),
        );
      },
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  const _EmptyTabState({required this.status, required this.strings});

  final String status;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final message = switch (status) {
      'active' => strings.noActiveListingsTab,
      'pending' => strings.noPendingListingsTab,
      'sold' => strings.noSoldListingsTab,
      'deleted' => strings.noDeletedListingsTab,
      _ => strings.noMyListings,
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.titleMedium),
          if (status == 'active') ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push(AppRoutes.post),
              child: Text(strings.addListingButton),
            ),
          ],
        ],
      ),
    );
  }
}

