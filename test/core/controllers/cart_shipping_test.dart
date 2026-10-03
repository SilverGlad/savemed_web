import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/services/shipping_service.dart';
import 'package:savemed/models/inventory_item.dart';
import 'package:savemed/models/medication.dart';
import 'package:savemed/models/pharmacy.dart';
import 'package:savemed/models/postal_address.dart';

void main() {
  for (final mutation in ['add', 'increase', 'decrease', 'remove']) {
    test('$mutation invalidates a quote for the previous products', () async {
      final service = _Service();
      final cart = _cart(service);
      addTearDown(cart.dispose);
      cart.addItem(cart.items.single.item);
      final request = cart.calculateShipping('01001000');
      final revision = cart.shippingInputRevision;
      final item = cart.items.single;
      switch (mutation) {
        case 'add':
          cart.addItem(item.item);
        case 'increase':
          cart.increase(item);
        case 'decrease':
          cart.decrease(item);
        case 'remove':
          cart.remove(item);
      }
      expect(cart.shippingInputRevision, greaterThan(revision));
      service.requests.single.complete([
        {'id': 'obsolete', 'price': 10},
      ]);
      await request;
      expect(cart.shippingOptions, isEmpty);
      expect(cart.selectedShipping, isNull);
      expect(cart.loadingShipping, isFalse);
    });
  }

  test(
    'quantity change clears selected delivery but preserves pickup',
    () async {
      final service = _Service();
      final cart = _cart(service);
      addTearDown(cart.dispose);
      cart.selectShipping({
        'id': 'delivery',
        'method': 'own_delivery',
        'price': 10,
      });
      cart.increase(cart.items.single);
      expect(cart.selectedShipping, isNull);
      cart.selectShipping(cart.localDeliveryOptions.single);
      cart.decrease(cart.items.single);
      expect(cart.isPickupSelected, isTrue);
      final request = cart.calculateShipping('01001000');
      expect(cart.isPickupSelected, isTrue);
      service.requests.single.complete([
        {'id': 'delivery', 'price': 10},
      ]);
      await request;
      expect(cart.isPickupSelected, isTrue);
    },
  );

  test(
    'invalid quote price stays an error and cannot become free delivery',
    () async {
      final cart = _cart(
        ShippingService(
          post: (_, _) async => http.Response(
            jsonEncode([
              {'id': 'invalid', 'method': 'shipping', 'price': 'unknown'},
            ]),
            200,
          ),
        ),
      );
      addTearDown(cart.dispose);

      await cart.calculateShipping('01001000');

      expect(cart.shippingOptions, isEmpty);
      expect(cart.selectedShipping, isNull);
      expect(
        cart.shippingError,
        'Uma opção de frete retornou um preço inválido.',
      );
      expect(cart.loadingShipping, isFalse);
    },
  );

  for (final clearCart in [false, true]) {
    test(
      'clearing ${clearCart ? "cart" : "address"} invalidates pending shipping',
      () async {
        final service = _Service();
        final cart = _cart(service);
        addTearDown(cart.dispose);
        final request = cart.calculateShipping('01001000');
        if (clearCart) {
          cart.clear();
        } else {
          cart.clearAddress();
        }
        expect(cart.loadingShipping, isFalse);
        service.requests.single.complete([
          {'id': 'old', 'price': 10},
        ]);
        await request;
        expect(cart.shippingOptions, isEmpty);
        expect(cart.selectedShipping, isNull);
        expect(cart.shippingError, isNull);
      },
    );
  }
  for (final fails in [false, true]) {
    test('old quote does not change a newer quote (fails: $fails)', () async {
      final service = _Service();
      final cart = _cart(service);
      addTearDown(cart.dispose);
      final old = cart.calculateShipping('01001000');
      cart.selectAddress(PostalAddress.fromJson({'ID': 2, 'CEP': '02002000'}));
      final current = cart.calculateShipping('01001000');
      if (fails) {
        service.requests[0].completeError(
          const ShippingQuoteException('old failure'),
        );
      } else {
        service.requests[0].complete([
          {'id': 'old', 'price': 10},
        ]);
      }
      await old;
      expect(cart.loadingShipping, isTrue);
      expect(cart.shippingOptions, isEmpty);
      expect(cart.shippingError, isNull);
      service.requests[1].complete([
        {'id': 'current', 'price': 20},
      ]);
      await current;
      expect(cart.loadingShipping, isFalse);
      expect(cart.shippingOptions.single['id'], 'current');
    });
  }
  test('disposed cart ignores late shipping completion', () async {
    final service = _Service();
    final cart = _cart(service);
    final request = cart.calculateShipping('01001000');
    cart.dispose();
    service.requests.single.complete([
      {'id': 'old', 'price': 10},
    ]);
    await request;
    expect(cart.shippingOptions, isEmpty);
  });
}

CartController _cart(ShippingService service) =>
    CartController(shippingService: service)
      ..addItem(
        InventoryItem(
          id: 1,
          price: 10,
          originalPrice: 10,
          stock: 5,
          pharmacy: const Pharmacy(
            id: 1,
            name: 'Farmacia teste',
            acceptsPickup: true,
          ),
          medication: const Medication(
            id: 1,
            name: 'Produto teste',
            description: 'Teste',
            categoryId: 1,
            requiresPrescription: false,
          ),
        ),
      )
      ..selectAddress(PostalAddress.fromJson({'ID': 1, 'CEP': '01002000'}));

class _Service extends ShippingService {
  final requests = <Completer<List<Map<String, dynamic>>>>[];
  @override
  Future<List<Map<String, dynamic>>> quote({
    required int pharmacyId,
    required String fromCep,
    required String toCep,
    required Map<String, dynamic> destinationAddress,
    required List<Map<String, dynamic>> products,
  }) {
    final request = Completer<List<Map<String, dynamic>>>();
    requests.add(request);
    return request.future;
  }
}
