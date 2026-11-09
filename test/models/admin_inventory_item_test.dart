import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/models/admin_inventory_item.dart';

void main() {
  test('parses administrative inventory aliases and nested product', () {
    final item = AdminInventoryItem.fromJson({
      'ID': '8',
      'PHARMACY_ID': 2,
      'MEDICATION_ID': '5',
      'PRICE': '19.90',
      'ORIGINAL_PRICE': 24.9,
      'STOCK': '4',
      'Medication': {'NAME': 'Produto teste', 'UNIT': 'caixa'},
      'UPDATED_AT': '2026-08-21T10:00:00.000Z',
    });

    expect(item.id, 8);
    expect(item.medicationName, 'Produto teste');
    expect(item.unit, 'caixa');
    expect(item.price, 19.9);
    expect(item.stock, 4);
    expect(item.updatedAt, isNotNull);
  });

  test('rejects non-finite inventory prices', () {
    expect(
      () => AdminInventoryItem.fromJson({
        'ID': 8,
        'PHARMACY_ID': 2,
        'MEDICATION_ID': 5,
        'PRICE': double.infinity,
        'STOCK': 1,
      }),
      throwsFormatException,
    );
  });
}
