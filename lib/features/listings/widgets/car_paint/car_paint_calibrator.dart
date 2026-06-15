import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Set to `true` during development to tap panel corners on the diagram.
/// Tap top-left then bottom-right for each panel in [kCarPaintCalibrationOrder].
/// Copy `PANEL …` lines from the console into `car_paint_panel_layout.dart`.
const kEnableCarPaintCalibration = false;

const kCarPaintCalibrationOrder = <String>[
  'front_bumper',
  'hood',
  'front_left_fender',
  'front_right_fender',
  'front_left_door',
  'front_right_door',
  'roof',
  'rear_left_door',
  'rear_right_door',
  'rear_left_fender',
  'rear_right_fender',
  'trunk',
  'rear_bumper',
];

/// Debug overlay: two-tap corner measurement on the car diagram image.
class CarPaintCalibrator extends StatefulWidget {
  const CarPaintCalibrator({
    super.key,
    required this.imgWidth,
    required this.imgHeight,
    required this.child,
  });

  final double imgWidth;
  final double imgHeight;
  final Widget child;

  @override
  State<CarPaintCalibrator> createState() => _CarPaintCalibratorState();
}

class _CarPaintCalibratorState extends State<CarPaintCalibrator> {
  int _panelIndex = 0;
  Offset? _firstCorner;

  void _onTapDown(TapDownDetails details, BuildContext context) {
    final box = context.findRenderObject()! as RenderBox;
    final local = box.globalToLocal(details.globalPosition);
    final pctX = local.dx / widget.imgWidth;
    final pctY = local.dy / widget.imgHeight;

    debugPrint('TAP: x=${pctX.toStringAsFixed(3)}, y=${pctY.toStringAsFixed(3)}');

    if (_firstCorner == null) {
      setState(() => _firstCorner = Offset(pctX, pctY));
      return;
    }

    final x1 = _firstCorner!.dx;
    final y1 = _firstCorner!.dy;
    final x2 = pctX;
    final y2 = pctY;
    final panelId = kCarPaintCalibrationOrder[_panelIndex];
    final left = x1 < x2 ? x1 : x2;
    final top = y1 < y2 ? y1 : y2;
    final width = (x2 - x1).abs();
    final height = (y2 - y1).abs();

    debugPrint(
      "PANEL $panelId: left=${left.toStringAsFixed(3)} "
      'top=${top.toStringAsFixed(3)} '
      'w=${width.toStringAsFixed(3)} '
      'h=${height.toStringAsFixed(3)}',
    );

    _firstCorner = null;
    if (_panelIndex < kCarPaintCalibrationOrder.length - 1) {
      setState(() => _panelIndex++);
    } else {
      debugPrint('Calibration complete — copy PANEL lines into car_paint_panel_layout.dart');
    }
  }

  @override
  Widget build(BuildContext context) {
    final panelId = kCarPaintCalibrationOrder[_panelIndex];
    return Stack(
      children: [
        GestureDetector(
          onTapDown: (details) => _onTapDown(details, context),
          child: widget.child,
        ),
        Positioned(
          left: 4,
          top: 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                _firstCorner == null
                    ? 'Panel ${_panelIndex + 1}/13: $panelId — tap top-left'
                    : 'Panel ${_panelIndex + 1}/13: $panelId — tap bottom-right',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ),
        if (_firstCorner != null)
          Positioned(
            left: _firstCorner!.dx * widget.imgWidth - 4,
            top: _firstCorner!.dy * widget.imgHeight - 4,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

bool get carPaintCalibrationEnabled =>
    kDebugMode && kEnableCarPaintCalibration;
