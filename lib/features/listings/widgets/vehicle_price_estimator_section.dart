import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/theme/app_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../core/utils/vehicle_listing_utils.dart';
import '../../../models/price_estimate.dart';
import '../../../services/groq_service.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/models/vehicle_listing_metadata.dart';

final groqServiceProvider = Provider<GroqService>((ref) {
  return GroqService(client: ref.watch(supabaseClientProvider));
});

/// Optional AI price helper shown on the automobile car details step.
class VehiclePriceEstimatorSection extends ConsumerStatefulWidget {
  const VehiclePriceEstimatorSection({
    super.key,
    required this.categoryPath,
    required this.vehicle,
    required this.condition,
  });

  final List<CategoryModel> categoryPath;
  final VehicleListingMetadata vehicle;
  final ListingCondition? condition;

  @override
  ConsumerState<VehiclePriceEstimatorSection> createState() =>
      _VehiclePriceEstimatorSectionState();
}

class _VehiclePriceEstimatorSectionState
    extends ConsumerState<VehiclePriceEstimatorSection> {
  bool _isLoading = false;
  PriceEstimate? _estimate;

  Future<void> _requestEstimate() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _estimate = null;
    });

    try {
      final input = CarPriceEstimateInput.fromListingForm(
        categoryPath: widget.categoryPath,
        vehicle: widget.vehicle,
        condition: widget.condition,
      );
      final estimate =
          await ref.read(groqServiceProvider).estimatePrice(input);
      if (!mounted) return;
      setState(() {
        _estimate = estimate;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (kDebugMode) {
        debugPrint('VehiclePriceEstimator: estimate failed: $e');
      }
      final strings = ref.read(appLocalizationsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.priceEstimateFailed,
            style: AppFonts.cairo(),
            textAlign: TextAlign.right,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAutomobileCarListingPath(widget.categoryPath)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        if (_isLoading)
          const _EstimatorLoadingCard()
        else if (_estimate != null)
          _EstimatorResultCard(estimate: _estimate!)
        else
          _EstimatorPromptButton(onPressed: _requestEstimate),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _EstimatorPromptButton extends StatelessWidget {
  const _EstimatorPromptButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;

    return Material(
      color: AppColors.volt,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                strings.calculateSuggestedPrice,
                style: AppFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.canvas,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstimatorLoadingCard extends StatelessWidget {
  const _EstimatorLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.borderLight,
      highlightColor: Colors.white,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
      ),
    );
  }
}

class _EstimatorResultCard extends StatelessWidget {
  const _EstimatorResultCard({required this.estimate});

  final PriceEstimate estimate;

  Color _confidenceColor(String confidence) => switch (confidence) {
        'high' => AppColors.approved,
        'medium' => AppColors.pending,
        _ => AppColors.rejected,
      };

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    final confidenceLabel = switch (estimate.confidence) {
      'high' => strings.confidenceHigh,
      'medium' => strings.confidenceMedium,
      _ => strings.confidenceLow,
    };
    final confidenceColor = _confidenceColor(estimate.confidence);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: AppColors.primary.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
              Text(
                strings.aiPriceEstimateTitle,
                style: AppFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: confidenceColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  confidenceLabel,
                  style: AppFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: confidenceColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${arabicNumber(estimate.minPrice)} — ${arabicNumber(estimate.maxPrice)} ${strings.currencyIqd}',
            textAlign: TextAlign.center,
            style: AppFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            estimate.reasoning,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppFonts.cairo(
              fontSize: 12,
              height: 1.45,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            strings.priceEstimateDisclaimer,
            textAlign: TextAlign.center,
            style: AppFonts.cairo(
              fontSize: 10,
              color: AppColors.textMuted.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
