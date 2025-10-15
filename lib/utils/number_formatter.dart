import 'package:intl/intl.dart';

/// Utility class for formatting numbers and currency values.
///
/// Provides consistent formatting for monetary amounts throughout
/// the application using Spanish locale conventions.
class NumberFormatter {
  /// Private currency formatter with Spanish locale settings.
  ///
  /// Configured with dollar symbol and 2 decimal places for
  /// consistent currency display.
  static final _currencyFormat = NumberFormat.currency(
    locale: 'es',
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Formats a monetary amount as currency string.
  ///
  /// Converts the [amount] to a localized currency string with
  /// appropriate symbol and decimal formatting.
  ///
  /// Example:
  /// ```dart
  /// NumberFormatter.formatCurrency(1234.56); // Returns "\$1.234,56"
  /// ```
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }
}