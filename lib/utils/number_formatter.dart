import 'package:intl/intl.dart';

class NumberFormatter {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'es',
    symbol: '\$',
    decimalDigits: 2,
  );

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }
}