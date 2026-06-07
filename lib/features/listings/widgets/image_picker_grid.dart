import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderables/reorderables.dart';

/// Reusable photo grid with add, remove, and drag-to-reorder.
class ImagePickerGrid extends StatelessWidget {
  const ImagePickerGrid({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onRemove,
    required this.onReorder,
    required this.maxImages,
  });

  final List<File> images;
  final Future<void> Function(File file) onAdd;
  final void Function(int index) onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;
  final int maxImages;

  Future<void> _pickSource(BuildContext context, ImageSource source) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    XFile? picked;
    if (source == ImageSource.camera) {
      picked = await picker.pickImage(source: ImageSource.camera);
    } else {
      if (images.length >= maxImages) return;
      final remaining = maxImages - images.length;
      final multi = await picker.pickMultiImage();
      for (var i = 0; i < multi.length && i < remaining; i++) {
        await onAdd(File(multi[i].path));
      }
      return;
    }
    if (picked != null) {
      await onAdd(File(picked.path));
    }
  }

  void _showSourcePicker(BuildContext context) {
    if (images.length >= maxImages) return;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('الكاميرا'),
              onTap: () => _pickSource(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('معرض الصور'),
              onTap: () => _pickSource(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slots = <Widget>[];

    if (images.length < maxImages) {
      slots.add(
        _AddSlot(
          key: const ValueKey('add_slot'),
          onTap: () => _showSourcePicker(context),
        ),
      );
    }

    for (var i = 0; i < images.length; i++) {
      slots.add(
        _ImageSlot(
          key: ValueKey(images[i].path),
          file: images[i],
          isPrimary: i == 0,
          onRemove: () => onRemove(i),
        ),
      );
    }

    return ReorderableWrap(
      spacing: 8,
      runSpacing: 8,
      onReorder: (oldIndex, newIndex) {
        final addSlotOffset = images.length < maxImages ? 1 : 0;
        final oldImageIndex = oldIndex - addSlotOffset;
        var newImageIndex = newIndex - addSlotOffset;
        if (oldImageIndex < 0 || oldImageIndex >= images.length) return;
        if (newImageIndex < 0) newImageIndex = 0;
        if (newImageIndex >= images.length) {
          newImageIndex = images.length - 1;
        }
        onReorder(oldImageIndex, newImageIndex);
      },
      needsLongPressDraggable: true,
      children: slots,
    );
  }
}

class _AddSlot extends StatelessWidget {
  const _AddSlot({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}

class _ImageSlot extends StatelessWidget {
  const _ImageSlot({
    super.key,
    required this.file,
    required this.isPrimary,
    required this.onRemove,
  });

  final File file;
  final bool isPrimary;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(file, fit: BoxFit.cover),
          ),
          if (isPrimary)
            Positioned(
              bottom: 4,
              right: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'الصورة الرئيسية',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),
            ),
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              icon: const Icon(Icons.close, size: 18, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }
}
