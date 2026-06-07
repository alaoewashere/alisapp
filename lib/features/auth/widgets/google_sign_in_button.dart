import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/l10n/l10n_provider.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/google.svg',
                      width: 22,
                      height: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.l10n.signInWithGoogle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
