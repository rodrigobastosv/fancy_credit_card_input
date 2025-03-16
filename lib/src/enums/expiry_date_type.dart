enum ExpiryDateType {
  regular('##/##', 4),
  fullYear('##/####', 6);

  const ExpiryDateType(this.value, this.length);

  final String value;
  final int length;
}
