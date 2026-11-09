import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:savemed/core/services/shipping_service.dart';

void main() {
  test('posts the pharmacy, address, and product quote contract', () async {
    String? requestedPath;
    Map? requestBody;
    final service = ShippingService(
      post: (path, body) async {
        requestedPath = path;
        requestBody = body;
        return http.Response(
          jsonEncode([
            {'id': 'carrier-1', 'method': 'shipping', 'price': '12.50'},
          ]),
          200,
        );
      },
    );

    final options = await service.quote(
      pharmacyId: 7,
      fromCep: '01001000',
      toCep: '02002000',
      destinationAddress: const {'postal_code': '02002000'},
      products: const [
        {'id': 'box-1', 'quantity': 1},
      ],
    );

    expect(requestedPath, '/shipping/quote');
    expect(requestBody, {
      'pharmacyId': 7,
      'from': {'postal_code': '01001000'},
      'to': {'postal_code': '02002000'},
      'destinationAddress': {'postal_code': '02002000'},
      'products': [
        {'id': 'box-1', 'quantity': 1},
      ],
    });
    expect(options.single['price'], '12.50');
  });

  test('ignores explicitly unpriced rows and preserves valid quotes', () async {
    final service = ShippingService(
      post: (_, _) async => http.Response(
        jsonEncode([
          {'id': 'unavailable'},
          {'id': 'pickup', 'price': 0},
        ]),
        200,
      ),
    );

    final options = await _quote(service);

    expect(options, hasLength(1));
    expect(options.single['id'], 'pickup');
  });

  test('rejects malformed rows instead of silently dropping them', () async {
    final service = ShippingService(
      post: (_, _) async => http.Response(jsonEncode([null]), 200),
    );

    await expectLater(_quote(service), throwsA(isA<ShippingQuoteException>()));
  });

  for (final invalidPrice in [
    'not-a-price',
    -1,
    {'amount': 10},
    'NaN',
    'Infinity',
  ]) {
    test('rejects invalid shipping price $invalidPrice', () async {
      final service = ShippingService(
        post: (_, _) async => http.Response(
          jsonEncode([
            {'id': 'valid', 'price': 5},
            {'id': 'invalid', 'price': invalidPrice},
          ]),
          200,
        ),
      );

      await expectLater(
        _quote(service),
        throwsA(isA<ShippingQuoteException>()),
      );
    });
  }
}

Future<List<Map<String, dynamic>>> _quote(ShippingService service) =>
    service.quote(
      pharmacyId: 7,
      fromCep: '01001000',
      toCep: '02002000',
      destinationAddress: const {'postal_code': '02002000'},
      products: const [
        {'id': 'box-1', 'quantity': 1},
      ],
    );
