import 'package:flutter/material.dart';

import 'sello_web_ready.dart';

/// Marks `data-sello-ready="true"` on `<html>` after the first frame (web only).
class SelloWebReadyMarker extends StatefulWidget {
  const SelloWebReadyMarker({super.key, required this.child});

  final Widget child;

  @override
  State<SelloWebReadyMarker> createState() => _SelloWebReadyMarkerState();
}

class _SelloWebReadyMarkerState extends State<SelloWebReadyMarker> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => markSelloWebReady());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
