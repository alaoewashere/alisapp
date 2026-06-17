import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_governorates.dart';
import '../../core/utils/digit_input_formatter.dart';
import '../../core/supabase/supabase_client.dart';
import '../../features/listings/providers/post_listing_provider.dart';
import '../../features/listings/widgets/steps/step2_form_common.dart';
import '../../models/smart_alert.dart';
import '../../models/smart_alert_category.dart';
import '../../services/smart_alert_service.dart';
import '../../shared/models/category_model.dart';
import '../../theme/app_form_fields.dart';
import '../../theme/app_text_styles.dart';
import 'smart_alert_limit_sheet.dart';
import '../../shared/widgets/app_back_button.dart';
import 'widgets/smart_alert_category_pickers.dart';

class CreateAlertScreen extends ConsumerStatefulWidget {
  const CreateAlertScreen({super.key, this.prefill});

  final SmartAlertDraft? prefill;

  @override
  ConsumerState<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends ConsumerState<CreateAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _yearMinController;
  late final TextEditingController _yearMaxController;
  late final TextEditingController _priceMinController;
  late final TextEditingController _priceMaxController;

  List<CategoryModel> _categoryPath = [];
  String? _location;
  bool _saving = false;
  bool _prefillPathLoaded = false;

  @override
  void initState() {
    super.initState();
    final prefill = widget.prefill;
    _titleController = TextEditingController(text: prefill?.title ?? '');
    _yearMinController = TextEditingController(
      text: prefill?.yearMin?.toString() ?? '',
    );
    _yearMaxController = TextEditingController(
      text: prefill?.yearMax?.toString() ?? '',
    );
    _priceMinController = TextEditingController(
      text: prefill?.priceMin?.toString() ?? '',
    );
    _priceMaxController = TextEditingController(
      text: prefill?.priceMax?.toString() ?? '',
    );
    _location = prefill?.location;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefill = widget.prefill;
      if (prefill == null || _prefillPathLoaded) return;
      try {
        final all = await ref.read(allCategoriesProvider.future);
        if (!mounted) return;
        final rebuilt = rebuildCategoryPathFromFields(
          all: all,
          category: prefill.category,
          subcategory: prefill.subcategory,
          make: prefill.make,
          model: prefill.model,
        );
        if (rebuilt != null && rebuilt.isNotEmpty) {
          setState(() {
            _categoryPath = rebuilt;
            _prefillPathLoaded = true;
          });
        }
      } catch (_) {
        // Categories optional for prefill.
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _yearMinController.dispose();
    _yearMaxController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final options = iraqiGovernorates
        .map((g) => Step2PickerOption(value: g.slug, label: g.nameAr))
        .toList();
    final pickedSlug = await showStep2PickerSheetForOptions(
      context: context,
      title: 'الموقع',
      options: options,
      selectedValue: _locationSlug(),
      searchable: true,
    );
    if (pickedSlug != null && mounted) {
      setState(() => _location = governorateNameAr(pickedSlug));
    }
  }

  String? _locationSlug() {
    if (_location == null) return null;
    for (final g in iraqiGovernorates) {
      if (g.nameAr == _location || g.slug == _location) return g.slug;
    }
    return null;
  }

  int? _parseInt(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    setState(() => _saving = true);
    try {
      final categoryFields = categoryFieldsFromPath(_categoryPath);
      final yearFromPath = categoryFields.year;
      final yearMin = _parseInt(_yearMinController.text) ?? yearFromPath;
      final yearMax = _parseInt(_yearMaxController.text) ?? yearFromPath;

      final alert = SmartAlert(
        id: '',
        userId: userId,
        title: _titleController.text.trim(),
        category: categoryFields.category,
        subcategory: categoryFields.subcategory,
        make: categoryFields.make,
        model: categoryFields.model,
        yearMin: yearMin,
        yearMax: yearMax,
        priceMin: _parseInt(_priceMinController.text),
        priceMax: _parseInt(_priceMaxController.text),
        location: _location,
        createdAt: DateTime.now(),
      );

      await ref
          .read(smartAlertServiceProvider)
          .createAlert(userId: userId, alert: alert);

      ref.invalidate(userSmartAlertsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ التنبيه ✓ سنخبرك فور نشر إعلان مطابق',
            style: AppFonts.cairo(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } on SmartAlertException catch (e) {
      if (e.message == 'free_limit_reached') {
        if (mounted) await showSmartAlertLimitSheet(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message, style: AppFonts.cairo())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذّر حفظ التنبيه: $e', style: AppFonts.cairo()),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: Text(
          'تنبيه ذكي جديد',
          style: AppFonts.cairo(fontWeight: FontWeight.bold),
        ),
        leading: AppBackButton(onPressed: () => context.pop()),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _FormCard(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        decoration: AppFormDecorations.underline(
                          hintText: 'اسم التنبيه *',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'اسم التنبيه مطلوب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      SmartAlertCategoryPickers(
                        path: _categoryPath,
                        onPathChanged: (path) => setState(() => _categoryPath = path),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FormCard(
                    children: [
                      Text(
                        'سنة الصنع',
                        style: AppFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _yearMinController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [appDigitsOnly()],
                              textAlign: TextAlign.center,
                              style: AppTextStyles.input,
                              decoration: AppFormDecorations.underline(
                                hintText: 'من',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _yearMaxController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [appDigitsOnly()],
                              textAlign: TextAlign.center,
                              style: AppTextStyles.input,
                              decoration: AppFormDecorations.underline(
                                hintText: 'إلى',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FormCard(
                    children: [
                      Text(
                        'السعر',
                        style: AppFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Step2IqdField(
                              label: 'من',
                              controller: _priceMinController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Step2IqdField(
                              label: 'إلى',
                              controller: _priceMaxController,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FormCard(
                    children: [
                      Step2PickerTriggerRow(
                        label: 'الموقع',
                        displayValue: _location ?? 'كل العراق',
                        onTap: _pickLocation,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.canvas,
                          ),
                        )
                      : Text(
                          'حفظ التنبيه',
                          style: AppFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.microShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
