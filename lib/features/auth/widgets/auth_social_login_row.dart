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
    this.facebookLoading = false,
    this.onPhonePressed,
    this.showPhone = true,
  });

  final VoidCallback? onGooglePressed;
  final bool googleLoading;
  final VoidCallback? onApplePressed;
  final bool appleLoading;
  final VoidCallback? onFacebookPressed;
  final bool facebookLoading;
  final VoidCallback? onPhonePressed;
  final bool showPhone;

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
        // Sign in with Apple — Apple's HIG "white" appearance (black logo on a
        // white button) so it's clearly a tappable button on the dark theme.
        _SocialIconButton(
          assetPath: 'assets/icons/apple.svg',
          loading: appleLoading,
          onPressed: onApplePressed,
          backgroundColor: AppColors.pureWhite,
          iconColor: Colors.black,
        ),
        const SizedBox(width: _gap),
        _SocialIconButton(
          assetPath: 'assets/icons/facebook.svg',
          loading: facebookLoading,
          onPressed: onFacebookPressed,
        ),
        if (showPhone) ...[
          const SizedBox(width: _gap),
          _PhoneIconButton(onPressed: onPhonePressed),
        ],
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
    this.backgroundColor,
    this.iconColor,
  });

  final String assetPath;
  final VoidCallback? onPressed;
  final bool loading;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return _SocialCircleButton(
      onPressed: loading ? null : onPressed,
      backgroundColor: backgroundColor,
      child: loading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: iconColor ?? AppColors.pureWhite,
              ),
            )
          : SvgPicture.asset(
              assetPath,
              width: 24,
              height: 24,
              colorFilter: iconColor != null
                  ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                  : null,
            ),
    );
  }
}

class _SocialCircleButton extends StatelessWidget {
  const _SocialCircleButton({
    required this.onPressed,
    required this.child,
    this.backgroundColor,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppColors.fieldCarbon,
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
