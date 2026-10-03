import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:savemed/core/api/api_response.dart';
import 'package:savemed/core/services/order_service.dart';

void main() {
  test('uses the transactional checkout contract', () async {
    String? requestedPath;
    Map? requestedBody;
    final service = OrderService(
      post: (path, body) async {
        requestedPath = path;
        requestedBody = body;
        return http.Response(
          jsonEncode({
            'order': {'ID': 42},
            'items': [],
          }),
          201,
        );
      },
    );

    final orderId = await service.checkout(
      customerId: 2,
      pharmacyId: 3,
      addressId: 4,
      shippingPrice: 9.5,
      deliveryMethod: 'shipping',
      subtotal: 20,
      items: [
        {'inventoryId': 7, 'quantity': 2, 'price': 10},
      ],
    );

    expect(orderId, 42);
    expect(requestedPath, '/orders/checkout');
    expect(requestedBody?['EXPECTED_SUBTOTAL'], 20);
    expect(requestedBody?['ITEMS'], [
      {'INVENTORY_ID': 7, 'QUANTITY': 2},
    ]);
  });

  for (final unavailableStatus in [404, 405]) {
    test(
      'does not create partial orders when transactional checkout returns $unavailableStatus',
      () async {
        final requestedPaths = <String>[];
        final service = OrderService(
          post: (path, _) async {
            requestedPaths.add(path);
            return http.Response('{}', unavailableStatus);
          },
        );

        await expectLater(
          service.checkout(
            customerId: 2,
            pharmacyId: 3,
            shippingPrice: 0,
            deliveryMethod: 'pickup',
            subtotal: 25,
            items: [
              {'inventoryId': 7, 'quantity': 1, 'price': 25},
            ],
          ),
          throwsA(
            isA<ApiResponseException>().having(
              (error) => error.statusCode,
              'status code',
              unavailableStatus,
            ),
          ),
        );

        expect(requestedPaths, ['/orders/checkout']);
      },
    );
  }
}
