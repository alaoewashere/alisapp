import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final _phoneController = TextEditingController();
  late Country _selectedCountry;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedCountry = Country.parse('SA');
  }

  @override
  void dispose() {
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

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'متابعة برقم الهاتف',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'سنرسل لك رمز تحقق عبر واتساب',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: const Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 24),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AuthFormStyles.fieldFill,
                      borderRadius:
                          BorderRadius.circular(AuthFormStyles.pillRadius),
                    ),
                    child: Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _loading ? null : _pickCountry,
                            borderRadius: BorderRadius.circular(
                              AuthFormStyles.pillRadius,
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
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF111111),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 20,
                                    color: AppColors.textMuted
                                        .withValues(alpha: 0.8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: const Color(0xFFE0E0E0),
                        ),
                        Expanded(
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              enabled: !_loading,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                color: const Color(0xFF111111),
                              ),
                              decoration: InputDecoration(
                                hintText: '5XXXXXXXX',
                                hintStyle: GoogleFonts.cairo(
                                  color: AppColors.textMuted
                                      .withValues(alpha: 0.75),
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
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _loading ? null : _sendCode,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'إرسال الرمز',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
