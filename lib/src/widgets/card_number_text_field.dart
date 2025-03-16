import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CardNumberTextField extends StatelessWidget {
  const CardNumberTextField({
    super.key,
    required this.cardNumberController,
    required this.cardNumberFocusNode,
    required this.cardNumberMask,
    required this.onChanged,
    this.hint,
  });

  final TextEditingController cardNumberController;
  final FocusNode cardNumberFocusNode;
  final MaskTextInputFormatter cardNumberMask;
  final ValueChanged<String>? onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: cardNumberController,
      focusNode: cardNumberFocusNode,
      keyboardType: TextInputType.number,
      inputFormatters: [cardNumberMask],
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint ?? 'Enter Credit Card Number',
        border: InputBorder.none,
        contentPadding: const EdgeInsets.only(left: 8),
      ),
    );
  }
}
