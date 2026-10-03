import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/models/customer_order.dart';

void main() {
  test('parses the customer order boundary with nested items', () {
    final order = CustomerOrder.fromJson({
      'ID': '42',
      'STATUS': 'confirmed',
      'PAYMENT_STATUS': 'paid',
      'TOTAL_AMOUNT': '31.50',
      'CREATED_AT': '2026-09-04T10:00:00.000Z',
      'customer': {'ID': 7, 'NAME': 'Maria Cliente'},
      'pharmacy': {'NAME': 'Farmacia Central'},
      'items': [
        {
          'QUANTITY': '2',
          'TOTAL_PRICE': '31.50',
          'inventory': {
            'medication': {'NAME': 'Produto teste'},
          },
        },
      ],
    });

    expect(order.id, 42);
    expect(order.totalAmount, 31.5);
    expect(order.pharmacyName, 'Farmacia Central');
    expect(order.customerName, 'Maria Cliente');
    expect(order.items.single.productName, 'Produto teste');
    expect(order.items.single.quantity, 2);
  });

  test('does not expose non-finite order amounts', () {
    final order = CustomerOrder.fromJson({
      'ID': 42,
      'TOTAL_AMOUNT': 'Infinity',
      'items': [
        {'QUANTITY': 1, 'TOTAL_PRICE': double.nan},
      ],
    });

    expect(order.totalAmount, 0);
    expect(order.items.single.totalPrice, 0);
  });
}
