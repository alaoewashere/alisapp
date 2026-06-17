import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../providers/post_listing_provider.dart';
import 'step2_animal_details.dart';
import 'step2_electronics_details.dart';
import 'step2_general_marketplace_details.dart';
import 'step2_home_service_details.dart';
import 'step2_job_details.dart';
import 'step2_generic_details.dart';
import 'step2_real_estate_details.dart';
import 'step2_tutoring_details.dart';
import 'step2_vehicle_details.dart';

class Step2Details extends ConsumerWidget {
  const Step2Details({super.key});

  static String _formKind(PostListingState state) {
    if (state.isVehicleListing) return 'vehicle';
    if (state.isRealEstateListing) return 'real_estate';
    if (state.isElectronicsListing) return 'electronics';
    if (state.isGeneralMarketplaceListing) return 'general';
    if (state.isTutoringListing) return 'tutoring';
    if (state.isJobListing) return 'job';
    if (state.isAnimalListing) return 'animal';
    if (state.isHomeServiceListing) return 'home_service';
    return 'generic';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postListingProvider);
    final formKind = _formKind(state);

    return Theme(
      data: Theme.of(context).copyWith(
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.textMuted;
            }
            if (states.contains(WidgetState.selected)) {
              return AppColors.volt;
            }
            return AppColors.pureWhite;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return const Color(0xFF3A3A3C).withValues(alpha: 0.5);
            }
            if (states.contains(WidgetState.selected)) {
              return AppColors.volt.withValues(alpha: 0.45);
            }
            return const Color(0xFF3A3A3C);
          }),
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(formKind),
        child: switch (formKind) {
          'vehicle' => const Step2VehicleDetails(),
          'real_estate' => const Step2RealEstateDetails(),
          'electronics' => const Step2ElectronicsDetails(),
          'general' => const Step2GeneralMarketplaceDetails(),
          'tutoring' => const Step2TutoringDetails(),
          'job' => const Step2JobDetails(),
          'animal' => const Step2AnimalDetails(),
          'home_service' => const Step2HomeServiceDetails(),
          _ => const Step2GenericDetails(),
        },
      ),
    );
  }
}
