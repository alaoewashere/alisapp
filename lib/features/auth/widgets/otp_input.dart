import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/digit_input_formatter.dart';

class OtpInput extends ConsumerStatefulWidget {
  const OtpInput({
    super.key,
    required this.onChanged,
    this.enabled = true,
  });

  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  ConsumerState<OtpInput> createState() => OtpInputState();
}

class OtpInputState extends ConsumerState<OtpInput> {
  static const length = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(length, (_) => TextEditingController());
    _focusNodes = List.generate(length, (_) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.enabled) _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    widget.onChanged('');
    if (widget.enabled) _focusNodes.first.requestFocus();
  }

  String get code => _controllers.map((c) => c.text).join();

  bool get isComplete =>
      code.length == length && _controllers.every((c) => c.text.isNotEmpty);

  void _notifyChange() => widget.onChanged(code);

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      _fillFromPaste(value, index);
      return;
    }

    if (value.isNotEmpty && index < length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    _notifyChange();
  }

  void _fillFromPaste(String pasted, int startIndex) {
    final digits = WesternDigitsInputFormatter.toWestern(pasted);
    if (digits.isEmpty) return;

    for (var i = 0; i < length; i++) {
      final digitIndex = i - startIndex;
      if (digitIndex >= 0 && digitIndex < digits.length) {
        _controllers[i].text = digits[digitIndex];
      }
    }

    _notifyChange();

    if (isComplete) {
      _focusNodes.last.unfocus();
    } else {
      final nextEmpty = _controllers.indexWhere((c) => c.text.isEmpty);
      if (nextEmpty >= 0) {
        _focusNodes[nextEmpty].requestFocus();
      }
    }
  }

  KeyEventResult _onKeyEvent(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(length, (index) {
          return SizedBox(
            width: 48,
            child: Focus(
              onKeyEvent: (_, event) => _onKeyEvent(index, event),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                enabled: widget.enabled,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: Theme.of(context).textTheme.headlineSmall,
                inputFormatters: [
                  WesternDigitsInputFormatter(maxLength: 1),
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => _onChanged(index, v),
              ),
            ),
          );
        }),
      ),
    );
  }
}
