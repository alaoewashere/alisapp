import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/supabase/supabase_client.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/widgets/guest_bottom_sheet.dart';
import '../../features/favorites/providers/favorites_provider.dart';
import '../models/listing_model.dart';

/// Heart overlay for listing card images — dark circle, white / Volt when saved.
class ListingCardFavoriteButton extends StatelessWidget {
  const ListingCardFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
  });

  final bool isFavorite;
  final VoidCallback onTap;

  static const double size = 32;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0x60000000),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 16,
          color: isFavorite ? AppColors.volt : AppColors.pureWhite,
        ),
      ),
    );
  }
}

/// Favorite toggle wired to [toggleFavoriteProvider] with guest gating.
class ListingFavoriteToggleButton extends ConsumerWidget {
  const ListingFavoriteToggleButton({
    super.key,
    required this.listing,
  });

  final ListingModel listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      toggleFavoriteProvider.select((ids) => ids.contains(listing.id)),
    );
    final isGuest = ref.watch(isGuestProvider);

    return ListingCardFavoriteButton(
      isFavorite: isFavorite,
      onTap: () async {
        HapticFeedback.selectionClick();
        if (isGuest || !ref.read(isAuthenticatedProvider)) {
          await showGuestBottomSheet(context);
          return;
        }
        await ref.read(toggleFavoriteProvider.notifier).toggle(listing.id);
      },
    );
  }
}
