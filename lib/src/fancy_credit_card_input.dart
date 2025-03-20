import 'package:fancy_credit_card_input/fancy_credit_card_input.dart';
import 'package:fancy_credit_card_input/src/utils/mask_utils.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

typedef LabelBuilder = Widget Function(bool hasError);
typedef CardNumberBuilder = Widget Function(CardBrand brand, String cardLastFourDigits);
typedef DecorationBuilder = Decoration Function(bool hasFocus, bool hasError);
typedef ErrorBuilder = Widget Function(String errorMessage);

class FancyCreditCardInput extends StatefulWidget {
  const FancyCreditCardInput({
    required this.cardNumberBuilder,
    required this.decorationBuilder,
    this.onFormCompleted,
    this.cardNumberInitialValue,
    this.expiryMonthInitialValue,
    this.expiryYearInitialValue,
    this.cvvInitialValue,
    this.cardNumberFlex,
    this.expiryFlex,
    this.cvvFlex,
    this.onChangedCardNumber,
    this.onChangedExpiryDate,
    this.onChangedCvv,
    this.labelBuilder,
    this.errorBuilder,
    this.cardNumberMask = '#### #### #### #### ###',
    this.supportedCardLengths = const [16, 19],
    this.expiryDateType = ExpiryDateType.regular,
    this.cvvMask = '###',
    this.cardNumberHint,
    this.expiryHint,
    this.cvvHint,
    this.cardNumberValidator,
    this.expiryValidator,
    this.cvvValidator,
    this.animationDuration,
    this.animationCurve = Curves.easeInOut,
    this.hintTextStyle,
    super.key,
  });

  /// Callback that will be executed when the form is completed with all the data needed
  ///
  /// This callback is often called with null when the form is not complete. This happens, for instance, when the user
  /// edits some field values and the fields becomes not filled
  final void Function(CardData?)? onFormCompleted;

  /// Builder executed whenever the card number is filled. You have the liberty to add whatever component you want here
  ///
  /// Usually what is done here is display both the brand and the last 4 digits. That's why this builder receives
  /// these two values.
  final CardNumberBuilder cardNumberBuilder;

  /// Builder executed to customize the decoration of the component.
  ///
  /// It receives both the focus and error states so you can customize your ui accordingly.
  final DecorationBuilder decorationBuilder;

  /// Initial value for the card number field
  final String? cardNumberInitialValue;

  /// Initial value for the expiry month field
  final int? expiryMonthInitialValue;

  /// Initial value for the expiry year field
  final int? expiryYearInitialValue;

  /// Initial value for the cvv field
  final String? cvvInitialValue;

  /// Flex space that the card number field takes
  final int? cardNumberFlex;

  /// Flex space that the expiry field takes
  final int? expiryFlex;

  /// Flex space that the cvv field takes
  final int? cvvFlex;

  /// Callback executed whenever the card number changes
  final ValueChanged<String>? onChangedCardNumber;

  /// Callback executed whenever the expiry date changes
  final ValueChanged<String>? onChangedExpiryDate;

  /// Callback executed whenever the cvv changes
  final ValueChanged<String>? onChangedCvv;

  /// Builder executed to customize the label above the component.
  ///
  /// It receives the error state so you can customize your ui accordingly.
  final LabelBuilder? labelBuilder;

  /// Builder executed to customize the error message shown below the component.
  ///
  /// It receives the error message so you can customize your ui accordingly.
  final ErrorBuilder? errorBuilder;

  /// The mask of the credit card number field
  final String cardNumberMask;

  /// List with the suported lengths of the cards.
  ///
  /// Defaults to [16, 19] as it's the most commom values nowadays.
  final List<int> supportedCardLengths;

  /// Type of the expiry date
  ///
  /// Change this if you want to change the year format of the expiry. Option are regular (2 digits) and full year (4 digits)
  final ExpiryDateType expiryDateType;

  /// The mask of the cvv field
  final String cvvMask;

  /// Hint to be displayed inside the card number field
  final String? cardNumberHint;

  /// Hint to be displayed inside the expiry field
  final String? expiryHint;

  /// Hint to be displayed inside the cvv field
  final String? cvvHint;

  /// Validator to validate the card number input
  final String? Function(String?)? cardNumberValidator;

  /// Validator to validate the expiry input
  final String? Function(String?)? expiryValidator;

