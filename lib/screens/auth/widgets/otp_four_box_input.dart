import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/digit_input_formatter.dart';

class OtpFourBoxInput extends StatefulWidget {
  const OtpFourBoxInput({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<OtpFourBoxInput> createState() => OtpFourBoxInputState();
}

class OtpFourBoxInputState extends State<OtpFourBoxInput>
    with SingleTickerProviderStateMixin {
  static const length = 4;

  late final FocusNode _focusNode;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
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
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  Future<void> shake() async {
    await _shakeController.forward(from: 0);
  }

  void clear() {
    widget.controller.clear();
    _focusNode.requestFocus();
  }

  String get code => widget.controller.text;

  void _focusField() => _focusNode.requestFocus();

  @override
  Widget build(BuildContext context) {
    final digits = widget.controller.text.split('');
    while (digits.length < length) {
      digits.add('');
    }

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
              height: 68,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                maxLength: length,
                autofocus: true,
                inputFormatters: [appDigitsOnly(maxLength: length)],
                decoration: const InputDecoration(counterText: ''),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(length, (index) {
              final char = index < digits.length ? digits[index] : '';
              final filled = char.isNotEmpty;
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 10),
                child: GestureDetector(
                  onTap: _focusField,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.fieldCarbon,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: filled ? AppColors.volt : AppColors.glassBorder,
                        width: 1.5,
                      ),
                      boxShadow: filled
                          ? [
                              BoxShadow(
                                color: AppColors.volt.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      char,
                      style: AppFonts.cairo(
                        fontSize: 28,
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
  }
}
