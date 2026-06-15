import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_governorates.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/animal_listing_utils.dart';
import '../../../../core/utils/electronics_listing_utils.dart';
import '../../../../core/utils/general_listing_utils.dart';
import '../../../../core/utils/home_service_listing_utils.dart';
import '../../../../core/utils/job_listing_utils.dart';
import '../../../../core/utils/real_estate_listing_utils.dart';
import '../../../../core/utils/tutoring_listing_utils.dart';
import '../../../../core/utils/vehicle_listing_utils.dart';
import '../../../../shared/models/listing_model.dart';
import '../../providers/post_listing_provider.dart';
import '../car_paint/car_paint_summary_widget.dart';
import '../category_path_breadcrumb.dart';

class Step5Review extends ConsumerStatefulWidget {
  const Step5Review({
    super.key,
    required this.onPublish,
    required this.onSaveDraft,
  });

  final VoidCallback onPublish;
  final VoidCallback onSaveDraft;

  @override
  ConsumerState<Step5Review> createState() => _Step5ReviewState();
}

class _Step5ReviewState extends ConsumerState<Step5Review> {
  bool _descriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final theme = Theme.of(context);
    final categoryLabel = state.categoryPath.isNotEmpty
        ? state.categoryPathLabel
        : (state.effectiveCategory?.nameAr ?? '');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'مراجعة الإعلان',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _ReviewSection(
                title: 'الصور',
                step: state.photosStep,
                onEdit: notifier.goToStep,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.images.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.file(
                            state.images.first,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    if (state.images.length > 1) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.images.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              state.images[i],
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _ReviewSection(
                title: 'التفاصيل',
                step: 2,
                onEdit: notifier.goToStep,
                child: state.isVehicleListing
                    ? _VehicleReviewSummary(state: state)
                    : state.isRealEstateListing
                        ? _RealEstateReviewSummary(state: state)
                        : state.isElectronicsListing
                            ? _ElectronicsReviewSummary(state: state)
                            : state.isGeneralMarketplaceListing
                                ? _GeneralMarketplaceReviewSummary(state: state)
                                : state.isTutoringListing
                                    ? _MetaReviewSummary(
                                        title: state.title.isNotEmpty
                                            ? state.title
                                            : buildTutoringListingTitle(
                                                state.categoryPath,
                                                state.tutoringDetails,
                                              ),
                                        price: state.tutoringDetails
                                                .pricePerHour
                                                ?.toDouble() ??
                                            state.price,
                                        isNegotiable: state.isNegotiable,
                                        badges: [
                                          if (state.tutoringDetails.subject !=
                                              null)
                                            state.tutoringDetails.subject!,
                                          ...state.tutoringDetails.stages,
                                          if (state.tutoringDetails
                                                  .sessionType !=
                                              null)
                                            state.tutoringDetails.sessionType!,
                                        ],
                                      )
                                    : state.isJobListing
                                        ? _MetaReviewSummary(
                                            title: state.title.isNotEmpty
                                                ? state.title
                                                : buildJobListingTitle(
                                                    state.categoryPath,
                                                    state.jobDetails,
                                                  ),
                                            price: state.jobDetails.salaryMin
                                                ?.toDouble(),
                                            isNegotiable: state.isNegotiable,
                                            badges: [
                                              if (state.jobDetails.jobType !=
                                                  null)
                                                state.jobDetails.jobType!,
                                              if (state.jobDetails.sector !=
                                                  null)
                                                state.jobDetails.sector!,
                                              ...state.jobDetails.benefits,
                                            ],
                                          )
                                        : state.isAnimalListing
                                            ? _MetaReviewSummary(
                                                title: state.title.isNotEmpty
                                                    ? state.title
                                                    : buildAnimalListingTitle(
                                                        state.categoryPath,
                                                        state.animalDetails,
                                                      ),
                                                price: state.price,
                                                isNegotiable:
                                                    state.isNegotiable,
                                                badges: [
                                                  if (state.animalDetails
                                                          .animalType !=
                                                      null)
                                                    state.animalDetails
                                                        .animalType!,
                                                  if (state.animalDetails
                                                          .breed !=
                                                      null)
                                                    state.animalDetails.breed!,
                                                  if (state.animalDetails
                                                          .gender !=
                                                      null)
                                                    state.animalDetails.gender!,
                                                ],
                                              )
                                            : state.isHomeServiceListing
                                                ? _MetaReviewSummary(
                                                    title: state.title
                                                            .isNotEmpty
                                                        ? state.title
                                                        : buildHomeServiceListingTitle(
                                                            state
                                                                .categoryPath,
                                                            state
                                                                .homeServiceDetails,
                                                          ),
                                                    price: state
                                                        .homeServiceDetails
                                                        .salaryExpected
                                                        ?.toDouble(),
                                                    isNegotiable:
                                                        state.isNegotiable,
                                                    badges: [
                                                      if (state
                                                              .homeServiceDetails
                                                              .serviceType !=
                                                          null)
                                                        state
                                                            .homeServiceDetails
                                                            .serviceType!,
                                                      if (state
                                                              .homeServiceDetails
                                                              .availability !=
                                                          null)
                                                        state
                                                            .homeServiceDetails
                                                            .availability!,
                                                      ...state
                                                          .homeServiceDetails
                                                          .languages,
                                                    ],
                                                  )
                                                : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            state.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.price != null
                                ? formatIQD(state.price!)
                                : '—',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          if (state.condition != null) ...[
                            const SizedBox(height: 8),
                            _Badge(
                              label: state.condition == ListingCondition.newItem
                                  ? 'جديد'
                                  : 'مستعمل',
                            ),
                          ],
                        ],
                      ),
              ),
              _ReviewSection(
                title: 'الفئة',
                step: 1,
                onEdit: notifier.goToStep,
                child: state.categoryPath.isNotEmpty
                    ? CategoryPathBreadcrumb(path: state.categoryPath)
                    : Text(categoryLabel),
              ),
              if (state.isVehicleListing) ...[
                _ReviewSection(
                  title: 'حالة الهيكل والطلاء',
                  step: 3,
                  onEdit: notifier.goToStep,
                  child: CarPaintSummaryWidget(
                    panelConditions: state.vehicleDetails.panelConditions,
                    diagramHeight: 140,
                    showWhenAllOriginal: true,
                    requireMarkedPanels: false,
                  ),
                ),
              ],
              _ReviewSection(
                title: 'الموقع',
                step: state.locationStep,
                onEdit: notifier.goToStep,
                child: Text(
                  governorateNameAr(state.governorate ?? ''),
                ),
              ),
              if (!state.isVehicleListing &&
                  !state.isRealEstateListing &&
                  !state.isElectronicsListing &&
                  !state.isGeneralMarketplaceListing &&
                  !state.isTutoringListing &&
                  !state.isJobListing &&
                  !state.isAnimalListing &&
                  !state.isHomeServiceListing)
                _ReviewSection(
                  title: 'الوصف',
                  step: 2,
                  onEdit: notifier.goToStep,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        state.description,
                        maxLines: _descriptionExpanded ? null : 3,
                        overflow: _descriptionExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                      if (state.description.length > 120)
                        TextButton(
                          onPressed: () => setState(
                            () => _descriptionExpanded = !_descriptionExpanded,
                          ),
                          child: Text(
                            _descriptionExpanded ? 'عرض أقل' : 'عرض المزيد',
                          ),
                        ),
                    ],
                  ),
                ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                TextButton(
                  onPressed: widget.onPublish,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ],
          ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.title,
    required this.step,
    required this.onEdit,
    required this.child,
  });

  final String title;
  final int step;
  final void Function(int) onEdit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () => onEdit(step),
                  child: const Text('تعديل'),
                ),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

