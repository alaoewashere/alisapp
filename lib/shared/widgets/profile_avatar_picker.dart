import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/preset_avatars.dart';

/// Avatar picker — large preview + horizontal preset row (edit profile).
class ProfileAvatarPicker extends StatelessWidget {
  const ProfileAvatarPicker({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
    this.uploadedFile,
    this.uploadedUrl,
    this.showPresetSelection = true,
    this.onPreviewTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;
  final File? uploadedFile;
  final String? uploadedUrl;
  final bool showPresetSelection;
  final VoidCallback? onPreviewTap;

  static const _previewSize = 80.0;
  static const _optionSize = 56.0;

  @override
  Widget build(BuildContext context) {
    final index = PresetAvatars.clampIndex(selectedIndex);

    return Column(
      children: [
        GestureDetector(
          onTap: onPreviewTap,
          child: _PreviewAvatar(
            size: _previewSize,
            uploadedFile: uploadedFile,
            uploadedUrl: showPresetSelection ? null : uploadedUrl,
            presetColor: PresetAvatars.colorAt(index),
            usePreset: showPresetSelection || uploadedFile == null && uploadedUrl == null,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'اختر صورتك',
          style: AppFonts.cairo(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        _SectionDivider(label: 'الصور الرمزية'),
        const SizedBox(height: 12),
        SizedBox(
          height: _optionSize + 4,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < PresetAvatars.colors.length; i++)
                  Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 12),
                    child: _PresetAvatarOption(
                      index: i,
                      size: _optionSize,
                      selected: showPresetSelection && i == index,
                      onTap: () => onSelectIndex(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: AppFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borderLight)),
      ],
    );
  }
}

class _PreviewAvatar extends StatelessWidget {
  const _PreviewAvatar({
    required this.size,
    required this.presetColor,
    required this.usePreset,
    this.uploadedFile,
    this.uploadedUrl,
  });

  final double size;
  final Color presetColor;
  final bool usePreset;
  final File? uploadedFile;
  final String? uploadedUrl;

  @override
  Widget build(BuildContext context) {
    if (uploadedFile != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(uploadedFile!),
      );
    }

    if (!usePreset && uploadedUrl != null && uploadedUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: CachedNetworkImageProvider(uploadedUrl!),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: presetColor,
      child: Icon(Icons.person, size: size * 0.45, color: Colors.white),
    );
  }
}

class _PresetAvatarOption extends StatelessWidget {
  const _PresetAvatarOption({
    required this.index,
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? PresetAvatars.selectedBorder
                : PresetAvatars.unselectedBorder,
            width: selected ? 2.5 : 1.5,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: PresetAvatars.colorAt(index),
          child: Icon(Icons.person, size: size * 0.4, color: Colors.white),
        ),
      ),
    );
  }
}
