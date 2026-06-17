import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/post_listing_provider.dart';
import 'listing_video_upload_section.dart';

class EditListingVideoSection extends ConsumerWidget {
  const EditListingVideoSection({
    super.key,
    required this.existingVideoUrl,
    required this.existingThumbnailUrl,
    required this.canUploadVideo,
  });

  final String? existingVideoUrl;
  final String? existingThumbnailUrl;
  final bool canUploadVideo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postListingProvider);
    final hasExisting = existingVideoUrl != null && existingVideoUrl!.isNotEmpty;
    final showPending = post.pendingVideoFile != null;

    if (!canUploadVideo && !hasExisting) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'الفيديو',
            style: AppFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          if (hasExisting && !showPending) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (existingThumbnailUrl != null &&
                        existingThumbnailUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: existingThumbnailUrl!,
                        fit: BoxFit.cover,
                      )
                    else
                      ColoredBox(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.videocam_outlined, size: 48),
                      ),
                    Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 56,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الفيديو الحالي — يمكنك استبداله بفيديو جديد أدناه',
              style: AppFonts.cairo(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
          if (canUploadVideo) const ListingVideoUploadSection(),
        ],
      ),
    );
  }
}
