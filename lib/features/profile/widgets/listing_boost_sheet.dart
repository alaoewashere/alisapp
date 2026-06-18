import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/widgets/package_badge.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../listings/data/listings_repository.dart';
import '../data/profile_repository.dart';
import '../utils/listing_boost_utils.dart';

Future<void> showListingBoostSheet(
  BuildContext context,
  WidgetRef ref, {
  required ListingModel listing,
  required UserSubscriptionTier userTier,
  required VoidCallback onSuccess,
}) {
  final postPackage = listingPackageFor(listing);
  final options = listingBoostOptions(postPackage: postPackage);
  if (options.isEmpty) return Future.value();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _ListingBoostSheet(
      listing: listing,
      options: options,
      onConfirm: (option) async {
        final profile = ref.read(currentProfileProvider).value;
        final userId = ref.read(currentUserIdProvider);
        if (userId == null) return;

        await ref.read(listingsRepositoryProvider).applyListingBoost(
              listingId: listing.id,
              userId: userId,
              currentMetadata: listing.metadata,
              targetPackage: option.targetPackage,
              priceIqd: option.priceIqd,
              setFeatured: option.setFeatured,
              setBoosted: option.setBoosted,
              upgradePackage: option.upgradePackage,
              userName: profile?.fullName ?? '',
              userPhone: profile?.phone,
              userEmail: profile?.email,
            );
        if (sheetContext.mounted) Navigator.pop(sheetContext);
        onSuccess();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم ترقية إعلانك بنجاح',
                style: AppFonts.cairo(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.approved,
            ),
          );
        }
      },
    ),
  );
}

class _ListingBoostSheet extends StatefulWidget {
  const _ListingBoostSheet({
    required this.listing,
    required this.options,
    required this.onConfirm,
  });

  final ListingModel listing;
  final List<ListingBoostOption> options;
  final Future<void> Function(ListingBoostOption option) onConfirm;

  @override
  State<_ListingBoostSheet> createState() => _ListingBoostSheetState();
}

class _ListingBoostSheetState extends State<_ListingBoostSheet> {
  int? _selectedIndex;
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    if (widget.options.length == 1) {
      _selectedIndex = 0;
    }
  }

  Future<void> _confirm() async {
    final index = _selectedIndex;
    if (index == null) return;

    setState(() => _confirming = true);
    try {
      await widget.onConfirm(widget.options[index]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final needsSelection = widget.options.length > 1;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ترقية إعلانك',
            textAlign: TextAlign.right,
            style: AppFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.pureWhite,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'اختر الباقة المناسبة لزيادة ظهور إعلانك في أعلى الأقسام',
            textAlign: TextAlign.right,
            style: AppFonts.cairo(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(widget.options.length, (index) {
            final option = widget.options[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < widget.options.length - 1 ? 12 : 0,
              ),
              child: _BoostOptionCard(
                option: option,
                selected: _selectedIndex == index,
                onTap: needsSelection
                    ? () => setState(() => _selectedIndex = index)
                    : null,
              ),
            );
          }),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _selectedIndex == null || _confirming ? null : _confirm,
            child: _confirming
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'تأكيد',
                    style: AppFonts.cairo(fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BoostOptionCard extends StatelessWidget {
  const _BoostOptionCard({
    required this.option,
    required this.selected,
    this.onTap,
  });

  final ListingBoostOption option;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fieldCarbon,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.volt : AppColors.glassBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  PackageBadge(
                    package: option.targetPackage,
                    size: PackageBadgeSize.medium,
                  ),
                  const Spacer(),
                  Text(
                    formatIqd(option.priceIqd),
                    style: AppFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.volt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                option.titleAr,
                textAlign: TextAlign.right,
                style: AppFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pureWhite,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                option.descriptionAr,
                textAlign: TextAlign.right,
                style: AppFonts.cairo(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
