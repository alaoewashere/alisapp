import 'package:flutter/material.dart';

/// Preset illustrated avatars for profile setup (no custom photo required).
class DefaultAvatar {
  const DefaultAvatar({
    required this.id,
    required this.labelAr,
    required this.emoji,
    required this.gradient,
    required this.ringColor,
  });

  final String id;
  final String labelAr;
  final String emoji;
  final List<Color> gradient;
  final Color ringColor;
}

/// Bundled default avatar presets matching souqly-redesign-studio style.
const defaultAvatars = <DefaultAvatar>[
  DefaultAvatar(
    id: 'male_casual',
    labelAr: 'شاب عادي',
    emoji: '🧔🏻',
    gradient: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    ringColor: Color(0xFF00897B),
  ),
  DefaultAvatar(
    id: 'male_tech',
    labelAr: 'شاب تقني',
    emoji: '👨🏻‍💻',
    gradient: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
    ringColor: Color(0xFF005F54),
  ),
  DefaultAvatar(
    id: 'female_casual',
    labelAr: 'شابة عادية',
    emoji: '👩🏻',
    gradient: [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
    ringColor: Color(0xFF00897B),
  ),
  DefaultAvatar(
    id: 'female_tech',
    labelAr: 'شابة تقنية',
    emoji: '👩🏻‍💼',
    gradient: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
    ringColor: Color(0xFF005F54),
  ),
  DefaultAvatar(
    id: 'young_male',
    labelAr: 'شاب',
    emoji: '👱🏻‍♂️',
    gradient: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    ringColor: Color(0xFF00897B),
  ),
  DefaultAvatar(
    id: 'young_female',
    labelAr: 'شابة',
    emoji: '👧🏻',
    gradient: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
    ringColor: Color(0xFF00897B),
  ),
];

DefaultAvatar? defaultAvatarById(String? id) {
  if (id == null) return null;
  for (final avatar in defaultAvatars) {
    if (avatar.id == id) return avatar;
  }
  return null;
}
