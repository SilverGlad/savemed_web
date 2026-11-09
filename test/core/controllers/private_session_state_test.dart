import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/controllers/order_controller.dart';
import 'package:savemed/core/services/order_service.dart';
import 'package:savemed/core/storage/card_storage.dart';
import 'package:savemed/core/storage/token_storage.dart';
import 'package:savemed/models/customer_order.dart';
import 'package:savemed/models/inventory_item.dart';
import 'package:savemed/models/medication.dart';
import 'package:savemed/models/pharmacy.dart';
import 'package:savemed/models/postal_address.dart';
import '../../support/in_memory_token_vault.dart';

void main() {
  setUp(() {
    TokenStorage.resetForTesting();
    TokenStorage.setVaultForTesting(InMemoryTokenVault());
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'logout clears cart and order history; late order response is ignored',
    () async {
      SharedPreferences.setMockInitialValues({});
      await CardStorage.clear();
      final request = Completer<List<CustomerOrder>>();
      final service = _OrderService(request: request);
      final cart = CartController();
      final orders = OrderController(service: service);
      final auth = AuthController(cart: cart, orders: orders);
      addTearDown(cart.dispose);
      addTearDown(orders.dispose);
      addTearDown(auth.dispose);

      cart.addItem(_item());
      cart.selectAddress(PostalAddress.fromJson({'ID': 1, 'CEP': '01001000'}));
      cart.selectShipping({'id': 'pickup', 'method': 'pickup', 'price': 0});
      orders.currentOrderId = 42;
      orders.currentOrder = _order(42);
      final load = orders.load(1);
      await auth.logout();
      expect(cart.items, isEmpty);
      expect(cart.selectedAddress, isNull);
      expect(cart.selectedShipping, isNull);
      expect(cart.pharmacyId, isNull);
      expect(orders.orders, isEmpty);
      expect(orders.currentOrder, isNull);
      expect(orders.currentOrderId, isNull);
      expect(orders.loading, isFalse);

      request.complete([_order(99)]);
      await load;
      expect(orders.orders, isEmpty);
    },
  );

  test(
    'late checkout completion after logout cannot return an order id',
    () async {
      SharedPreferences.setMockInitialValues({});
      await CardStorage.clear();
      final checkoutRequest = Completer<int>();
      final cart = CartController();
      final orders = OrderController(
        service: _OrderService(checkoutRequest: checkoutRequest),
      );
      final auth = AuthController(cart: cart, orders: orders);
      addTearDown(cart.dispose);
      addTearDown(orders.dispose);
      addTearDown(auth.dispose);
      final create = expectLater(
        orders.createOrder(
          customerId: 1,
          pharmacyId: 2,
          shipping: {'price': 0, 'method': 'pickup'},
          subtotal: 0,
          items: const [],
        ),
        throwsStateError,
      );
      await auth.logout();
      checkoutRequest.complete(91);
      await create;
      expect(orders.currentOrderId, isNull);
      expect(orders.currentOrder, isNull);
      expect(orders.loading, isFalse);
    },
  );
}

class _OrderService extends OrderService {
  final Completer<List<CustomerOrder>>? request;
  final Completer<int>? checkoutRequest;
  _OrderService({this.request, this.checkoutRequest});
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
  }) => checkoutRequest!.future;
  @override
  Future<List<CustomerOrder>> getOrdersByCustomer(int customerId) =>
      request!.future;
}

CustomerOrder _order(int id) => CustomerOrder(
  id: id,
  status: 'pending',
  paymentStatus: 'pending',
  totalAmount: 10,
  createdAt: null,
  pharmacyName: 'Teste',
  items: const [],
);

InventoryItem _item() => InventoryItem(
  id: 1,
  price: 10,
  originalPrice: 10,
  stock: 2,
  pharmacy: const Pharmacy(id: 1, name: 'Teste'),
  medication: const Medication(
    id: 1,
    name: 'Teste',
    description: 'Teste',
    categoryId: 1,
    requiresPrescription: false,
  ),
);
