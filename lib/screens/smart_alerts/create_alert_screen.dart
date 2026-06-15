import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_governorates.dart';
import '../../core/constants/notification_constants.dart';
import '../../core/supabase/supabase_client.dart';
import '../../features/listings/widgets/steps/step2_form_common.dart';
import '../../models/smart_alert.dart';
import '../../services/smart_alert_service.dart';
import '../../theme/app_form_fields.dart';
import 'smart_alert_limit_sheet.dart';

class CreateAlertScreen extends ConsumerStatefulWidget {
  const CreateAlertScreen({super.key, this.prefill});

  final SmartAlertDraft? prefill;

  @override
  ConsumerState<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends ConsumerState<CreateAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearMinController;
  late final TextEditingController _yearMaxController;
  late final TextEditingController _priceMinController;
  late final TextEditingController _priceMaxController;

  String? _category;
  String? _location;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final prefill = widget.prefill;
    _titleController = TextEditingController(text: prefill?.title ?? '');
    _makeController = TextEditingController(text: prefill?.make ?? '');
    _modelController = TextEditingController(text: prefill?.model ?? '');
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
    _category = prefill?.category;
    _location = prefill?.location;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearMinController.dispose();
    _yearMaxController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
    super.dispose();
  }

  bool get _isVehicle =>
      _category != null && _category!.trim() == kSmartAlertVehicleCategory;

  Future<void> _pickCategory() async {
    final picked = await showStep2PickerSheet(
      context: context,
      title: 'الفئة',
      options: kSmartAlertCategoryOptions,
      selected: _category,
    );
    if (picked != null && mounted) {
      setState(() {
        _category = picked;
        if (!_isVehicle) {
          _makeController.clear();
          _modelController.clear();
        }
      });
    }
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
      final alert = SmartAlert(
        id: '',
        userId: userId,
        title: _titleController.text.trim(),
        category: _category,
        make: _isVehicle ? _makeController.text.trim() : null,
        model: _isVehicle ? _modelController.text.trim() : null,
        yearMin: _parseInt(_yearMinController.text),
        yearMax: _parseInt(_yearMaxController.text),
        priceMin: _parseInt(_priceMinController.text),
        priceMax: _parseInt(_priceMaxController.text),
        location: _location,
        createdAt: DateTime.now(),
      );

      await ref.read(smartAlertServiceProvider).createAlert(
            userId: userId,
            alert: alert,
          );

      ref.invalidate(userSmartAlertsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ التنبيه ✓ سنخبرك فور نشر إعلان مطابق',
            style: GoogleFonts.cairo(),
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
          SnackBar(content: Text(e.message, style: GoogleFonts.cairo())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذّر حفظ التنبيه: $e', style: GoogleFonts.cairo()),
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
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => context.pop(),
        ),
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
                      Step2PickerTriggerRow(
                        label: 'الفئة',
                        displayValue: _category ?? 'الكل',
                        onTap: _pickCategory,
                      ),
                      if (_isVehicle) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _makeController,
                          textDirection: TextDirection.rtl,
                          decoration: AppFormDecorations.underline(
                            hintText: 'الصانع',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _modelController,
                          textDirection: TextDirection.rtl,
                          decoration: AppFormDecorations.underline(
                            hintText: 'الموديل',
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FormCard(
                    children: [
                      Text(
                        'سنة الصنع',
                        style: GoogleFonts.cairo(
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
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textAlign: TextAlign.center,
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
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textAlign: TextAlign.center,
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
                        style: GoogleFonts.cairo(
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
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'حفظ التنبيه',
                          style: GoogleFonts.cairo(
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
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
