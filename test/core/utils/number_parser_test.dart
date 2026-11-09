import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/utils/number_parser.dart';

void main() {
  test('parses finite numeric values and rejects invalid values', () {
    expect(parseFiniteNumber(12), 12.0);
    expect(parseFiniteNumber('12.5'), 12.5);
    expect(parseFiniteNumber('invalid'), isNull);
    expect(parseFiniteNumber(double.nan), isNull);
    expect(parseFiniteNumber(double.infinity), isNull);
    expect(parseFiniteNumber(double.negativeInfinity), isNull);
    expect(parseFiniteNumber('NaN'), isNull);
    expect(parseFiniteNumber('Infinity'), isNull);
  });
}
