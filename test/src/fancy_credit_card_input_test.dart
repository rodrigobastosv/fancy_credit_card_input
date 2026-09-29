import 'package:fancy_credit_card_input/fancy_credit_card_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpFancyCreditCardInput(
    WidgetTester tester, {
    void Function(CardData?)? onFormCompleted,
    required CardNumberBuilder cardNumberBuilder,
    required DecorationBuilder decorationBuilder,
    String? cardNumberInitialValue,
    int? expiryMonthInitialValue,
    int? expiryYearInitialValue,
    String? cvvInitialValue,
    ErrorBuilder? errorBuilder,
    String? cardNumberHint,
    ExpiryDateType? expiryDateType,
    String? Function(String?)? cardNumberValidator,
    String? Function(String?)? expiryValidator,
    String? Function(String?)? cvvValidator,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FancyCreditCardInput(
            onFormCompleted: onFormCompleted ?? (cardData) {},
            cardNumberBuilder: cardNumberBuilder,
            decorationBuilder: decorationBuilder,
            cardNumberInitialValue: cardNumberInitialValue,
            expiryMonthInitialValue: expiryMonthInitialValue,
            expiryYearInitialValue: expiryYearInitialValue,
            cvvInitialValue: cvvInitialValue,
            errorBuilder: errorBuilder,
            cardNumberHint: cardNumberHint,
            expiryDateType: expiryDateType ?? ExpiryDateType.regular,
            cardNumberValidator: cardNumberValidator,
            expiryValidator: expiryValidator,
            cvvValidator: cvvValidator,
          ),
        ),
      ),
    );
  }

  Future<void> enterCardNumber(
    WidgetTester tester, {
    required String cardNumber,
  }) async {
    final cardNumberTextField = find.byType(TextField).at(0);
    await tester.enterText(cardNumberTextField, cardNumber);
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> enterExpiry(
    WidgetTester tester, {
    required String expiry,
  }) async {
    final expiryTextField = find.byType(TextField).at(1);
    await tester.enterText(expiryTextField, expiry);
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('should show card number hint', (tester) async {
    await pumpFancyCreditCardInput(
      tester,
      cardNumberBuilder: (brand, cardLastFourDigits, hasError) => const SizedBox(),
      decorationBuilder: (hasFocus, hasError) => const BoxDecoration(),
      cardNumberHint: 'Enter your Card Number',
    );
    expect(find.text('Enter your Card Number'), findsOneWidget);
  });

  testWidgets('should show widget with expiry type full year', (tester) async {
    await pumpFancyCreditCardInput(tester,
        cardNumberBuilder: (brand, cardLastFourDigits, hasError) => const SizedBox(),
        decorationBuilder: (hasFocus, hasError) => const BoxDecoration(),
        cardNumberHint: 'Enter your Card Number',
        expiryDateType: ExpiryDateType.fullYear);
    expect(find.text('Enter your Card Number'), findsOneWidget);
  });

  testWidgets(
      'should execute the cardNumberBuilder after the card number field is completely filled',
      (tester) async {
    var cardNumberBuilderCalled = false;
    await pumpFancyCreditCardInput(
      tester,
      cardNumberBuilder: (brand, cardLastFourDigits, hasError) {
        cardNumberBuilderCalled = true;
        return Text(cardLastFourDigits);
      },
      decorationBuilder: (hasFocus, hasError) => const BoxDecoration(),
      cardNumberHint: 'Enter your Card Number',
    );
    await enterCardNumber(tester, cardNumber: '4111111111111234');
    expect(find.text('1234'), findsOneWidget);
    expect(cardNumberBuilderCalled, true);
  });

  testWidgets(
      'should start colapsed when theres an initial value for the card number',
      (tester) async {
    await pumpFancyCreditCardInput(
      tester,
      cardNumberInitialValue: '4111111111111234',
      cardNumberBuilder: (brand, cardLastFourDigits, hasError) =>
          Text(cardLastFourDigits),
      decorationBuilder: (hasFocus, hasError) => const BoxDecoration(),
      cardNumberHint: 'Enter your Card Number',
    );
    expect(find.text('1234'), findsOneWidget);
  });

  testWidgets(
      'should not show the last four digits if the card number is not completely filled',
      (tester) async {
    await pumpFancyCreditCardInput(
      tester,
      cardNumberBuilder: (brand, cardLastFourDigits, hasError) =>
          Text(key: const ValueKey('last-four-digits'), cardLastFourDigits),
      decorationBuilder: (hasFocus, hasError) => const BoxDecoration(),
      cardNumberHint: 'Enter your Card Number',
    );
    await enterCardNumber(tester, cardNumber: '1');
    expect(find.text('Enter your Card Number'), findsOneWidget);
  });

  testWidgets(
      'should expand the card number again after being clicked while being colapsed',
      (tester) async {
    await pumpFancyCreditCardInput(
      tester,
      cardNumberBuilder: (brand, cardLastFourDigits, hasError) =>
          Text(key: const ValueKey('last-four-digits'), cardLastFourDigits),
      decorationBuilder: (hasFocus, hasError) => const BoxDecoration(),
    );
    await enterCardNumber(tester, cardNumber: '4111111111111234');
    await enterExpiry(tester, expiry: '1225');
    final lastFourDigits = find.byKey(const ValueKey('last-four-digits'));
    await tester.tap(lastFourDigits);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('4111 1111 1111 1234'), findsOneWidget);
  });

  testWidgets('should call error builder showing error when validates',
      (tester) async {
    await pumpFancyCreditCardInput(
      tester,
      cardNumberBuilder: (brand, cardLastFourDigits, hasError) =>
          Text(cardLastFourDigits),
      decorationBuilder: (hasFocus, hasError) => const BoxDecoration(),
      errorBuilder: (errorMessage) => const Text('Error'),
    );
    await enterCardNumber(tester, cardNumber: '41');
    expect(find.text('Error'), findsOneWidget);
  });

  testWidgets(
      'should populate initial values including cvv and set card brand and call onFormCompleted',
      (tester) async {
    CardBrand? capturedBrand;
    CardData? completedCardData;

    await pumpFancyCreditCardInput(
      tester,
      cardNumberInitialValue: '4111 1111 1111 1234',
      expiryMonthInitialValue: 12,
      expiryYearInitialValue: 25,
      cvvInitialValue: '123',
      cardNumberBuilder: (brand, cardLastFourDigits, hasError) {
        capturedBrand = brand;
        return Text(cardLastFourDigits);
      },
      decorationBuilder: (hasFocus, hasError) => const BoxDecoration(),
      onFormCompleted: (cardData) {
        completedCardData = cardData;
      },
    );
    await tester.pumpAndSettle();

    expect(capturedBrand, CardBrand.visa);
    expect(find.byType(TextField), findsNWidgets(2)); // expiry and cvv
    final cvvField = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(cvvField.controller?.text, '123');
    expect(completedCardData?.cvv, '123');
  });

  testWidgets(
      'should update cvv and trigger onFormCompleted when cvvInitialValue is updated via widget update',
      (tester) async {
    CardData? completedCardData;

    Widget buildWidget(String? cvv) => MaterialApp(
          home: Scaffold(
            body: FancyCreditCardInput(
              cardNumberInitialValue: '4111 1111 1111 1234',
              expiryMonthInitialValue: 12,
              expiryYearInitialValue: 25,
              cvvInitialValue: cvv,
              cardNumberBuilder: (brand, cardLastFourDigits, hasError) =>
                  Text(cardLastFourDigits),
              decorationBuilder: (hasFocus, hasError) => const BoxDecoration(),
              onFormCompleted: (cardData) {
                completedCardData = cardData;
              },
            ),
          ),
        );

    await tester.pumpWidget(buildWidget(null));
    await tester.pumpAndSettle();

    expect(completedCardData, isNull);

    // Update with CVV in edit context
    await tester.pumpWidget(buildWidget('456'));
    await tester.pumpAndSettle();

    final cvvField = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(cvvField.controller?.text, '456');
    expect(completedCardData?.cvv, '456');
  });
}

