import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../home/widgets/listing_card.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);

    final strings = ref.watch(appLocalizationsProvider);

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.favorites)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(strings.loginToViewFavorites),
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

    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.favorites)),
      body: favoritesAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(12),
          child: ListingGridShimmer(),
        ),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(favoritesProvider),
        ),
        data: (listings) {
          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 72,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.noFavorites,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: Text(strings.browseListings),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(favoritesProvider),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: listings.length,
              itemBuilder: (_, i) {
                final listing = listings[i];
                return Dismissible(
                  key: ValueKey(listing.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    color: Theme.of(context).colorScheme.error,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => ref
                      .read(toggleFavoriteProvider.notifier)
                      .toggle(listing.id),
                  child: ListingCard(listing: listing),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
