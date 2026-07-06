import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fades + slides a child in once on mount, delayed by its [index] so a list or
/// grid reveals in a smooth cascade instead of popping in all at once.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 45),
    this.duration = const Duration(milliseconds: 430),
    this.maxStagger = 12,
    this.offset = 0.12,
  });

  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration duration;

  /// Cap on how many items keep staggering (keeps long lists from feeling slow).
  final int maxStagger;

  /// Vertical slide distance as a fraction of the child height.
  final double offset;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    final steps = math.min(widget.index, widget.maxStagger);
    Future<void>.delayed(widget.baseDelay * steps, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, widget.offset),
          end: Offset.zero,
        ).animate(_curve),
        child: widget.child,
      ),
    );
  }
}
