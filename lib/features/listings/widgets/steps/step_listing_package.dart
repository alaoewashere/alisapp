import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/package_badge.dart';
import '../../../../shared/models/listing_model.dart';
import '../../constants/listing_package_config.dart';
import '../../providers/post_listing_provider.dart';

class StepListingPackage extends ConsumerStatefulWidget {
  const StepListingPackage({super.key});

  @override
  ConsumerState<StepListingPackage> createState() => _StepListingPackageState();
}

class _StepListingPackageState extends ConsumerState<StepListingPackage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postListingProvider.notifier).refreshFreePostQuota();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'اختر الباقة',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...ListingPackageConfig.options.map((option) {
                    final isLast =
                        option.package == ListingPackage.premium;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                      child: _PackageTierCard(
                        option: option,
                        isSelected: state.listingPackage == option.package,
                        freePostsRemaining: state.freePostsRemaining,
                        quotaLoaded: state.freePostQuotaLoaded,
                        onTap: () => notifier.setListingPackage(option.package),
                      ),
                    );
                  }),
                  if (state.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.approved,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: notifier.confirmListingPackage,
                child: const Text(
                  'متابعة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PackageTierCard extends StatelessWidget {
  const _PackageTierCard({
    required this.option,
    required this.isSelected,
    required this.freePostsRemaining,
    required this.quotaLoaded,
    required this.onTap,
  });

  final ListingPackageOption option;
  final bool isSelected;
  final int freePostsRemaining;
  final bool quotaLoaded;
  final VoidCallback onTap;

  String _priceLabel() {
    if (option.package == ListingPackage.standard &&
        quotaLoaded &&
        freePostsRemaining > 0) {
      return '0 د.ع (متبقي $freePostsRemaining من 2 إعلان مجاني)';
    }
    return formatPackagePriceIqd(option.priceIqd);
  }

  @override
  Widget build(BuildContext context) {
    final showQuotaWarning = option.package == ListingPackage.standard &&
        quotaLoaded &&
        freePostsRemaining <= 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.fieldCarbon
                : AppColors.fieldCarbon,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.volt : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.volt.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0),
          transformAlignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PackageBadge(
                          package: option.package,
                          size: PackageBadgeSize.compact,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          option.labelAr,
                          style: AppFonts.sans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.pureWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.volt,
                      size: 22,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _priceLabel(),
                style: AppFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.volt,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                option.durationLabelAr,
                style: AppFonts.sans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.pureWhite.withValues(alpha: 0.65),
                ),
              ),
              if (showQuotaWarning) ...[
                const SizedBox(height: 8),
                Text(
                  'تم استخدام إعلانيك المجانيين. سيتم تحصيل رسوم الإعلان العادي.',
                  style: AppFonts.sans(
                    fontSize: 12,
                    color: AppColors.pending,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              ...option.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.volt,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature.title,
                              style: AppFonts.sans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.pureWhite,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              feature.description,
                              style: AppFonts.sans(
                                fontSize: 12,
                                color: AppColors.pureWhite.withValues(alpha: 0.55),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
