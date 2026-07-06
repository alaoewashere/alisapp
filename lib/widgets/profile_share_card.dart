import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_governorates.dart';
import '../core/l10n/category_locale.dart';
import '../core/l10n/l10n_provider.dart';
import '../shared/widgets/app_logo.dart';
import '../core/constants/deep_link_constants.dart';
import '../core/utils/arabic_number.dart';
import '../shared/models/profile_model.dart';
import 'sello_watermark.dart';

/// Off-screen 1080×600 landscape profile card captured via [repaintKey].
class ProfileShareCard extends ConsumerWidget {
  const ProfileShareCard({
    super.key,
    required this.repaintKey,
    required this.profile,
    required this.listingCount,
  });

  final GlobalKey repaintKey;
  final ProfileModel profile;
  final int listingCount;

  static const cardWidth = 1080.0;
  static const cardHeight = 600.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    final localeCode = ref.watch(categoryLocaleCodeProvider);
    final sellerLink = DeepLinkConstants.sellerUrl(profile.id);
    final cityLabel = _cityLabel(localeCode);
    final initial = _initial;

    return RepaintBoundary(
      key: repaintKey,
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: cardHeight * 0.5,
                  child: ColoredBox(
                    color: AppColors.primary,
                    child: Center(
                      child: AppLogo(size: 80),
                    ),
                  ),
                ),
                Expanded(
                  child: ColoredBox(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          children: [
                            _ProfileAvatar(profile: profile, initial: initial),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (profile.isVerifiedSeller) ...[
                                  const Icon(
                                    Icons.verified,
                                    color: Color(0xFF1DA1F2),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Flexible(
                                  child: Text(
                                    profile.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFonts.cairo(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              strings.listingsOnSouqakCount(
                                arabicNumber(listingCount),
                              ),
                              style: AppFonts.cairo(
                                fontSize: 15,
                                color: AppColors.textMuted,
                              ),
                            ),
                            if (cityLabel.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    cityLabel,
                                    style: AppFonts.cairo(
                                      fontSize: 14,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ),
                            ],
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                sellerLink,
                                style: AppFonts.robotoMono(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SelloWatermark(
              size: const Size(cardWidth, cardHeight),
            ),
          ],
        ),
      ),
    );
  }

  String _cityLabel(String localeCode) {
    if (profile.city?.trim().isNotEmpty == true) {
      return profile.city!.trim();
    }
    if (profile.governorate?.trim().isNotEmpty == true) {
      final slug = profile.governorate!.trim();
      for (final governorate in iraqiGovernorates) {
        if (governorate.slug == slug) {
          return governorate.displayName(localeCode);
        }
      }
    }
    return '';
  }

  String get _initial {
    final name = profile.fullName.trim();
    if (name.isEmpty) return '?';
    return name[0];
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.profile,
    required this.initial,
  });

  final ProfileModel profile;
  final String initial;

  @override
  Widget build(BuildContext context) {
    const size = 72.0;
    final avatarUrl = profile.avatarUrl?.trim();

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _InitialAvatar(initial: initial, size: size),
        ),
      );
    }

    return _InitialAvatar(initial: initial, size: size);
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.initial, required this.size});

  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5EE),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppFonts.cairo(
          fontSize: size * 0.42,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
