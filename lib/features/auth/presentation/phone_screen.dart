import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/digit_input_formatter.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/google_sign_in_button.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final country = ref.watch(_selectedCountryProvider);
    final localDigits = ref.watch(_phoneDigitsProvider);
    final isoCode = country.code ?? 'IQ';
    final isValid = Validators.localPhone(localDigits, isoCode) == null;
    final googleLoading = ref.watch(isGoogleSignInLoadingProvider);
    final phoneLoading =
        auth.status == AuthFlowStatus.loading && auth.phone != null;

    final strings = ref.watch(appLocalizationsProvider);

    ref.listen(authNotifierProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage &&
          next.phone == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }

      if (next.status == AuthFlowStatus.otpSent &&
          next.phone != null &&
          prev?.status != AuthFlowStatus.otpSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.otpSent)),
        );
        context.go(
          '${AppRoutes.otp}?phone=${Uri.encodeComponent(next.phone!)}',
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.storefront_rounded,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                strings.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 48),
              Text(
                strings.enterPhone,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _CountryPickerButton(
                        country: country,
                        onChanged: (code) {
                          final current = ref.read(_selectedCountryProvider);
                          if (current.code == code.code) return;

                          ref.read(_selectedCountryProvider.notifier).set(code);
                          ref.read(_phoneDigitsProvider.notifier).set('');
                          _phoneController.clear();
                        },
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: TextField(
                            key: ValueKey(isoCode),
                            controller: _phoneController,
                            autofocus: true,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              WesternDigitsInputFormatter(
                                maxLength: Validators.maxLocalDigits(isoCode),
                              ),
                            ],
                            decoration: const InputDecoration(
                              hintText: '7901234567',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            onChanged: (value) {
                              final normalized = Validators.normalizeLocalDigits(
                                value,
                                isoCode,
                              );
                              if (normalized != value) {
                                _phoneController.value = TextEditingValue(
                                  text: normalized,
                                  selection: TextSelection.collapsed(
                                    offset: normalized.length,
                                  ),
                                );
                              }
                              ref
                                  .read(_phoneDigitsProvider.notifier)
                                  .set(normalized);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _hintForCountry(isoCode, country.dialCode ?? '+964'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: strings.sendOtp,
                loading: phoneLoading,
                onPressed: isValid && !googleLoading
                    ? () async {
                        final fullPhone = Validators.formatE164(
                          country.dialCode ?? '+964',
                          localDigits,
                        );
                        final result = await ref
                            .read(authNotifierProvider.notifier)
                            .sendOTP(fullPhone);

                        if (!context.mounted) return;

                        switch (result) {
                          case Success():
                            break;
                          case Failure(:final message):
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                        }
                      }
                    : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      strings.orDivider,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ),
                  Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
                ],
              ),
              const SizedBox(height: 24),
              GoogleSignInButton(
                loading: googleLoading,
                onPressed: phoneLoading
                    ? null
                    : () => ref
                        .read(authNotifierProvider.notifier)
                        .signInWithGoogle(),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: (phoneLoading || googleLoading)
                    ? null
                    : () {
                        ref.read(authNotifierProvider.notifier).enterGuestMode();
                        context.go(AppRoutes.home);
                      },
                child: Text(
                  '${strings.browseAsGuest} →',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  String _hintForCountry(String isoCode, String dialCode) {
    return switch (isoCode) {
      'IQ' => 'مثال: ${dialCode}7901234567 (بدون صفر في البداية)',
      'US' || 'CA' => 'مثال: ${dialCode}5551234567',
      _ => 'أدخل رقم الهاتف بدون رمز الدولة',
    };
  }
}

class _CountryPickerButton extends StatelessWidget {
  const _CountryPickerButton({
    required this.country,
    required this.onChanged,
  });

  final CountryCode country;
  final ValueChanged<CountryCode> onChanged;

  @override
  Widget build(BuildContext context) {
    return CountryCodePicker(
      onChanged: onChanged,
      initialSelection: country.code ?? 'IQ',
      favorite: const ['+964', 'IQ'],
      pickerStyle: PickerStyle.bottomSheet,
      showCountryOnly: false,
      showOnlyCountryWhenClosed: false,
      showFlag: true,
      showDropDownButton: false,
      hideHeaderText: true,
      alignLeft: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      searchDecoration: const InputDecoration(
        hintText: 'ابحث عن دولة...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      builder: (selected) {
        final item = selected ?? country;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.flagUri != null)
                Image.asset(
                  item.flagUri!,
                  package: 'country_code_picker',
                  width: 28,
                  height: 20,
                  fit: BoxFit.cover,
                ),
              const SizedBox(width: 8),
              Text(
                item.dialCode ?? '+964',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectedCountryNotifier extends Notifier<CountryCode> {
  @override
  CountryCode build() => CountryCode.fromCountryCode('IQ');

  void set(CountryCode country) => state = country;
}

final _selectedCountryProvider =
    NotifierProvider<_SelectedCountryNotifier, CountryCode>(
  _SelectedCountryNotifier.new,
);

class _PhoneDigitsNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final _phoneDigitsProvider =
    NotifierProvider<_PhoneDigitsNotifier, String>(_PhoneDigitsNotifier.new);
