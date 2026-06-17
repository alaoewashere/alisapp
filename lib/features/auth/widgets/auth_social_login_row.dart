import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';

class AuthSocialLoginRow extends StatelessWidget {
  const AuthSocialLoginRow({
    super.key,
    required this.onGooglePressed,
    this.googleLoading = false,
    this.onApplePressed,
    this.appleLoading = false,
    this.onFacebookPressed,
    this.onPhonePressed,
  });

  final VoidCallback? onGooglePressed;
  final bool googleLoading;
  final VoidCallback? onApplePressed;
  final bool appleLoading;
  final VoidCallback? onFacebookPressed;
  final VoidCallback? onPhonePressed;

  static const _iconSize = 52.0;
  static const _gap = 16.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialIconButton(
          assetPath: 'assets/icons/google.svg',
          loading: googleLoading,
          onPressed: onGooglePressed,
        ),
        const SizedBox(width: _gap),
        _SocialIconButton(
          assetPath: 'assets/icons/apple.svg',
          loading: appleLoading,
          onPressed: onApplePressed,
        ),
        const SizedBox(width: _gap),
        _SocialIconButton(
          assetPath: 'assets/icons/facebook.svg',
          onPressed: onFacebookPressed,
        ),
        const SizedBox(width: _gap),
        _PhoneIconButton(onPressed: onPhonePressed),
      ],
    );
  }
}

class _PhoneIconButton extends StatelessWidget {
  const _PhoneIconButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return _SocialCircleButton(
      onPressed: onPressed,
      child: const Icon(
        Icons.phone_outlined,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.assetPath,
    required this.onPressed,
    this.loading = false,
  });

  final String assetPath;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return _SocialCircleButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.pureWhite,
              ),
            )
          : SvgPicture.asset(
              assetPath,
              width: 24,
              height: 24,
            ),
    );
  }
}

class _SocialCircleButton extends StatelessWidget {
  const _SocialCircleButton({
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fieldCarbon,
      shape: CircleBorder(
        side: BorderSide(color: AppColors.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: AuthSocialLoginRow._iconSize,
          height: AuthSocialLoginRow._iconSize,
          child: Center(child: child),
        ),
      ),
    );
  }
}
