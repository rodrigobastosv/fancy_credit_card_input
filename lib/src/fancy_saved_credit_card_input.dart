import 'package:fancy_credit_card_input/fancy_credit_card_input.dart';
import 'package:fancy_credit_card_input/src/utils/mask_utils.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// A credit card input component designed for editing an existing saved card.
///
/// It displays the card brand and the last four digits of the card in a fixed/collapsed state,
/// while providing editable fields for the expiration date and CVV.
class FancySavedCreditCardInput extends StatefulWidget {
  const FancySavedCreditCardInput({
    required this.cardBrand,
    required this.cardNumber,
    required this.cardNumberBuilder,
    required this.decorationBuilder,
    this.onFormCompleted,
    this.expiryMonthInitialValue,
    this.expiryYearInitialValue,
    this.cvvInitialValue,
    this.cardNumberFlex,
    this.expiryFlex,
    this.cvvFlex,
    this.onChangedExpiryDate,
    this.onChangedCvv,
    this.labelBuilder,
    this.errorBuilder,
    this.expiryDateType = ExpiryDateType.regular,
    this.cvvMask,
    this.expiryHint,
    this.cvvHint,
    this.expiryValidator,
    this.cvvValidator,
    this.animationDuration,
    this.animationCurve = Curves.easeInOut,
    this.hintTextStyle,
    this.inputTextStyle,
    this.errorInputTextStyle,
    this.cursorColor,
    this.cursorErrorColor,
    this.expiryEnabled = true,
    this.cvvEnabled = true,
    super.key,
  });

  /// The brand of the saved card.
  final CardBrand cardBrand;

  /// The card number or masked card number of the saved card (e.g. '•••• •••• •••• 1234' or '1234').
  final String cardNumber;

  /// Callback executed when the form is completed or when values become incomplete.
  final void Function(CardData?)? onFormCompleted;

  /// Builder executed to render the card brand and last four digits.
  final CardNumberBuilder cardNumberBuilder;

  /// Builder executed to customize the container decoration based on focus and error states.
  final DecorationBuilder decorationBuilder;

  /// Initial value for the expiry month.
  final int? expiryMonthInitialValue;

  /// Initial value for the expiry year.
  final int? expiryYearInitialValue;

  /// Initial value for the CVV.
  final String? cvvInitialValue;

  /// Flex space allocated for the card display section. Defaults to 9.
  final int? cardNumberFlex;

  /// Flex space allocated for the expiry field. Defaults to 3.
  final int? expiryFlex;

  /// Flex space allocated for the CVV field. Defaults to 2.
  final int? cvvFlex;

  /// Callback executed whenever the expiry date changes.
  final ValueChanged<String>? onChangedExpiryDate;

  /// Callback executed whenever the CVV changes.
  final ValueChanged<String>? onChangedCvv;

  /// Builder executed to customize the label above the component.
  final LabelBuilder? labelBuilder;

  /// Builder executed to customize the error message shown below the component.
  final ErrorBuilder? errorBuilder;

  /// Expiry date format (regular 2-digit year or full 4-digit year).
  final ExpiryDateType expiryDateType;

  /// Mask for the CVV field. Defaults to '####' for Amex and '###' for other brands.
  final String? cvvMask;

  /// Hint text for the expiry field.
  final String? expiryHint;

  /// Hint text for the CVV field.
  final String? cvvHint;

  /// Validator for the expiry input.
  final String? Function(String?)? expiryValidator;

  /// Validator for the CVV input.
  final String? Function(String?)? cvvValidator;

  /// Duration for decoration animations.
  final Duration? animationDuration;

  /// Curve for decoration animations.
  final Curve animationCurve;

  /// Style for hint text.
  final TextStyle? hintTextStyle;

  /// Style for input text.
  final TextStyle? inputTextStyle;

  /// Style for input text when in error state.
  final TextStyle? errorInputTextStyle;

  /// Color for the text cursor.
  final Color? cursorColor;

  /// Color for the text cursor when in error state.
  final Color? cursorErrorColor;

  /// Whether the expiry date field is enabled.
  final bool expiryEnabled;

  /// Whether the CVV field is enabled.
  final bool cvvEnabled;

