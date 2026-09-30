import 'package:fancy_credit_card_input/fancy_credit_card_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fancy Credit Card Input'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Default',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              FancyCreditCardInput(
                onFormCompleted: (cardData) {
                  // ignore: avoid_print
                  print(cardData);
                },
                onChangedCardNumber: print,
                onChangedExpiryDate: print,
                onChangedCvv: print,
                cardNumberBuilder: (brand, cardLastFourDigits, hasError) => Row(
                  children: [
                    _buildCardBrand(brand),
                    Text('•••• $cardLastFourDigits',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 12),
                  ],
                ),
                decorationBuilder: (hasFocus, hasError) => BoxDecoration(
                  color: hasError ? const Color(0xFFF8E9E9) : null,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border:
                      Border.all(color: _getBorderColor(hasFocus, hasError)),
                ),
                errorBuilder: (errorMessage) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                cardNumberHint: 'Enter card number',
                expiryHint: 'MM/YY',
                cvvHint: 'CVV',
                supportedCardLengths: const [15, 16, 19],
              ),
              const SizedBox(height: 32),
              const Text(
                'Saved Card (editing flow)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              FancySavedCreditCardInput(
                cardBrand: CardBrand.visa,
                cardNumber: '•••• •••• •••• 4242',
                expiryMonthInitialValue: 12,
                expiryYearInitialValue: 26,
                cvvInitialValue: '123',
                onFormCompleted: (cardData) {
                  // ignore: avoid_print
                  print(cardData);
                },
                onChangedExpiryDate: print,
                onChangedCvv: print,
                cardNumberBuilder: (brand, cardLastFourDigits, hasError) => Row(
                  children: [
                    _buildCardBrand(brand),
                    Text('•••• $cardLastFourDigits',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 12),
                  ],
                ),
                decorationBuilder: (hasFocus, hasError) => BoxDecoration(
                  color: hasError ? const Color(0xFFF8E9E9) : null,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border:
                      Border.all(color: _getBorderColor(hasFocus, hasError)),
                ),
                errorBuilder: (errorMessage) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                expiryHint: 'MM/YY',
                cvvHint: 'CVV',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(bool hasFocus, bool hasError) {
    if (hasError) {
      return Colors.red;
    }

    if (hasFocus) {
      return Colors.green;
    }

    return const Color(0xFF000000);
  }

  Widget _buildCardBrand(CardBrand cardBrand) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: SvgPicture.asset(
          cardBrand.logoAsset,
          height: 24,
          fit: BoxFit.scaleDown,
          package: 'fancy_credit_card_input',
        ),
      );
}
