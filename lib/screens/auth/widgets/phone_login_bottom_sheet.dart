import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/validators.dart';
import '../../../features/auth/data/auth_repository.dart';
import '../../../features/auth/widgets/auth_form_styles.dart';
Future<void> showPhoneLoginBottomSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _PhoneLoginSheet(),
  );
}

class _PhoneLoginSheet extends ConsumerStatefulWidget {
  const _PhoneLoginSheet();

  @override
  ConsumerState<_PhoneLoginSheet> createState() => _PhoneLoginSheetState();
}

class _PhoneLoginSheetState extends ConsumerState<_PhoneLoginSheet> {
  static const _fieldRadius = 14.0;
  static const _fieldBorder = Color(0x15FFFFFF);
  static const _sheetTopBorder = Color(0x10FFFFFF);

  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  late Country _selectedCountry;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedCountry = Country.parse('SA');
    _phoneFocusNode.addListener(_onPhoneFocusChanged);
  }

  void _onPhoneFocusChanged() => setState(() {});

  @override
  void dispose() {
    _phoneFocusNode.removeListener(_onPhoneFocusChanged);
    _phoneFocusNode.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
    );
  }

  Future<void> _sendCode() async {
    final isoCode = _selectedCountry.countryCode;
    final localDigits = Validators.normalizeLocalDigits(
      _phoneController.text,
      isoCode,
      phoneCode: _selectedCountry.phoneCode,
    );
    final error = Validators.localPhone(localDigits, isoCode);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    setState(() => _loading = true);
    final fullPhone = Validators.formatE164(
      '+${_selectedCountry.phoneCode}',
      localDigits,
    );
    final result = await ref.read(authRepositoryProvider).sendWhatsAppOtp(
          fullPhone,
        );
    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case Success():
        Navigator.of(context).pop();
        context.push(
          '${AppRoutes.phoneVerify}?phone=${Uri.encodeComponent(fullPhone)}',
        );
      case Failure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isPhoneFocused = _phoneFocusNode.hasFocus;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: _sheetTopBorder)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'متابعة برقم الهاتف',
                  style: AppFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pureWhite,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'سنرسل لك رمز تحقق عبر واتساب',
                  style: AppFonts.cairo(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.fieldCarbon,
                      borderRadius: BorderRadius.circular(_fieldRadius),
                      border: Border.all(
                        color: isPhoneFocused ? AppColors.volt : _fieldBorder,
                        width: isPhoneFocused ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Material(
                          color: AppColors.fieldCarbon,
                          child: InkWell(
                            onTap: _loading ? null : _pickCountry,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(_fieldRadius),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _selectedCountry.flagEmoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '+${_selectedCountry.phoneCode}',
                                    style: AppFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.pureWhite,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 20,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: _fieldBorder,
                        ),
                        Expanded(
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: TextField(
                              controller: _phoneController,
                              focusNode: _phoneFocusNode,
                              keyboardType: TextInputType.phone,
                              enabled: !_loading,
                              cursorColor: AppColors.volt,
                              style: AppFonts.cairo(
                                fontSize: 16,
                                color: AppColors.pureWhite,
                              ),
                              decoration: InputDecoration(
                                hintText: '5XXXXXXXX',
                                hintStyle: AppFonts.cairo(
                                  color: AppColors.pureWhite
                                      .withValues(alpha: 0.5),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  label: 'إرسال الرمز',
                  loading: _loading,
                  loginStyle: true,
                  onPressed: _sendCode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
