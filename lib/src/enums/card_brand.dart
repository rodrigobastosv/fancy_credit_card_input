enum CardBrand {
  visa(r'^4', 'icons/visa.svg'),
  mastercard(r'^(51|52|53|54|55|2221|2720)', 'icons/mastercard.svg'),
  amex(r'^(34|37)', 'icons/amex.svg'),
  discover(r'^(6011|65|644|645|646|647|648|649)', 'icons/discover.svg'),
  dinersClub(r'^(36|38|39)', 'icons/diners.svg'),
  jcb(r'^(35)', 'icons/jcb.svg'),
  unionPay(r'^(62)', 'icons/unionpay.svg'),
  unknown(r'', 'icons/unknown.svg');

  const CardBrand(this.regExp, this.logoAsset);
  final String regExp;
  final String logoAsset;

  static CardBrand fromCardNumber(String cardNumber) {
    for (final brand in CardBrand.values) {
      final regExp = RegExp(brand.regExp);
      if (regExp.hasMatch(cardNumber)) {
        return brand;
      }
    }
    return CardBrand.unknown;
  }
}
