import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ExpiryTextField extends StatelessWidget {
  const ExpiryTextField({
    super.key,
    required this.expiryController,
    required this.expiryFocusNode,
    required this.expiryMask,
    required this.onChanged,
    this.hint,
  });

  final TextEditingController expiryController;
  final FocusNode expiryFocusNode;
  final MaskTextInputFormatter expiryMask;
  final ValueChanged<String>? onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: expiryController,
      focusNode: expiryFocusNode,
      keyboardType: TextInputType.datetime,
      inputFormatters: [expiryMask],
      onChanged: onChanged,
      decoration:
          InputDecoration(hintText: hint ?? 'MM/YY', border: InputBorder.none),
    );
  }
}
