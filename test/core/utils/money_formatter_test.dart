import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/utils/money_formatter.dart';

void main() {
  test('parses API and Brazilian decimal representations', () {
    expect(parseLocalizedNumber(12.5), 12.5);
    expect(parseLocalizedNumber('12.50'), 12.5);
    expect(parseLocalizedNumber('1.234,56'), 1234.56);
    expect(parseLocalizedNumber('invalido'), isNull);
    expect(parseLocalizedNumber('NaN'), isNull);
    expect(parseLocalizedNumber('Infinity'), isNull);
    expect(parseLocalizedNumber(double.nan), isNull);
    expect(parseLocalizedNumber(double.infinity), isNull);
    expect(parseLocalizedNumber(double.negativeInfinity), isNull);
  });

  test('formats monetary values in Brazilian notation', () {
    final formatted = formatBrl('1234.5');
    expect(formatted, contains(r'R$'));
    expect(formatted, contains('1.234,50'));
    expect(formatBrl(null), r'R$ 0,00');
  });

  test('strict amount parser rejects negative and non-finite values', () {
    expect(parseNonNegativeFiniteAmount(12.5), 12.5);
    expect(parseNonNegativeFiniteAmount('12,50'), 12.5);
    expect(parseNonNegativeFiniteAmount(0), 0);
    expect(parseNonNegativeFiniteAmount(-1), isNull);
    expect(parseNonNegativeFiniteAmount('NaN'), isNull);
    expect(parseNonNegativeFiniteAmount('Infinity'), isNull);
    expect(parseNonNegativeFiniteAmount('invalid'), isNull);
  });
}
