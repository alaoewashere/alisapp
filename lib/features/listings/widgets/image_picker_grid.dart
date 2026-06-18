import 'dart:io';

import 'package:flutter/material.dart';
import 'package:Sello/core/theme/app_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderables/reorderables.dart';

import '../../../core/constants/app_colors.dart';

/// Modern 3-column photo grid for listing create/edit flows.
class ImagePickerGrid extends StatelessWidget {
  const ImagePickerGrid({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onAddBatch,
    required this.onRemove,
    required this.onReorder,
    required this.maxImages,
    this.onLimitReached,
  });

  final List<File> images;
  final Future<void> Function(File file) onAdd;
  final Future<void> Function(List<File> files) onAddBatch;
  final void Function(int index) onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;
  final int maxImages;
  final VoidCallback? onLimitReached;

  Future<void> _pickMultiple(BuildContext context) async {
    if (images.length >= maxImages) {
      onLimitReached?.call();
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;

    final remaining = maxImages - images.length;
    final files = picked.take(remaining).map((x) => File(x.path)).toList();

    if (picked.length > remaining) {
      onLimitReached?.call();
    }

    if (files.length == 1) {
      await onAdd(files.first);
    } else if (files.isNotEmpty) {
      await onAddBatch(files);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 16.0;
        const spacing = 8.0;
        final width = constraints.maxWidth;
        final cellSize = (width - horizontalPadding * 2 - spacing * 2) / 3;

        final slots = <Widget>[];

        if (images.length < maxImages) {
          slots.add(
            _AddPhotoCell(
              key: const ValueKey('listing_photo_add'),
              size: cellSize,
              onTap: () => _pickMultiple(context),
            ),
          );
        }

        for (var i = 0; i < images.length; i++) {
          slots.add(
            _PhotoCell(
              key: ValueKey('listing_photo_${images[i].path}_$i'),
              file: images[i],
              size: cellSize,
              isCover: i == 0,
              onRemove: () => onRemove(i),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: ReorderableWrap(
            spacing: spacing,
            runSpacing: spacing,
            needsLongPressDraggable: true,
            buildDraggableFeedback: (context, constraints, child) {
              return Material(
                elevation: 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                child: Transform.scale(scale: 1.05, child: child),
              );
            },
            onReorder: (oldIndex, newIndex) {
              final addOffset = images.length < maxImages ? 1 : 0;
              final oldImageIndex = oldIndex - addOffset;
              var newImageIndex = newIndex - addOffset;
              if (oldImageIndex < 0 || oldImageIndex >= images.length) return;
              if (newImageIndex < 0) newImageIndex = 0;
              if (newImageIndex >= images.length) {
                newImageIndex = images.length - 1;
              }
              onReorder(oldImageIndex, newImageIndex);
            },
            children: slots,
          ),
        );
      },
    );
  }
}

class _AddPhotoCell extends StatelessWidget {
  const _AddPhotoCell({
    super.key,
    required this.size,
    required this.onTap,
  });

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: AppColors.primary,
            radius: 12,
            strokeWidth: 1.5,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.fieldCarbon,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.volt,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.canvas,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'إضافة صورة',
                  style: AppFonts.sans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.volt,
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

class _PhotoCell extends StatelessWidget {
  const _PhotoCell({
    super.key,
    required this.file,
    required this.size,
    required this.isCover,
    required this.onRemove,
  });

  final File file;
  final double size;
  final bool isCover;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.file(file, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 6,
            left: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.rejected,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
          if (isCover)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.62),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'الغلاف',
                  style: AppFonts.sans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pureWhite,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          next.clamp(0, metric.length),
        );
        canvas.drawPath(extractPath, paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
