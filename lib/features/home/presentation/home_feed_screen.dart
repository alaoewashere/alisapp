import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../models/home_listings_feed_type.dart';
import '../providers/home_feed_provider.dart';
import '../widgets/listing_card.dart';

class HomeFeedScreen extends ConsumerWidget {
  const HomeFeedScreen({
    super.key,
    required this.feedType,
  });

  final HomeListingsFeedType feedType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(homeFeedProvider(feedType));

    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(onPressed: () => context.pop()),
        title: Text(feedType.titleAr),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeFeedProvider(feedType).notifier).refresh(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
              ref.read(homeFeedProvider(feedType).notifier).loadMore();
            }
            return false;
          },
          child: _FeedBody(feed: feed, feedType: feedType),
        ),
      ),
    );
  }
}

class _FeedBody extends ConsumerWidget {
  const _FeedBody({
    required this.feed,
    required this.feedType,
  });

  final HomeFeedState feed;
  final HomeListingsFeedType feedType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (feed.isLoading && feed.items.isEmpty) {
      return const ListingGridShimmer();
    }

    if (feed.error != null && feed.items.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: AppErrorWidget(
              message: 'فشل تحميل الإعلانات',
              onRetry: () =>
                  ref.read(homeFeedProvider(feedType).notifier).refresh(),
            ),
          ),
        ],
      );
    }

    if (feed.items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          EmptyStateWidget(
            message: 'لا توجد إعلانات',
            icon: Icons.storefront_outlined,
          ),
        ],
      );
    }

    final itemCount = feed.items.length + (feed.isLoadingMore ? 1 : 0);

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= feed.items.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListingCard(listing: feed.items[index]);
      },
    );
  }
}
