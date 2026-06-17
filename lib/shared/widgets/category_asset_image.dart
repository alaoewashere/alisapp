import 'package:flutter/material.dart';

/// Loads a local category PNG with a light plate and visible fallback on failure.
class CategoryAssetImage extends StatelessWidget {
  const CategoryAssetImage({
    super.key,
    required this.assetPath,
    required this.size,
    this.fallback,
    this.showPlate = true,
  });

  final String assetPath;
  final double size;
  final Widget? fallback;
  final bool showPlate;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        return fallback ??
            Icon(
              Icons.category_outlined,
              size: size * 0.62,
              color: Colors.grey.shade600,
            );
      },
    );

    if (!showPlate) return image;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(size * 0.1),
        child: image,
      ),
    );
  }
}
