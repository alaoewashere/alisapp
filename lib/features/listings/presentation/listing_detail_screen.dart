import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_governorates.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/guest_bottom_sheet.dart';
import '../../../core/utils/share_listing.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../favorites/data/favorites_repository.dart';
import '../../home/widgets/listing_card.dart';
import '../providers/listing_detail_provider.dart';
import '../providers/listings_provider.dart';
import '../widgets/listing_detail_bottom_bar.dart';
import '../widgets/listing_detail_gallery.dart';
import '../widgets/listing_map_preview.dart';
import '../widgets/report_sheet.dart';

class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingDetailProvider(listingId));
    final favoriteLoadingId = ref.watch(listingFavoriteLoadingProvider);
    final isOwner = ref.watch(isOwnerProvider(listingId));

    return listingAsync.when(
      loading: () => const Scaffold(
        body: LoadingWidget(message: 'جاري التحميل...'),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: '$e',
          onRetry: () => ref.invalidate(listingDetailProvider(listingId)),
        ),
      ),
      data: (listing) {
        if (listing == null) {
          return Scaffold(
            appBar: AppBar(),
            body: AppErrorWidget(
              message: 'الإعلان غير موجود',
              onRetry: () => ref.invalidate(listingDetailProvider(listingId)),
            ),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                automaticallyImplyLeading: false,
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    final settings = context
                        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
                    final collapsed = settings == null ||
                        settings.currentExtent <= settings.minExtent + 10;
                    return collapsed
                        ? Text(
                            listing.titleAr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : const SizedBox.shrink();
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: ListingDetailGallery(
                    listing: listing,
                    favoriteLoading: favoriteLoadingId == listingId,
                    onBack: () => context.canPop()
                        ? context.pop()
                        : context.go(AppRoutes.home),
                    onShare: () => shareListingUrl(listing),
                    onFavorite: () => _toggleFavorite(context, ref, listing),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _ListingDetailBody(listing: listing, isOwner: isOwner),
              ),
            ],
          ),
          bottomNavigationBar: ListingDetailBottomBar(
            listing: listing,
            isOwner: isOwner,
          ),
        );
      },
    );
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    ListingModel listing,
  ) async {
    if (ref.read(isGuestProvider)) {
      await showGuestBottomSheet(context);
      return;
    }
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      await requireAuth(context, ref);
      return;
    }
    ref.read(listingFavoriteLoadingProvider.notifier).setListingId(listingId);
    try {
      await ref.read(favoritesRepositoryProvider).toggle(userId, listingId);
      ref.invalidate(listingDetailProvider(listingId));
      ref.invalidate(favoritesProvider);
    } finally {
      ref.read(listingFavoriteLoadingProvider.notifier).setListingId(null);
    }
  }
}

class _ListingDetailBody extends ConsumerWidget {
  const _ListingDetailBody({
    required this.listing,
    required this.isOwner,
  });

