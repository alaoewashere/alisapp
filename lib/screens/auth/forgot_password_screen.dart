import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/result.dart';
import '../../core/utils/validators.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/widgets/auth_form_styles.dart';

enum _RecoveryMethod { email, phone }

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  static const _titleColor = Color(0xFF111111);
  static const _instructionColor = Color(0xFF555555);

  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  _RecoveryMethod _selectedMethod = _RecoveryMethod.email;
  late final TextEditingController _emailController;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _onSendPressed() async {
    if (_selectedMethod == _RecoveryMethod.email) {
      final email = _emailController.text.trim();
      final emailError = Validators.email(email);
      if (emailError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(emailError)),
        );
        return;
      }

      setState(() => _sending = true);
      final result = await ref
          .read(authNotifierProvider.notifier)
          .resetPasswordForEmail(email);
      if (!mounted) return;
      setState(() => _sending = false);

      switch (result) {
        case Success():
          context.push(
            '${AppRoutes.emailVerify}?email=${Uri.encodeComponent(email)}',
          );
        case Failure(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إرسال رمز التحقق',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.login);
              }
            },
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: _titleColor,
              size: 20,
            ),
          ),
          title: Text(
            'نسيت كلمة المرور؟',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _titleColor,
            ),
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: Image.asset(
                      'assets/images/forgot_password.jpg',
                      width: 260,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'أدخل بريدك الإلكتروني لاستقبال رمز التحقق',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        height: 1.5,
                        color: _instructionColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _RecoveryOptionCard(
                          selected: _selectedMethod == _RecoveryMethod.email,
                          icon: Icons.email_outlined,
                          label: 'متابعة عبر البريد الإلكتروني',
                          sublabel: 'بريدك المرتبط بالحساب',
                          onTap: () {
                            setState(() => _selectedMethod = _RecoveryMethod.email);
                          },
                        ),
                        const SizedBox(height: 12),
                        _RecoveryOptionCard(
                          selected: _selectedMethod == _RecoveryMethod.phone,
                          icon: Icons.phone_outlined,
                          label: 'متابعة عبر الهاتف',
                          sublabel: 'هاتفك المرتبط بالحساب',
                          onTap: () {
                            setState(() => _selectedMethod = _RecoveryMethod.phone);
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_selectedMethod == _RecoveryMethod.email) ...[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AuthPillField(
                        label: 'البريد الإلكتروني',
                        controller: _emailController,
                        hintText: 'example@email.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                  const SizedBox(height: 36),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      height: 54,
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _sending ? null : _onSendPressed,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: _sending
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('إرسال'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecoveryOptionCard extends StatefulWidget {
  const _RecoveryOptionCard({
    required this.selected,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  @override
  State<_RecoveryOptionCard> createState() => _RecoveryOptionCardState();
}

class _RecoveryOptionCardState extends State<_RecoveryOptionCard> {
  static const _cardBorderUnselected = Color(0xFFE0E0E0);
  static const _cardFillSelected = Color(0xFFF0FAF4);
  static const _iconCircleBg = Color(0xFFE8F5EE);
  static const _titleColor = Color(0xFF111111);
  static const _sublabelColor = Color(0xFF888888);

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Material(
          color: widget.selected ? _cardFillSelected : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: widget.selected ? AppColors.primary : _cardBorderUnselected,
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 68,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: _iconCircleBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _titleColor,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          widget.sublabel,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: _sublabelColor,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _RecoveryRadio(selected: widget.selected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecoveryRadio extends StatelessWidget {
  const _RecoveryRadio({required this.selected});

  final bool selected;

  static const _radioOutline = Color(0xFFCCCCCC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.primary : _radioOutline,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
