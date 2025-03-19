import 'package:fancy_credit_card_input/fancy_credit_card_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('toString', (tester) async {
    final cardData = CardData(
        brand: CardBrand.visa,
        cardNumber: '4111111111111111',
        expiryMonth: 12,
        expiryYear: 25,
        cvv: '222');
    expect(cardData.toString(),
        'visa, Number: 4111111111111111, Month: 12, Year: 25, CVV: 222');
  });
}
