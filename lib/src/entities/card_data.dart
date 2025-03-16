import 'package:fancy_credit_card_input/fancy_credit_card_input.dart';

class CardData {
  CardData({
    required this.brand,
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
  });

  final CardBrand brand;
  final String cardNumber;
  final int expiryMonth;
  final int expiryYear;
  final String cvv;

  @override
  String toString() {
    return '${brand.name}, Number: $cardNumber, Month: $expiryMonth, Year: $expiryYear, CVV: $cvv';
  }
}
