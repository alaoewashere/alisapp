import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.prefixIcon,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final IconData? prefixIcon;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }
}
