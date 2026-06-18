import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/dicebear_avatars.dart';

bool _isFlutterTest() {
  if (kIsWeb) return false;
  return Platform.environment.containsKey('FLUTTER_TEST');
}

/// Illustrated DiceBear avatar for any user surface.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.avatarSeed,
    this.size = 48,
    this.darkStyle = false,
  });

  final String? avatarSeed;
  final double size;
  final bool darkStyle;

  @override
  Widget build(BuildContext context) {
    if (_isFlutterTest()) {
      return _SeedPlaceholder(
        seed: DiceBearAvatars.resolveSeed(avatarSeed),
        size: size,
        darkStyle: darkStyle,
      );
    }

    final seed = DiceBearAvatars.resolveSeed(avatarSeed);
    final url = DiceBearAvatars.urlFor(seed);

    return ClipOval(
      child: SvgPicture.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholderBuilder: (_) =>
            _Fallback(size: size, loading: true, darkStyle: darkStyle),
        errorBuilder: (_, _, _) => _Fallback(size: size, darkStyle: darkStyle),
      ),
    );
  }
}

class _SeedPlaceholder extends StatelessWidget {
  const _SeedPlaceholder({
    required this.seed,
    required this.size,
    this.darkStyle = false,
  });

  final String seed;
  final double size;
  final bool darkStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: darkStyle ? AppColors.fieldCarbon : const Color(0xFFE8F5EE),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: darkStyle
          ? Icon(Icons.person, color: AppColors.pureWhite, size: size * 0.45)
          : Text(
              seed.isNotEmpty ? seed[0].toUpperCase() : '?',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.35,
              ),
            ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({
    required this.size,
    this.loading = false,
    this.darkStyle = false,
  });

  final double size;
  final bool loading;
  final bool darkStyle;

  @override
  Widget build(BuildContext context) {
    final background =
        darkStyle ? AppColors.fieldCarbon : (loading ? Colors.grey.shade200 : AppColors.primary);

    return Container(
      width: size,
      height: size,
      color: background,
      alignment: Alignment.center,
      child: loading
          ? SizedBox(
              width: size * 0.35,
              height: size * 0.35,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: darkStyle ? AppColors.pureWhite : AppColors.primary,
              ),
            )
          : Icon(
              Icons.person,
              color: AppColors.pureWhite,
              size: size * 0.5,
            ),
    );
  }
}
