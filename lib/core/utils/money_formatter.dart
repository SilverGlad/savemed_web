import 'package:intl/intl.dart';
import 'number_parser.dart';

final NumberFormat _brlFormatter = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: r'R$',
);

double? parseLocalizedNumber(Object? value) {
  if (value is num) return parseFiniteNumber(value);
  var text = value?.toString().trim() ?? '';
  if (text.isEmpty) return null;

  if (text.contains(',')) {
    text = text.replaceAll('.', '').replaceAll(',', '.');
  }
  return parseFiniteNumber(text);
}

double? parseNonNegativeFiniteAmount(Object? value) {
  final amount = parseLocalizedNumber(value);
  if (amount == null || !amount.isFinite || amount < 0) return null;
  return amount;
}

String formatBrl(Object? value, {String fallback = r'R$ 0,00'}) {
  final number = parseLocalizedNumber(value);
  return number == null ? fallback : _brlFormatter.format(number);
}
