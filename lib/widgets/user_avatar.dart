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
  });

  final String? avatarSeed;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (_isFlutterTest()) {
      return _SeedPlaceholder(seed: DiceBearAvatars.resolveSeed(avatarSeed), size: size);
    }

    final seed = DiceBearAvatars.resolveSeed(avatarSeed);
    final url = DiceBearAvatars.urlFor(seed);

    return ClipOval(
      child: SvgPicture.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => _Fallback(size: size, loading: true),
        errorBuilder: (_, _, _) => _Fallback(size: size),
      ),
    );
  }
}

class _SeedPlaceholder extends StatelessWidget {
  const _SeedPlaceholder({required this.seed, required this.size});

  final String seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5EE),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
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
  const _Fallback({required this.size, this.loading = false});

  final double size;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: loading ? Colors.grey.shade200 : AppColors.primary,
      alignment: Alignment.center,
      child: loading
          ? SizedBox(
              width: size * 0.35,
              height: size * 0.35,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : Icon(Icons.person, color: Colors.white, size: size * 0.5),
    );
  }
}
