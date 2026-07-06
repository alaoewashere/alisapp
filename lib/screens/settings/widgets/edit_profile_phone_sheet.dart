import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/l10n/l10n_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/digit_input_formatter.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/validators.dart';
import '../../../features/auth/widgets/auth_form_styles.dart';
import '../../../features/profile/providers/profile_provider.dart';

/// Returns the saved E.164 phone number when the update succeeds.
Future<String?> showEditProfilePhoneSheet(
  BuildContext context,
  WidgetRef ref, {
  String? initialPhoneE164,
}) {
  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _EditProfilePhoneSheet(
      initialPhoneE164: initialPhoneE164,
    ),
  );
}

class _EditProfilePhoneSheet extends ConsumerStatefulWidget {
  const _EditProfilePhoneSheet({this.initialPhoneE164});

  final String? initialPhoneE164;

  @override
  ConsumerState<_EditProfilePhoneSheet> createState() =>
      _EditProfilePhoneSheetState();
}

class _EditProfilePhoneSheetState extends ConsumerState<_EditProfilePhoneSheet> {
  final _phoneController = TextEditingController();
  late Country _selectedCountry;
  bool _loading = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _selectedCountry = Country.parse('IQ');
    _initFromE164(widget.initialPhoneE164);
    _phoneController.addListener(() {
      if (_inlineError != null) {
        setState(() => _inlineError = null);
      }
    });
  }

  void _initFromE164(String? phone) {
    if (phone == null || phone.trim().isEmpty) return;
    final e164 = Validators.normalizeE164(phone);
    for (final iso in ['IQ', 'SA', 'AE', 'JO', 'KW', 'TR']) {
      final country = Country.parse(iso);
      final dial = '+${country.phoneCode}';
      if (e164.startsWith(dial)) {
        _selectedCountry = country;
        _phoneController.text = e164.substring(dial.length);
        return;
      }
    }
    _phoneController.text = e164.replaceFirst('+', '');
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
      onSelect: (country) => setState(() => _selectedCountry = country),
    );
  }

  String? _validateAndBuildPhoneE164() {
    final digitsOnly =
        _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty || digitsOnly.length < 7) {
      return null;
    }

    final localDigits = Validators.normalizeLocalDigits(
      _phoneController.text,
      _selectedCountry.countryCode,
      phoneCode: _selectedCountry.phoneCode,
    );
    final error = Validators.localPhone(
      localDigits,
      _selectedCountry.countryCode,
    );
    if (error != null) return null;

    return Validators.formatE164(
      '+${_selectedCountry.phoneCode}',
      localDigits,
    );
  }

  Future<void> _savePhone() async {
    final phoneE164 = _validateAndBuildPhoneE164();
    if (phoneE164 == null) {
      setState(() => _inlineError = ref.read(appLocalizationsProvider).enterValidPhone);
      return;
    }

    setState(() {
      _loading = true;
      _inlineError = null;
    });

    final result = await ref
        .read(profileNotifierProvider.notifier)
        .updateProfilePhone(phoneE164);

    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case Success():
        Navigator.of(context).pop(phoneE164);
      case Failure(:final message):
        setState(() => _inlineError = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appLocalizationsProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.fieldCarbon,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  strings.phoneNumber,
                  textAlign: TextAlign.center,
                  style: AppFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 20),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AuthFormStyles.fieldFill,
                      borderRadius:
                          BorderRadius.circular(AuthFormStyles.pillRadius),
                      border: Border.all(
                        color: _inlineError != null
                            ? AppColors.rejected
                            : AppColors.glassBorder,
                      ),
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
                                vertical: 14,
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
                                      color: AppColors.textDark,
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
                          color: AppColors.glassBorder,
                        ),
                        Expanded(
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              enabled: !_loading,
                              inputFormatters: [appDigitsOnly()],
                              style: AppFonts.cairo(
                                fontSize: 16,
                                color: AppColors.textDark,
                              ),
                              decoration: InputDecoration(
                                hintText: '7XXXXXXXXX',
                                hintStyle: AppFonts.cairo(
                                  color: AppColors.textMuted
                                      .withValues(alpha: 0.75),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_inlineError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _inlineError!,
                    textAlign: TextAlign.right,
                    style: AppFonts.cairo(
                      fontSize: 12,
                      color: AppColors.rejected,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _loading ? null : _savePhone,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.canvas,
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
                              color: AppColors.canvas,
                            ),
                          )
                        : Text(
                            strings.save,
                            style: AppFonts.cairo(
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
