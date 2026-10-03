import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/controllers/order_controller.dart';
import 'package:savemed/core/services/order_service.dart';
import 'package:savemed/core/services/shipping_service.dart';
import 'package:savemed/models/customer_order.dart';

void main() {
  for (final invalidPrice in <Object?>[
    null,
    'invalid',
    -1,
    'NaN',
    'Infinity',
  ]) {
    test(
      'does not create an order with invalid shipping price $invalidPrice',
      () async {
        final service = _OrderService();
        final controller = OrderController(service: service);
        addTearDown(controller.dispose);

        await expectLater(
          controller.createOrder(
            customerId: 1,
            pharmacyId: 2,
            shipping: {'price': invalidPrice, 'method': 'shipping'},
            subtotal: 10,
            items: const [],
          ),
          throwsA(isA<ShippingQuoteException>()),
        );

        expect(service.checkoutCalls, 0);
        expect(controller.loading, isFalse);
        expect(controller.currentOrderId, isNull);
      },
    );
  }

  test('passes a validated numeric shipping amount to checkout', () async {
    final service = _OrderService();
    final controller = OrderController(service: service);
    addTearDown(controller.dispose);

    final orderId = await controller.createOrder(
      customerId: 1,
      pharmacyId: 2,
      shipping: {
        'price': '12.50',
        'method': 'shipping',
        'company': {'name': 'Transportadora'},
        'name': 'Entrega expressa',
      },
      subtotal: 10,
      items: const [],
    );

    expect(orderId, 42);
    expect(service.checkoutCalls, 1);
    expect(service.shippingPrice, 12.5);
    expect(service.deliveryLabel, 'Transportadora - Entrega expressa');
    expect(controller.loading, isFalse);
  });
}

class _OrderService extends OrderService {
  int checkoutCalls = 0;
  double? shippingPrice;
  String? deliveryLabel;

  @override
  Future<int> checkout({
    required int customerId,
    required int pharmacyId,
    int? addressId,
    required double shippingPrice,
    required String deliveryMethod,
    String? deliveryLabel,
    required double subtotal,
    required List<Map<String, num>> items,
  }) async {
    checkoutCalls++;
    this.shippingPrice = shippingPrice;
    this.deliveryLabel = deliveryLabel;
    return 42;
  }

  @override
  Future<List<CustomerOrder>> getOrdersByCustomer(int customerId) async => [];
}
