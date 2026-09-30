import 'package:fancy_credit_card_input/fancy_credit_card_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpFancySavedCreditCardInput(
    WidgetTester tester, {
    required CardBrand cardBrand,
    required String cardNumber,
    required CardNumberBuilder cardNumberBuilder,
    required DecorationBuilder decorationBuilder,
    void Function(CardData?)? onFormCompleted,
    int? expiryMonthInitialValue,
    int? expiryYearInitialValue,
    String? cvvInitialValue,
    ErrorBuilder? errorBuilder,
    String? expiryHint,
    String? cvvHint,
    ExpiryDateType? expiryDateType,
    String? Function(String?)? expiryValidator,
    String? Function(String?)? cvvValidator,
    bool expiryEnabled = true,
    bool cvvEnabled = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FancySavedCreditCardInput(
            cardBrand: cardBrand,
            cardNumber: cardNumber,
            onFormCompleted: onFormCompleted ?? (cardData) {},
            cardNumberBuilder: cardNumberBuilder,
            decorationBuilder: decorationBuilder,
            expiryMonthInitialValue: expiryMonthInitialValue,
            expiryYearInitialValue: expiryYearInitialValue,
            cvvInitialValue: cvvInitialValue,
            errorBuilder: errorBuilder,
            expiryHint: expiryHint,
            cvvHint: cvvHint,
            expiryDateType: expiryDateType ?? ExpiryDateType.regular,
            expiryValidator: expiryValidator,
            cvvValidator: cvvValidator,
            expiryEnabled: expiryEnabled,
            cvvEnabled: cvvEnabled,
          ),
        ),
      ),
    );
  }

  testWidgets('should display the card brand and last four digits in cardNumberBuilder', (tester) async {
    await pumpFancySavedCreditCardInput(
      tester,
      cardBrand: CardBrand.visa,
      cardNumber: '•••• •••• •••• 4242',
      cardNumberBuilder: (brand, cardLastFourDigits, hasError) => Row(
        children: [
          Text(brand.name),
          Text(cardLastFourDigits),
        ],
      ),
      decorationBuilder: (hasFocus, hasError) => const BoxDecoration(),
    );
    await tester.pumpAndSettle();

    expect(find.text('visa'), findsOneWidget);
    expect(find.text('4242'), findsOneWidget);
  });

  testWidgets('should extract last four digits when only 4 digits are passed', (tester) async {
    await pumpFancySavedCreditCardInput(
      tester,
      cardBrand: CardBrand.mastercard,
      cardNumber: '5678',
      cardNumberBuilder: (brand, cardLastFourDigits, hasError) => Text('Ending in $cardLastFourDigits'),
      decorationBuilder: (hasFocus, hasError) => const BoxDecoration(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ending in 5678'), findsOneWidget);
  });

  testWidgets('should populate initial values and call onFormCompleted', (tester) async {
    CardData? completedCard;

    await pumpFancySavedCreditCardInput(
      tester,
      cardBrand: CardBrand.visa,
      cardNumber: '•••• 1234',
      expiryMonthInitialValue: 12,
      expiryYearInitialValue: 26,
      cvvInitialValue: '123',
      cardNumberBuilder: (brand, cardLastFourDigits, hasError) => Text(cardLastFourDigits),
      decorationBuilder: (hasFocus, hasError) => const BoxDecoration(),
      onFormCompleted: (cardData) {
        completedCard = cardData;
      },
    );
    await tester.pumpAndSettle();

    expect(find.text('12/26'), findsOneWidget);
    expect(find.text('123'), findsOneWidget);
    expect(completedCard, isNotNull);
    expect(completedCard?.brand, equals(CardBrand.visa));
    expect(completedCard?.cardNumber, equals('•••• 1234'));
    expect(completedCard?.expiryMonth, equals(12));
    expect(completedCard?.expiryYear, equals(26));
    expect(completedCard?.cvv, equals('123'));
  });

  testWidgets('should support Amex 4-digit CVV', (tester) async {
    CardData? completedCard;

    await pumpFancySavedCreditCardInput(
      tester,
      cardBrand: CardBrand.amex,
      cardNumber: '•••• 3005',
      expiryMonthInitialValue: 5,
      expiryYearInitialValue: 28,
      cvvInitialValue: '1234',
      cardNumberBuilder: (brand, cardLastFourDigits, hasError) => Text(cardLastFourDigits),
      decorationBuilder: (hasFocus, hasError) => const BoxDecoration(),
      onFormCompleted: (cardData) {
        completedCard = cardData;
      },
    );
    await tester.pumpAndSettle();

    expect(completedCard, isNotNull);
    expect(completedCard?.brand, equals(CardBrand.amex));
    expect(completedCard?.cvv, equals('1234'));
  });

  testWidgets('should respect expiryEnabled and cvvEnabled when false', (tester) async {
    await pumpFancySavedCreditCardInput(
      tester,
      cardBrand: CardBrand.visa,
      cardNumber: '•••• 1234',
      expiryEnabled: false,
      cvvEnabled: false,
      cardNumberBuilder: (brand, cardLastFourDigits, hasError) => Text(cardLastFourDigits),
      decorationBuilder: (hasFocus, hasError) => const BoxDecoration(),
    );
    await tester.pumpAndSettle();

    final textFields = tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(textFields.length, equals(2));
    expect(textFields[0].enabled, isFalse);
    expect(textFields[1].enabled, isFalse);
  });

  testWidgets('should display error when validator returns an error', (tester) async {
    await pumpFancySavedCreditCardInput(
      tester,
      cardBrand: CardBrand.visa,
      cardNumber: '•••• 1234',
      expiryMonthInitialValue: 12,
      expiryYearInitialValue: 26,
      cvvInitialValue: '123',
      expiryValidator: (value) => 'Invalid date',
      errorBuilder: (errorMessage) => Text('Error: $errorMessage'),
      cardNumberBuilder: (brand, cardLastFourDigits, hasError) => Text(cardLastFourDigits),
      decorationBuilder: (hasFocus, hasError) => const BoxDecoration(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Error: Invalid date'), findsOneWidget);
  });
}
