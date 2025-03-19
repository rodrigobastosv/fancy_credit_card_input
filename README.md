[![codecov](https://codecov.io/gh/rodrigobastosv/fancy_credit_card_input/graph/badge.svg?token=o49uk7o6iw)](https://codecov.io/gh/rodrigobastosv/fancy_credit_card_input)

<a href="https://www.buymeacoffee.com/rodrigobastosv" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

Have you ever wanted a Credit Card input component that has everything you need? fancy_credit_card_input have everything you need in a highly customizable component.

![Demo](https://github.com/rodrigobastosv/fancy_credit_card_input/blob/main/docs/recording.gif?raw=true)

## Features
- Nice colapsing animation when the card number is filled
- Support for next focus to make it easier to input all the fields 
- Automatic brand detection while typing the card number
- You can pass validators to all your inputs (Card Number, Expiry Date, CVV)

## Getting started

Using the component is just as simple as:

```dart
FancyCreditCardInput(
    onFormCompleted: (cardData) {
        print(cardData);
    },
    cardNumberBuilder: (brand, cardLastFourDigits) => Row(
        children: [
            _buildCardBrand(brand),
            Text('•••• $cardLastFourDigits', style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 12),
        ],
    ),
    decorationBuilder: (hasFocus, hasError) => BoxDecoration(
        color: hasError ? const Color(0xFFF8E9E9) : null,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(color: _getBorderColor(hasFocus, hasError)),
    ),
)
```

The component relies a lot in using builders so it can be as much customizable as possible.

Pretty much everything can be customizable.

## Suggestions & Bugs

For any suggestions or bug report please head to [issue tracker][tracker].

[tracker]: https://github.com/rodrigobastosv/fancy_credit_card_input/issues