  final ListingModel listing;
  final bool isOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sellerKey = (
      sellerId: listing.userId,
      excludeListingId: listing.id,
    );
    final otherListingsAsync = ref.watch(sellerOtherListingsProvider(sellerKey));
    final sellerCountAsync = ref.watch(sellerListingsCountProvider(listing.userId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            listing.titleAr,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                listing.formattedPrice,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (listing.isNegotiable) ...[
                const SizedBox(width: 8),
                Chip(
                  label: const Text('قابل للتفاوض'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (listing.conditionLabelAr != null)
                _BadgeChip(
                  label: listing.conditionLabelAr!,
                  color: listing.condition == ListingCondition.newItem
                      ? Colors.green
                      : Colors.orange,
                ),
              if (listing.categoryBreadcrumb.isNotEmpty)
                _BadgeChip(label: listing.categoryBreadcrumb),
              if (listing.isBoosted || listing.isFeatured)
                const _BadgeChip(label: 'مميز', color: Colors.amber),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatItem(icon: Icons.visibility_outlined, label: '${listing.viewsCount} مشاهدة'),
              const SizedBox(width: 16),
              _StatItem(icon: Icons.schedule, label: listing.timeAgo),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 4),
              Text(
                '${governorateNameAr(listing.governorate)} · ${listing.city}',
              ),
            ],
          ),
          const Divider(height: 32),
          Text('الوصف', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _ExpandableDescription(
            listingId: listing.id,
            text: listing.descriptionAr,
          ),
          const Divider(height: 32),
          Text('الموقع', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('${governorateNameAr(listing.governorate)} — ${listing.city}'),
          if (listing.latitude != null && listing.longitude != null) ...[
            const SizedBox(height: 12),
            ListingMapPreview(
              latitude: listing.latitude!,
              longitude: listing.longitude!,
            ),
          ],
          const Divider(height: 32),
          _SellerCard(
            listing: listing,
            listingsCount: sellerCountAsync.value ?? 0,
          ),
          const SizedBox(height: 16),
          otherListingsAsync.when(
            data: (items) {
              if (items.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'إعلانات أخرى للبائع',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(
                          '/seller/${listing.userId}',
                        ),
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => SizedBox(
                        width: 160,
                        child: ListingCard(listing: items[i]),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          const _SafetyTipsSection(),
          const SizedBox(height: 8),
          if (!isOwner)
            TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => ReportSheet(listingId: listing.id),
              ),
              child: Text(
                'الإبلاغ عن هذا الإعلان',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).colorScheme.secondaryContainer)
            .withValues(alpha: color != null ? 0.15 : 1),
        borderRadius: BorderRadius.circular(16),
        border: color != null ? Border.all(color: color!) : null,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ExpandableDescription extends ConsumerWidget {
  const _ExpandableDescription({
    required this.listingId,
    required this.text,
  });

  final String listingId;
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = ref.watch(descriptionExpandedProvider(listingId));
    final long = text.length > 200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          text.isEmpty ? 'لا يوجد وصف' : text,
          maxLines: expanded ? null : 5,
          overflow: expanded ? null : TextOverflow.ellipsis,
        ),
        if (long)
          TextButton(
            onPressed: () => ref
                .read(descriptionExpandedProvider(listingId).notifier)
                .toggle(),
            child: Text(expanded ? 'عرض أقل' : 'عرض المزيد'),
          ),
      ],
    );
  }
}

class _SellerCard extends StatelessWidget {
  const _SellerCard({
    required this.listing,
    required this.listingsCount,
  });

  final ListingModel listing;
  final int listingsCount;

  @override
  Widget build(BuildContext context) {
    final joinYear = listing.sellerCreatedAt != null
        ? DateFormat('yyyy', 'ar').format(listing.sellerCreatedAt!)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: listing.sellerAvatar != null
                      ? CachedNetworkImageProvider(listing.sellerAvatar!)
                      : null,
                  child: listing.sellerAvatar == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              listing.sellerName ?? 'بائع',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (listing.sellerIsVerified) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                      if (joinYear != null)
                        Text(
                          'عضو منذ $joinYear',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      Text(
                        '$listingsCount إعلان',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.push('/seller/${listing.userId}'),
              child: const Text('عرض جميع إعلاناته'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyTipsSection extends StatelessWidget {
  const _SafetyTipsSection();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('نصائح الأمان'),
      children: const [
        ListTile(
          dense: true,
          leading: Icon(Icons.place_outlined),
          title: Text('قابل البائع في مكان عام'),
        ),
        ListTile(
          dense: true,
          leading: Icon(Icons.payments_outlined),
          title: Text('لا تدفع مقدماً قبل معاينة المنتج'),
        ),
        ListTile(
          dense: true,
          leading: Icon(Icons.verified_user_outlined),
          title: Text('تحقّق من حالة المنتج قبل الشراء'),
        ),
      ],
    );
  }
}
