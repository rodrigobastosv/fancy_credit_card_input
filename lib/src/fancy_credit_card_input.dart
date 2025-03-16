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
    required this.onFormCompleted,
    required this.cardNumberBuilder,
    required this.decorationBuilder,
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

  final void Function(CardData?) onFormCompleted;
  final CardNumberBuilder cardNumberBuilder;
  final DecorationBuilder decorationBuilder;
  final LabelBuilder? labelBuilder;
  final ErrorBuilder? errorBuilder;
  final String cardNumberMask;
  final List<int> supportedCardLengths;
  final ExpiryDateType expiryDateType;
  final String cvvMask;
  final String? cardNumberHint;
  final String? expiryHint;
  final String? cvvHint;
  final String? Function(String?)? cardNumberValidator;
  final String? Function(String?)? expiryValidator;
  final String? Function(String?)? cvvValidator;
  final Duration? animationDuration;
  final Curve animationCurve;
  final TextStyle? hintTextStyle;

  @override
  State<FancyCreditCardInput> createState() => _FancyCreditCardInputState();
}

class _FancyCreditCardInputState extends State<FancyCreditCardInput> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

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
    cardNumberMask = MaskTextInputFormatter(mask: widget.cardNumberMask, initialText: null, filter: digitFilter);
    expiryMask = MaskTextInputFormatter(mask: widget.expiryDateType.value, initialText: null, filter: digitFilter);
    cvvMask = MaskTextInputFormatter(mask: widget.cvvMask, initialText: null, filter: digitFilter);

    _cardNumberFocusNode.addListener(_cardNumberFieldLostFocusListener);
  }

  void _cardNumberFieldLostFocusListener() {
    if (!_cardNumberFocusNode.hasFocus) {
      setState(() => _editCardNumber = false);
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
                  flex: 9,
                  child: AnimatedCrossFade(
                    firstChild: _buildCardNumberField(),
                    secondChild: GestureDetector(
                      onTap: _expandCardNumberField,
                      child: widget.cardNumberBuilder(_cardBrand, _lastFourDigits),
                    ),
                    crossFadeState: _isCollapsed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: animationDuration,
                    firstCurve: widget.animationCurve,
                    secondCurve: widget.animationCurve,
                  ),
                ),
                if (_isCollapsed) ...[const SizedBox(width: 12), _buildExpiryField(), const SizedBox(width: 8), _buildCVVField()],
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

    if (_cardBrand != CardBrand.unknown && expiryText.length == widget.expiryDateType.length && cvvText.length == 3) {
      final expiryValues = expiryMasked.split('/');
      widget.onFormCompleted(
        CardData(
          brand: _cardBrand,
          cardNumber: cardNumberText,
          expiryMonth: int.parse(expiryValues.first),
          expiryYear: int.parse(expiryValues.last),
          cvv: cvvText,
        ),
      );
    } else {
      widget.onFormCompleted(null);
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

  Widget _buildCardNumberField() => TextField(
        controller: _cardNumberController,
        focusNode: _cardNumberFocusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [cardNumberMask],
        onChanged: (cardNumberMasked) {
          final cardNumber = cardNumberMask.unmaskText(cardNumberMasked);
          if (widget.supportedCardLengths.contains(cardNumber.length) && !_editCardNumber) {
            setState(() {
              _isCollapsed = true;
              _cardBrand = CardBrand.fromCardNumber(cardNumber);
            });
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) {
                FocusScope.of(context).nextFocus();
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
        flex: 3,
        child: TextField(
          controller: _expiryDateController,
          focusNode: _expiryFocusNode,
          keyboardType: TextInputType.datetime,
          inputFormatters: [expiryMask],
          onChanged: (expiryMasked) {
            if (expiryMask.isFill()) {
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) {
                  FocusScope.of(context).nextFocus();
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
        flex: 2,
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
            _checkFormCompleted();
          },
        ),
      );
}