  /// Validator to validate the CVV input
  final String? Function(String?)? cvvValidator;

  /// Duration of the animations
  final Duration? animationDuration;

  /// Curve of the animations
  final Curve animationCurve;

  /// Style of the hint text
  final TextStyle? hintTextStyle;

  @override
  State<FancyCreditCardInput> createState() => _FancyCreditCardInputState();
}

class _FancyCreditCardInputState extends State<FancyCreditCardInput> {
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryDateController;
  late TextEditingController _cvvController;

  final FocusNode _cardNumberFocusNode = FocusNode();
  final FocusNode _expiryFocusNode = FocusNode();
  final FocusNode _cvvFocusNode = FocusNode();

  late MaskTextInputFormatter cardNumberMask;
  late MaskTextInputFormatter expiryMask;
  late MaskTextInputFormatter cvvMask;

  bool _isCollapsed = false;
  bool _editCardNumber = false;
  String? _errorMessage;

  CardBrand _cardBrand = CardBrand.unknown;

  Duration get animationDuration => widget.animationDuration ?? const Duration(milliseconds: 300);

  String get _lastFourDigits {
    final creditCardNumber = cardNumberMask.getUnmaskedText();
    return creditCardNumber.length > 4 ? creditCardNumber.substring(creditCardNumber.length - 4) : creditCardNumber;
  }

  bool get _hasFocus => _cardNumberFocusNode.hasFocus || _expiryFocusNode.hasFocus || _cvvFocusNode.hasFocus;
  bool get _hasError => _errorMessage != null;

  @override
  void initState() {
    super.initState();

    final initialExpiryDate = widget.expiryMonthInitialValue != null && widget.expiryYearInitialValue != null
        ? switch (widget.expiryDateType) {
            ExpiryDateType.regular => '${widget.expiryMonthInitialValue}/${widget.expiryYearInitialValue}',
            ExpiryDateType.fullYear => '${widget.expiryMonthInitialValue}/20${widget.expiryYearInitialValue}',
          }
        : null;
    _cardNumberController = TextEditingController(text: widget.cardNumberInitialValue);
    _expiryDateController = TextEditingController(text: initialExpiryDate);
    _cvvController = TextEditingController(text: widget.cvvInitialValue);

    cardNumberMask = MaskTextInputFormatter(mask: widget.cardNumberMask, initialText: widget.cardNumberInitialValue, filter: digitFilter);
    expiryMask = MaskTextInputFormatter(mask: widget.expiryDateType.value, initialText: initialExpiryDate, filter: digitFilter);
    cvvMask = MaskTextInputFormatter(mask: widget.cvvMask, initialText: widget.cvvInitialValue, filter: digitFilter);

    _cardNumberFocusNode.addListener(_cardNumberFieldLostFocusListener);

    if (hasCardNumberInformation(_cardNumberController.text, _expiryDateController.text, _cvvController.text)) {
      setState(() {
        _isCollapsed = true;
      });
    }
  }

  void _cardNumberFieldLostFocusListener() {
    if (!_cardNumberFocusNode.hasFocus) {
      setState(() => _editCardNumber = false);
    }

    if (hasCardNumberInformation(_cardNumberController.text, _expiryDateController.text, _cvvController.text)) {
      setState(() {
        _isCollapsed = true;
      });
    }
  }