  /// Formatted expiry date combining month and year.
  String? get formattedExpiryDate {
    if (expiryMonthInitialValue != null && expiryYearInitialValue != null) {
      final month = expiryMonthInitialValue!.toString().padLeft(2, '0');
      final year = switch (expiryDateType) {
        ExpiryDateType.regular => expiryYearInitialValue!.toString().padLeft(2, '0'),
        ExpiryDateType.fullYear => expiryYearInitialValue!.toString().padLeft(4, '0'),
      };
      return '$month$year';
    }
    return null;
  }

  @override
  State<FancySavedCreditCardInput> createState() => _FancySavedCreditCardInputState();
}

class _FancySavedCreditCardInputState extends State<FancySavedCreditCardInput> {
  late TextEditingController _expiryDateController;
  late TextEditingController _cvvController;

  late final FocusNode _expiryFocusNode;
  late final FocusNode _cvvFocusNode;

  late MaskTextInputFormatter expiryMask;
  late MaskTextInputFormatter cvvMask;

  String? _errorMessage;

  Duration get animationDuration => widget.animationDuration ?? const Duration(milliseconds: 300);

  String get _lastFourDigits {
    final digits = widget.cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 4) {
      return digits.substring(digits.length - 4);
    }
    return widget.cardNumber.length >= 4
        ? widget.cardNumber.substring(widget.cardNumber.length - 4)
        : widget.cardNumber;
  }

  bool get _hasFocus => _expiryFocusNode.hasFocus || _cvvFocusNode.hasFocus;
  bool get _hasError => _errorMessage != null;

  String get _effectiveCvvMask =>
      widget.cvvMask ?? (widget.cardBrand == CardBrand.amex ? '####' : '###');

  @override
  void initState() {
    super.initState();
    _expiryFocusNode = FocusNode();
    _cvvFocusNode = FocusNode();

    _expiryFocusNode.addListener(_onFocusChange);
    _cvvFocusNode.addListener(_onFocusChange);

    final initialExpiryDate = widget.formattedExpiryDate;
    expiryMask = MaskTextInputFormatter(
      mask: widget.expiryDateType.value,
      initialText: initialExpiryDate,
      filter: digitFilter,
    );
    cvvMask = MaskTextInputFormatter(
      mask: _effectiveCvvMask,
      initialText: widget.cvvInitialValue,
      filter: digitFilter,
    );

    _expiryDateController = TextEditingController(
      text: expiryMask.getMaskedText().isNotEmpty ? expiryMask.getMaskedText() : initialExpiryDate,
    );
    _cvvController = TextEditingController(
      text: cvvMask.getMaskedText().isNotEmpty ? cvvMask.getMaskedText() : widget.cvvInitialValue,
    );

    if (_expiryDateController.text.isNotEmpty && _cvvController.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _checkFormCompleted();
        }
      });
    }
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant FancySavedCreditCardInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    var shouldCheckForm = false;

    if (widget.formattedExpiryDate != oldWidget.formattedExpiryDate) {
      final newExpiryDate = widget.formattedExpiryDate;
      expiryMask = MaskTextInputFormatter(
        mask: widget.expiryDateType.value,
        initialText: newExpiryDate,
        filter: digitFilter,
      );
      _expiryDateController.text = expiryMask.getMaskedText().isNotEmpty
          ? expiryMask.getMaskedText()
          : (newExpiryDate ?? '');
      shouldCheckForm = true;
    }

    if (widget.cvvInitialValue != oldWidget.cvvInitialValue ||
        widget.cardBrand != oldWidget.cardBrand ||
        widget.cvvMask != oldWidget.cvvMask) {
      cvvMask = MaskTextInputFormatter(
        mask: _effectiveCvvMask,
        initialText: widget.cvvInitialValue,
        filter: digitFilter,
      );
      _cvvController.text = cvvMask.getMaskedText().isNotEmpty
          ? cvvMask.getMaskedText()
          : (widget.cvvInitialValue ?? '');
      shouldCheckForm = true;
    }

    if (shouldCheckForm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _checkFormCompleted();
        }
      });
    }
  }

  @override
  void dispose() {
    _expiryFocusNode.removeListener(_onFocusChange);
    _cvvFocusNode.removeListener(_onFocusChange);
    _expiryFocusNode.dispose();
    _cvvFocusNode.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _checkFormCompleted() {
    final expiryMasked = _expiryDateController.text;
    final expiryText = expiryMask.unmaskText(expiryMasked);

    final cvvMasked = _cvvController.text;
    final cvvText = cvvMask.unmaskText(cvvMasked);

    _validateFields(expiryMasked, cvvMasked);

    if (widget.onFormCompleted != null) {
      final expectedCvvLength = widget.cardBrand == CardBrand.amex ? 4 : 3;
      if (expiryText.length == widget.expiryDateType.length && cvvText.length == expectedCvvLength) {
        final expiryValues = expiryMasked.split('/');

        widget.onFormCompleted!(
          CardData(
            brand: widget.cardBrand,
            cardNumber: widget.cardNumber,
            expiryMonth: int.parse(expiryValues.first),
            expiryYear: int.parse(switch (widget.expiryDateType) {
              ExpiryDateType.regular => expiryValues.last,
              ExpiryDateType.fullYear => '20${expiryValues.last}'
            }),
            cvv: cvvText,
          ),
        );
      } else {
        widget.onFormCompleted!(null);
      }
    }
  }

  void _validateFields(String expiryMasked, String cvvMasked) {
    final expiryError = widget.expiryValidator?.call(expiryMasked);
    final cvvError = widget.cvvValidator?.call(cvvMasked);
    _errorMessage = expiryError ?? cvvError;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          if (widget.labelBuilder != null) widget.labelBuilder!(_hasError),
          AnimatedContainer(
            decoration: widget.decorationBuilder(_hasFocus, _hasError),
            duration: animationDuration,
            curve: widget.animationCurve,
            child: Row(
              children: [
                Expanded(
                  flex: widget.cardNumberFlex ?? 9,
                  child: widget.cardNumberBuilder(
                    widget.cardBrand,
                    _lastFourDigits,
                    _hasError,
                  ),
                ),
                _buildExpiryField(),
                _buildCVVField(),
              ],
            ),
          ),
          if (widget.errorBuilder != null)
            Visibility(
              visible: _hasError,
              maintainAnimation: true,
              maintainState: true,
              child: widget.errorBuilder!(_errorMessage ?? ''),
            ),
        ],
      );

  Widget _buildExpiryField() => Expanded(
        flex: widget.expiryFlex ?? 3,
        child: TextField(
          enabled: widget.expiryEnabled,
          controller: _expiryDateController,
          focusNode: _expiryFocusNode,
          keyboardType: TextInputType.datetime,
          inputFormatters: [expiryMask],
          onChanged: (expiryMasked) {
            if (widget.onChangedExpiryDate != null) {
              widget.onChangedExpiryDate!(expiryMasked);
            }

            if (expiryMask.isFill()) {
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) {
                  _cvvFocusNode.requestFocus();
                }
              });
            }
            _checkFormCompleted();
          },
          style: _hasError ? widget.errorInputTextStyle : widget.inputTextStyle,
          decoration: InputDecoration(
            hintText: widget.expiryHint,
            counterText: '',
            border: InputBorder.none,
            hintStyle: widget.hintTextStyle,
          ),
          cursorColor: _hasError ? widget.cursorErrorColor : widget.cursorColor,
        ),
      );

  Widget _buildCVVField() => Expanded(
        flex: widget.cvvFlex ?? 2,
        child: TextField(
          enabled: widget.cvvEnabled,
          controller: _cvvController,
          focusNode: _cvvFocusNode,
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [cvvMask],
          maxLength: widget.cardBrand == CardBrand.amex ? 4 : 3,
          style: _hasError ? widget.errorInputTextStyle : widget.inputTextStyle,
          decoration: InputDecoration(
            hintText: widget.cvvHint,
            counterText: '',
            border: InputBorder.none,
            hintStyle: widget.hintTextStyle,
          ),
          cursorColor: _hasError ? widget.cursorErrorColor : widget.cursorColor,
          onChanged: (cvvMasked) {
            if (widget.onChangedCvv != null) {
              widget.onChangedCvv!(cvvMasked);
            }

            _checkFormCompleted();
          },
        ),
      );
}
