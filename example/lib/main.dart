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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FancyCreditCardInput(
                  onFormCompleted: (cardData) {
                    // ignore: avoid_print
                    print(cardData);
                  },
                  cardNumberBuilder: (brand, cardLastFourDigits) => Row(
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
                ),
              ],
            ),
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
