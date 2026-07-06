import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/l10n_provider.dart';
import '../../core/theme/app_fonts.dart';

enum FeatureTutorialBubblePosition { below, above }

enum FeatureTutorialHighlightShape { circle, roundedRect }

/// Reusable dim + spotlight coachmark with Arabic tooltip bubble.
class FeatureTutorialOverlay extends StatefulWidget {
  const FeatureTutorialOverlay({
    super.key,
    required this.targetKey,
    required this.onDismiss,
    required this.title,
    this.subtitle,
    this.bubblePosition = FeatureTutorialBubblePosition.below,
    this.highlightShape = FeatureTutorialHighlightShape.circle,
    this.holePadding = 6,
  });

  final GlobalKey targetKey;
  final VoidCallback onDismiss;
  final String title;
  final String? subtitle;
  final FeatureTutorialBubblePosition bubblePosition;
  final FeatureTutorialHighlightShape highlightShape;
  final double holePadding;

  @override
  State<FeatureTutorialOverlay> createState() => _FeatureTutorialOverlayState();
}

class _FeatureTutorialOverlayState extends State<FeatureTutorialOverlay> {
  static const _dimColor = Color(0xB8000000);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Rect? _targetRect() {
    final box =
        widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final globalTopLeft = box.localToGlobal(Offset.zero);
    // Convert to local coords of this overlay (which fills the Stack)
    final overlayBox = context.findRenderObject();
    if (overlayBox is RenderBox) {
      final localTopLeft = overlayBox.globalToLocal(globalTopLeft);
      return localTopLeft & box.size;
    }
    return globalTopLeft & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final hole = _targetRect();
    if (hole == null) return const SizedBox.shrink();

    final expanded = Rect.fromLTRB(
      hole.left - widget.holePadding,
      hole.top - widget.holePadding,
      hole.right + widget.holePadding,
      hole.bottom + widget.holePadding,
    );
    final screen = MediaQuery.sizeOf(context);

    final bubble = _TutorialBubble(
      title: widget.title,
      subtitle: widget.subtitle,
      onDismiss: widget.onDismiss,
    );

    return Stack(
      children: [
        ..._dimPanels(screen, expanded, widget.onDismiss),
        Positioned.fromRect(
          rect: expanded,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: widget.highlightShape ==
                      FeatureTutorialHighlightShape.circle
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.volt.withValues(alpha: 0.85),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.volt.withValues(alpha: 0.35),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    )
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.volt.withValues(alpha: 0.85),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.volt.withValues(alpha: 0.35),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (widget.bubblePosition == FeatureTutorialBubblePosition.below)
          Positioned(
            top: expanded.bottom + 14,
            left: 16,
            right: 16,
            child: bubble,
          )
        else
          Positioned(
            bottom: screen.height - expanded.top + 14,
            left: 16,
            right: 16,
            child: bubble,
          ),
      ],
    );
  }

  List<Widget> _dimPanels(Size screen, Rect hole, VoidCallback onDismiss) {
    Widget panel({
      required double top,
      required double left,
      required double width,
      required double height,
    }) {
      return Positioned(
        top: top,
        left: left,
        width: width,
        height: math.max(0, height),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onDismiss,
          child: const ColoredBox(color: _dimColor),
        ),
      );
    }

    return [
      panel(top: 0, left: 0, width: screen.width, height: hole.top),
      panel(
        top: hole.bottom,
        left: 0,
        width: screen.width,
        height: screen.height - hole.bottom,
      ),
      panel(
        top: hole.top,
        left: 0,
        width: hole.left,
        height: hole.height,
      ),
      panel(
        top: hole.top,
        left: hole.right,
        width: screen.width - hole.right,
        height: hole.height,
      ),
    ];
  }
}

class _TutorialBubble extends StatelessWidget {
  const _TutorialBubble({
    required this.title,
    required this.onDismiss,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fieldCarbon,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.right,
              style: AppFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.45,
                color: AppColors.textDark,
              ),
            ),
            if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.right,
                style: AppFonts.cairo(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: onDismiss,
                child: Text(
                  context.l10n.understood,
                  style: AppFonts.cairo(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