class _VehicleReviewSummary extends StatelessWidget {
  const _VehicleReviewSummary({required this.state});

  final PostListingState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vehicle = state.vehicleDetails;
    final title = state.title.isNotEmpty
        ? state.title
        : buildVehicleListingTitle(state.categoryPath, vehicle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          state.price != null ? formatIQD(state.price!) : '—',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        if (state.isNegotiable) ...[
          const SizedBox(height: 4),
          const _Badge(label: 'قابل للتفاوض'),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (state.condition != null)
              _Badge(
                label: state.condition == ListingCondition.newItem
                    ? 'جديد'
                    : 'مستعمل',
              ),
            if (vehicle.fuel != null) _Badge(label: vehicle.fuel!),
            if (vehicle.transmission != null)
              _Badge(label: vehicle.transmission!),
            if (vehicle.mileage != null)
              _Badge(
                label: '${vehicle.mileage} ${vehicle.mileageUnit.labelAr}',
              ),
            if (vehicle.color != null) _Badge(label: vehicle.color!),
          ],
        ),
        if (vehicle.selectedSpecs.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${vehicle.selectedSpecs.length} مواصفة مختارة',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _RealEstateReviewSummary extends StatelessWidget {
  const _RealEstateReviewSummary({required this.state});

  final PostListingState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = state.realEstateDetails;
    final title = state.title.isNotEmpty
        ? state.title
        : buildRealEstateListingTitle(state.categoryPath, details);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          state.price != null ? formatIQD(state.price!) : '—',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        if (state.isNegotiable) ...[
          const SizedBox(height: 4),
          const _Badge(label: 'قابل للتفاوض'),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (details.offerType != null) _Badge(label: details.offerType!),
            if (details.propertyType != null)
              _Badge(label: details.propertyType!),
            if (details.areaSqm != null)
              _Badge(label: '${details.areaSqm} م²'),
            if (details.rooms != null) _Badge(label: '${details.rooms} غرف'),
            if (details.furnished != null) _Badge(label: details.furnished!),
          ],
        ),
        if (details.features.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${details.features.length} ميزة مختارة',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _ElectronicsReviewSummary extends StatelessWidget {
  const _ElectronicsReviewSummary({required this.state});

  final PostListingState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = state.electronicsDetails;
    final title = state.title.isNotEmpty
        ? state.title
        : buildElectronicsListingTitle(state.categoryPath, details);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          state.price != null ? formatIQD(state.price!) : '—',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        if (state.isNegotiable) ...[
          const SizedBox(height: 4),
          const _Badge(label: 'قابل للتفاوض'),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (details.condition != null) _Badge(label: details.condition!),
            if (details.storage != null) _Badge(label: details.storage!),
            if (details.ram != null) _Badge(label: details.ram!),
            if (details.color != null) _Badge(label: details.color!),
            if (details.processor != null) _Badge(label: details.processor!),
            if (details.screenSize != null)
              _Badge(label: '${details.screenSize}"'),
            if (details.resolution != null) _Badge(label: details.resolution!),
            if (details.warranty != null) _Badge(label: details.warranty!),
            if (details.smart == true) const _Badge(label: 'سمارت TV'),
          ],
        ),
      ],
    );
  }
}

