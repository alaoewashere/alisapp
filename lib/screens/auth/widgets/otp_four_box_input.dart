import 'package:flutter/material.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/digit_input_formatter.dart';

/// Fixed-digit OTP input — always LTR, left-to-right fill. Defaults to 4
/// boxes (phone OTP); pass [length] for other code sizes (e.g. 6 for email).
class OtpFourBoxInput extends StatefulWidget {
  const OtpFourBoxInput({
    super.key,
    required this.controller,
    this.enabled = true,
    this.length = 4,
  });

  final TextEditingController controller;
  final bool enabled;
  final int length;

  @override
  State<OtpFourBoxInput> createState() => OtpFourBoxInputState();
}

class OtpFourBoxInputState extends State<OtpFourBoxInput>
    with SingleTickerProviderStateMixin {
  static const _maxBoxSize = 62.0;
  static const _maxBoxSpacing = 12.0;
  static const _borderRadius = 14.0;

  int get length => widget.length;

  late final FocusNode _focusNode;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onControllerChanged);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  void _onFocusChanged() => setState(() {});

  Future<void> shake() async {
    await _shakeController.forward(from: 0);
  }

  void clear() {
    widget.controller.clear();
    if (widget.enabled) _focusNode.requestFocus();
  }

  String get code => widget.controller.text;

  void _focusField() {
    if (widget.enabled) _focusNode.requestFocus();
  }

  Color _borderColor(int index, String text) {
    final filled = index < text.length;
    final active = widget.enabled &&
        _focusNode.hasFocus &&
        index == text.length.clamp(0, length - 1);

    if (active && !filled) return AppColors.volt;
    if (filled) return AppColors.pureWhite.withValues(alpha: 0.4);
    return AppColors.pureWhite.withValues(alpha: 0.15);
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Scale box size and spacing down together (uniformly) so the row
          // always fits the available width, however long the code is —
          // email OTP alone has changed length twice already. Scaling both
          // dimensions by the same factor guarantees the total never
          // exceeds maxWidth, unlike clamping box size to a fixed floor.
          final maxWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : _maxBoxSize * length + _maxBoxSpacing * (length - 1);
          final idealTotal = _maxBoxSize * length + _maxBoxSpacing * (length - 1);
          final scale = idealTotal > maxWidth ? maxWidth / idealTotal : 1.0;
          // No floor clamp on boxSize: fitting the screen takes priority
          // over a minimum box size, or long codes overflow again.
          final boxSize = _maxBoxSize * scale;
          final spacing = _maxBoxSpacing * scale;

          return AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: child,
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0,
                  child: SizedBox(
                    height: boxSize,
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      enabled: widget.enabled,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                      maxLength: length,
                      autofocus: widget.enabled,
                      inputFormatters: [appDigitsOnly(maxLength: length)],
                      decoration: const InputDecoration(counterText: ''),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(length, (index) {
                    final char = index < text.length ? text[index] : '';
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : spacing,
                      ),
                      child: GestureDetector(
                        onTap: _focusField,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: boxSize,
                          height: boxSize,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.fieldCarbon,
                            borderRadius: BorderRadius.circular(_borderRadius),
                            border: Border.all(
                              color: _borderColor(index, text),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            char,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: AppFonts.sans(
                              fontSize: boxSize >= 56 ? 24 : 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.pureWhite,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