  void _expandCardNumberField() {
    setState(() {
      _isCollapsed = false;
      _editCardNumber = true;
    });
    FocusScope.of(context).requestFocus(_cardNumberFocusNode);
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
                  child: AnimatedSwitcher(
                    duration: animationDuration,
                    reverseDuration: Duration.zero,
                    transitionBuilder: (child, animation) {
                      if (child.key == const ValueKey('cardNumber')) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      }

                      final slideAnimation = Tween<Offset>(
                        begin: const Offset(0.3, 0),
                        end: const Offset(0, 0),
                      ).animate(animation);

                      return SlideTransition(
                        position: slideAnimation,
                        child: child,
                      );
                    },
                    child: _isCollapsed
                        ? GestureDetector(
                            key: const ValueKey('collapsed'),
                            onTap: _expandCardNumberField,
                            child: widget.cardNumberBuilder(_cardBrand, _lastFourDigits),
                          )
                        : _buildCardNumberField(key: const ValueKey('cardNumber')),
                  ),
                ),
                if (_isCollapsed) ...[
                  const SizedBox(width: 12),
                  _buildExpiryField(),
                  const SizedBox(width: 8),
                  _buildCVVField(),
                ],
              ],
            ),
          ),
          if (widget.errorBuilder != null)
            Visibility(
              visible: _hasError,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: widget.errorBuilder!(_errorMessage ?? ''),
            ),
        ],
      );

  void _checkFormCompleted() {
    final cardNumberMasked = _cardNumberController.text;
    final cardNumberText = cardNumberMask.unmaskText(cardNumberMasked);

    final expiryMasked = _expiryDateController.text;
    final expiryText = expiryMask.unmaskText(expiryMasked);

    final cvvMasked = _cvvController.text;
    final cvvText = cvvMask.unmaskText(cvvMasked);

    _validateFields(cardNumberMasked, expiryMasked, cvvMasked);

    if (widget.onFormCompleted != null) {
      if (_cardBrand != CardBrand.unknown && expiryText.length == widget.expiryDateType.length && cvvText.length == 3) {
        final expiryValues = expiryMasked.split('/');

        widget.onFormCompleted!(
          CardData(
            brand: _cardBrand,
            cardNumber: cardNumberText,
            expiryMonth: int.parse(expiryValues.first),
            expiryYear:
                int.parse(switch (widget.expiryDateType) { ExpiryDateType.regular => expiryValues.last, ExpiryDateType.fullYear => '20${expiryValues.last}' }),
            cvv: cvvText,
          ),
        );
      } else {
        widget.onFormCompleted!(null);
      }
    }
  }

  void _validateFields(String cardNumberMasked, String expiryMasked, String cvvMasked) {
    if (widget.cardNumberValidator != null) {
      _errorMessage = widget.cardNumberValidator!(cardNumberMasked);
    }

    if (widget.expiryValidator != null) {
      _errorMessage = widget.expiryValidator!(expiryMasked);
    }

    if (widget.cvvValidator != null) {
      _errorMessage = widget.cvvValidator!(cvvMasked);
    }
    setState(() {});
  }

  bool hasCardNumberInformation(String cardNumberMasked, String expiryMasked, String cvvMasked) {
    final cardNumber = cardNumberMask.unmaskText(cardNumberMasked);
    return widget.supportedCardLengths.contains(cardNumber.length) && !_editCardNumber;
  }

  Widget _buildCardNumberField({Key? key}) => TextField(
        key: key,
        controller: _cardNumberController,
        focusNode: _cardNumberFocusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [cardNumberMask],
        onChanged: (cardNumberMasked) {
          if (widget.onChangedCardNumber != null) {
            widget.onChangedCardNumber!(cardNumberMasked);
          }

          final cardNumber = cardNumberMask.unmaskText(cardNumberMasked);
          if (widget.supportedCardLengths.contains(cardNumber.length) && !_editCardNumber) {
            setState(() {
              _isCollapsed = true;
              _cardBrand = CardBrand.fromCardNumber(cardNumber);
            });
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) {
                _expiryFocusNode.requestFocus();
              }
              _checkFormCompleted();
            });
          } else {
            setState(() {
              _isCollapsed = false;
              _editCardNumber = false;
            });
          }
        },
        decoration: InputDecoration(
          hintText: widget.cardNumberHint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(left: 8),
          hintStyle: widget.hintTextStyle,
        ),
      );

  Widget _buildExpiryField() => Expanded(
        flex: widget.expiryFlex ?? 3,
        child: TextField(
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
          decoration: InputDecoration(
            hintText: widget.expiryHint,
            counterText: '',
            border: InputBorder.none,
            hintStyle: widget.hintTextStyle,
          ),
        ),
      );

  Widget _buildCVVField() => Expanded(
        flex: widget.cvvFlex ?? 2,
        child: TextField(
          controller: _cvvController,
          focusNode: _cvvFocusNode,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 3,
          decoration: InputDecoration(
            hintText: widget.cvvHint,
            counterText: '',
            border: InputBorder.none,
            hintStyle: widget.hintTextStyle,
          ),
          onChanged: (cvvMasked) {
            if (widget.onChangedCvv != null) {
              widget.onChangedCvv!(cvvMasked);
            }

            _checkFormCompleted();
          },
        ),
      );
}
