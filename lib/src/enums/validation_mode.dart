/// Defines when the credit card input fields should be validated.
enum ValidationMode {
  /// Validates the fields on every change.
  always,

  /// Validates each field only when it loses focus.
  onUnfocus,
}
