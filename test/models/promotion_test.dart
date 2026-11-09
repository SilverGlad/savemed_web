import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/models/promotion.dart';

void main() {
  test('parses promotion contract with lowercase associations', () {
    final promotion = Promotion.fromJson({
      'ID': 3,
      'PHARMACY_ID': '9',
      'MEDICATION_ID': 12,
      'DISCOUNT_PERCENTAGE': '15.5',
      'START_DATE': '2026-08-01',
      'END_DATE': '2026-08-31',
      'medication': {'NAME': 'Vitamina C'},
      'pharmacy': {'NAME': 'Farmacia Central'},
      'HIGHLIGHT_IMAGE': [1, 2, 3],
    });

    expect(promotion.id, 3);
    expect(promotion.productName, 'Vitamina C');
    expect(promotion.pharmacyName, 'Farmacia Central');
    expect(promotion.discountPercentage, 15.5);
    expect(promotion.hasImage, isTrue);
  });

  test('rejects non-finite discount values', () {
    expect(
      () => Promotion.fromJson({
        'ID': 3,
        'PHARMACY_ID': 9,
        'MEDICATION_ID': 12,
        'DISCOUNT_PERCENTAGE': double.nan,
        'START_DATE': '2026-08-01',
        'END_DATE': '2026-08-31',
      }),
      throwsFormatException,
    );
  });
}
