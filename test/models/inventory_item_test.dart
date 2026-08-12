import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/models/inventory_item.dart';

void main() {
  test('parses production inventory with an optional subcategory', () {
    final item = InventoryItem.fromJson({
      'ID': 10,
      'PRICE': '79.90',
      'ORIGINAL_PRICE': '79.90',
      'STOCK': 1,
      'Pharmacy': {'ID': 2, 'NAME': 'Farmacia'},
      'Medication': {
        'ID': 14,
        'NAME': 'Tegum',
        'DESCRIPTION': 'Produto sem subcategoria',
        'CATEGORY_ID': 10,
        'SUBCATEGORY_ID': null,
        'REQUIRES_RX': true,
        'IMAGE': null,
      },
    });

    expect(item.id, 10);
    expect(item.medication.subcategoryId, isNull);
    expect(item.medication.requiresPrescription, isTrue);
  });

  test('accepts numeric fields represented as strings', () {
    final item = InventoryItem.fromJson({
      'ID': '8',
      'PRICE': '0.99',
      'ORIGINAL_PRICE': null,
      'STOCK': '42',
      'Pharmacy': {'ID': 2, 'NAME': 'Farmacia'},
      'Medication': {
        'ID': '8',
        'NAME': 'Creme dental',
        'DESCRIPTION': null,
        'CATEGORY_ID': '3',
        'SUBCATEGORY_ID': '9',
      },
    });

    expect(item.price, 0.99);
    expect(item.originalPrice, 0.99);
    expect(item.stock, 42);
    expect(item.medication.description, isEmpty);
    expect(item.medication.subcategoryId, 9);
  });
}