class _MetaReviewSummary extends StatelessWidget {
  const _MetaReviewSummary({
    required this.title,
    required this.price,
    required this.isNegotiable,
    required this.badges,
  });

  final String title;
  final double? price;
  final bool isNegotiable;
  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          price != null ? formatIQD(price!) : '—',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        if (isNegotiable) ...[
          const SizedBox(height: 4),
          const _Badge(label: 'قابل للتفاوض'),
        ],
        if (badges.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: badges.map((b) => _Badge(label: b)).toList(),
          ),
        ],
      ],
    );
  }
}

class _GeneralMarketplaceReviewSummary extends StatelessWidget {
  const _GeneralMarketplaceReviewSummary({required this.state});

  final PostListingState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = state.generalDetails;
    final title = state.title.isNotEmpty
        ? state.title
        : buildGeneralListingTitle(state.categoryPath, details);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          state.price != null ? formatIQD(state.price!) : '—',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        if (state.isNegotiable) ...[
          const SizedBox(height: 4),
          const _Badge(label: 'قابل للتفاوض'),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (details.itemCondition != null)
              _Badge(label: details.itemCondition!),
            if (details.brand != null && details.brand!.isNotEmpty)
              _Badge(label: details.brand!),
            if (details.exchangePossible == true)
              const _Badge(label: 'قابل للتبادل'),
            if (details.deliveryAvailable == true) ...[
              const _Badge(label: 'توصيل متاح'),
              if (details.deliveryCost != null)
                _Badge(label: details.deliveryCost!),
            ],
          ],
        ),
      ],
    );
  }
}
