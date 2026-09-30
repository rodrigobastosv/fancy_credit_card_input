import 'package:fancy_credit_card_input/src/enums/card_brand.dart';
import 'package:flutter/widgets.dart';

typedef LabelBuilder = Widget Function(bool hasError);
typedef CardNumberBuilder = Widget Function(CardBrand brand, String cardLastFourDigits, bool hasError);
typedef DecorationBuilder = Decoration Function(bool hasFocus, bool hasError);
typedef ErrorBuilder = Widget Function(String errorMessage);
