import 'package:flutter/material.dart';
import 'package:savemed/core/services/shipping_service.dart';
import 'package:savemed/core/utils/money_formatter.dart';
import 'package:savemed/models/cart_item.dart';
import 'package:savemed/models/customer_order.dart';

import '../services/order_service.dart';

class OrderController extends ChangeNotifier {
  final OrderService _service;
  int _generation = 0;

  OrderController({OrderService? service})
    : _service = service ?? OrderService();

  void clear() {
    _generation++;
    orders = [];
    currentOrderId = null;
    currentOrder = null;
    loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }

  bool loading = false;
  List<CustomerOrder> orders = [];
  int? currentOrderId;
  CustomerOrder? currentOrder;

  Future<int> createOrder({
    required int customerId,
    required int pharmacyId,
    int? addressId,
    required Map<String, dynamic> shipping,
    required double subtotal,
    required List<CartItem> items,
  }) async {
    final generation = ++_generation;
    loading = true;
    notifyListeners();

    try {
      final shippingPrice = parseNonNegativeFiniteAmount(shipping['price']);
      if (shippingPrice == null) {
        throw const ShippingQuoteException(
          'A cotação de frete está inválida. Volte ao carrinho e calcule o frete novamente.',
        );
      }
      final deliveryMethod = shipping['method']?.toString() ?? 'shipping';
      final companyName = shipping['company']?['name']?.toString();
      final serviceName = shipping['name']?.toString();
      final deliveryLabel = [
        companyName,
        serviceName,
      ].whereType<String>().where((value) => value.isNotEmpty).join(' - ');

      final id = await _service.checkout(
        customerId: customerId,
        pharmacyId: pharmacyId,
        addressId: addressId,
        shippingPrice: shippingPrice,
        deliveryMethod: deliveryMethod,
        deliveryLabel: deliveryLabel.isEmpty ? null : deliveryLabel,
        subtotal: subtotal,
        items: items
            .map(
              (item) => {
                'inventoryId': item.item.id,
                'quantity': item.quantity,
                'price': item.item.price,
              },
            )
            .toList(),
      );
      if (generation != _generation) {
        throw StateError('A sessão foi encerrada durante a criação do pedido.');
      }
      currentOrderId = id;
      return id;
    } catch (_) {
      if (generation == _generation) rethrow;
      throw StateError('A sessão foi encerrada durante a criação do pedido.');
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> load(int customerId) async {
    final generation = ++_generation;
    loading = true;
    notifyListeners();

    try {
      final loaded = await _service.getOrdersByCustomer(customerId);
      if (generation != _generation) return;
      orders = loaded;
    } catch (_) {
      if (generation == _generation) rethrow;
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadOrderDetail(int orderId) async {
    final generation = ++_generation;
    loading = true;
    notifyListeners();

    try {
      final loaded = await _service.getOrderDetail(orderId);
      if (generation != _generation) return;
      currentOrder = loaded;
    } catch (_) {
      if (generation == _generation) rethrow;
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }
}
