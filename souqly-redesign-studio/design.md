# Sello Premium Redesign System
> **Flutter Architecture & High-Fidelity UI Design System**

This blueprint contains a comprehensive design system, color palettes, folder structures, and high-fidelity reusable Dart widgets to completely overhaul your current Flutter marketplace app (**Sello**) into a world-class, premium mobile experience.

---

## 🎨 Creative Design Directions

You can choose one of the three tailored high-end aesthetic themes below for your refactoring.

### 1. Eco-Lux Traditional (الرقي البيئي المعاصر) - *Recommended*
An upscale, premium evolution of your current green and sandy sand theme. It keeps your identity but gives it a luxury "Apple Store" clean catalog feel.
*   **Backgrounds**: Soft Warm Sand (`0xFFFAF9F6`), Matte Card White (`0xFFFFFFFF`)
*   **Primary Active**: Deep Forest Green (`0xFF1B4332`), Emerald Pop (`0xFF2D6A4F`)
*   **Neutral Text**: Rich Charcoal (`0xFF22252A`), Muted Pebble (`0xFF7F8A96`)
*   **Accents**: Warm Gold/Ivory Highlights (`0xFFE9E5D9`)
*   **Depth**: Incredibly soft blur-shadows, razor-thin card borders (1px with `0x08000000` opacity).

### 2. Tech Bento Midnight (النظام الداكن التقني)
A modern dark mode for high-tech marketplaces, structured around dynamic grid blocks (Bento layouts) and glowing neon accents.
*   **Backgrounds**: Pitch Dark Slate (`0xFF0B0D0F`), Block Dark (`0xFF12161A`)
*   **Primary Active**: Neon Emerald (`0xFF00E676`), Cyber Teal (`0xFF00B0FF`)
*   **Neutral Text**: Alabaster White (`0xFFF5F6F7`), Muted Gray (`0xFF6F7C85`)
*   **Accents**: Glowing Glass Gradients

### 3. Cupertino-Glass Premium (البساطة الكوبرتينية الفاخرة)
Incredibly slick, fluid layout using glassmorphism overlays, iOS-style fine typography, and high-quality micro-elastic physics.
*   **Backgrounds**: Soft Pearl Gray (`0xFFF3F4F6`), Frozen Ice Card (`0x99FFFFFF` with blur)
*   **Primary Active**: Royal Pine Green (`0xFF004D40`), Sky Opal (`0xFF00897B`)
*   **Neutral Text**: Charcoal Onyx (`0xFF1C1C1E`), Muted Smoke (`0xFF8E8E93`)

---

## 🏗️ Reorganized Flutter App Architecture

To prevent code clutter, maintain clean separation of concerns, and make future modifications with Cursor effortless, implement this split directory tree:

```text
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart       # All Hex Color constants
│   │   ├── app_theme.dart        # Light/Dark ThemeData configurations
│   │   └── app_typography.dart   # Global TextStyle pairings (Cairo / Readex Pro)
│   └── values/
│       └── app_constants.dart    # Edge paddings, corner radii, animations
├── widgets/                      # Shared reusable UI elements
│   ├── custom_card.dart          # Bento-styled marketplace card
│   ├── bottom_nav_bar.dart       # Floating glass bottom navigation
│   └── search_bar.dart           # Animated hero search bar
└── screens/                      # Screen layouts matching your images
    ├── auth/
    │   └── login_screen.dart     # Polished OTP & Login page
    ├── home/
    │   ├── home_screen.dart      # Main grid explore page
    │   └── widgets/
    ├── categories/
    │   ├── categories_screen.dart # Category list and subdirectories tree
    │   └── widgets/
    ├── chats/
    │   ├── chat_list_screen.dart # Conversations list with status indicators
    │   └── chat_room_screen.dart # Fully styled instant chat
    └── profile/
        ├── profile_screen.dart   # Profile dashboard with user metrics
        └── edit_profile_screen.dart # Profile edit form field elements
```

---

## 🎛️ Premium Reusable Dart Widgets

Paste these foundational components into your project directory as described below.

### 1. Color System Constants (`lib/core/theme/app_colors.dart`)
```dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand Color Palette (Eco-Lux)
  static const Color background = Color(0xFFFAF9F6);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF1B4332);
  static const Color primaryAccent = Color(0xFF40916C);
  static const Color textDark = Color(0xFF1C1E21);
  static const Color textMuted = Color(0xFF7A828A);
  static const Color borderLight = Color(0xFFEEEEEE);
  
  // Status Colors
  static const Color heartAccent = Color(0xFFE63946);
  static const Color pendingBg = Color(0xFFFFF3CD);
  static const Color pendingText = Color(0xFF856404);
  
  // Theme gradients
  static const Gradient premiumGreenGrad = LinearGradient(
    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

### 2. Double-Column Product Card Widget (`lib/widgets/custom_card.dart`)
```dart
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class SouqlyProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String location;
  final String dateText;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;

  const SouqlyProductCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.location,
    required this.dateText,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Stack
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) => Container(
                      color: AppColors.borderLight,
                      child: const Icon(Icons.broken_image, color: AppColors.textMuted),
                    ),
                  ),
                  // Floating Favorite Button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFavorite ? AppColors.heartAccent : AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Text Details Card Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        dateText,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Floating Glass Bottom Navigation (`lib/widgets/bottom_nav_bar.dart`)
```dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../core/theme/app_colors.dart';

class FloatingGlassNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingGlassNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, "الرئيسية"),
            _buildNavItem(1, Icons.search_rounded, "البحث"),
            _buildCenterAddButton(),
            _buildNavItem(3, Icons.chat_bubble_outline_rounded, "الدردشة"),
            _buildNavItem(4, Icons.person_outline_rounded, "حسابي"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textMuted,
            size: isSelected ? 26 : 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterAddButton() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        height: 52,
        width: 52,
        decoration: const BoxDecoration(
          gradient: AppColors.premiumGreenGrad,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x601B4332),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
```

---

## 🎯 Steps to Apply This Overhaul in Cursor

1.  **Create Global Files**: Paste `app_colors.dart` and `custom_card.dart` inside your project under `lib/`.
2.  **Install Font**:
    Add the `Cairo` and `Readex Pro` Arabic fonts from Google Fonts into your `pubspec.yaml`:
    ```yaml
    flutter:
      fonts:
        - family: Cairo
          fonts:
            - asset: assets/fonts/Cairo-Regular.ttf
            - asset: assets/fonts/Cairo-Bold.ttf
              weight: 700
    ```
3.  **Refactor Screens via Prompt**: Use the tailored Redesign Prompt from the Redesign Generator App below to let Cursor rebuild your layouts screen-by-screen.

---
*Created especially for your marketplace app **Sello**.*
