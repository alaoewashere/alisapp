import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/dicebear_avatars.dart';

bool _isFlutterTest() {
  if (kIsWeb) return false;
  return Platform.environment.containsKey('FLUTTER_TEST');
}

/// Single selectable DiceBear glyphs avatar tile.
class DiceBearAvatarCell extends StatelessWidget {
  const DiceBearAvatarCell({
    super.key,
    required this.seed,
    required this.selected,
    required this.onTap,
    this.size = 64,
    this.showCheckBadge = false,
  });

  final String seed;
  final bool selected;
  final VoidCallback onTap;
  final double size;
  final bool showCheckBadge;

  static const _placeholderFill = Color(0xFFE8F5EE);

  @override
  Widget build(BuildContext context) {
    final cell = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: ClipOval(
          child: _isFlutterTest()
              ? _TestSeedAvatar(seed: seed, size: size)
              : SvgPicture.network(
                  DiceBearAvatars.urlFor(seed),
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  placeholderBuilder: (_) => Container(
                    width: size,
                    height: size,
                    color: _placeholderFill,
                    child: const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  errorBuilder: (_, _, _) =>
                      _TestSeedAvatar(seed: seed, size: size),
                ),
        ),
      ),
    );

    if (!showCheckBadge || !selected) return cell;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        cell,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 12),
          ),
        ),
      ],
    );
  }
}

/// Large DiceBear preview or placeholder when no seed is chosen.
class DiceBearAvatarPreview extends StatelessWidget {
  const DiceBearAvatarPreview({
    super.key,
    required this.seed,
    this.size = 90,
  });

  final String? seed;
  final double size;

  static const _placeholderFill = Color(0xFFE8F5EE);

  @override
  Widget build(BuildContext context) {
    final resolved = seed != null && seed!.trim().isNotEmpty
        ? DiceBearAvatars.resolveSeed(seed)
        : null;

    if (resolved == null) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: _placeholderFill,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person, color: AppColors.primary, size: size * 0.49),
      );
    }

    return ClipOval(
      child: _isFlutterTest()
          ? _TestSeedAvatar(seed: resolved, size: size)
          : SvgPicture.network(
              DiceBearAvatars.urlFor(resolved),
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholderBuilder: (_) => Container(
                width: size,
                height: size,
                color: _placeholderFill,
                child: Center(
                  child: SizedBox(
                    width: size * 0.28,
                    height: size * 0.28,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              errorBuilder: (_, _, _) =>
                  _TestSeedAvatar(seed: resolved, size: size),
            ),
    );
  }
}

class _TestSeedAvatar extends StatelessWidget {
  const _TestSeedAvatar({required this.seed, required this.size});

  final String seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: DiceBearAvatarCell._placeholderFill,
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
