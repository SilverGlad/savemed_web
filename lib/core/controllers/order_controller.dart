import 'package:flutter/material.dart';
import 'package:SaveMed/core/utils/input_formatters.dart';
import 'package:SaveMed/models/cart_item.dart';

import '../services/order_service.dart';

class OrderController extends ChangeNotifier {
  final _service = OrderService();

  bool loading = false;
  List<dynamic> orders = [];
  int? currentOrderId;
  Map<String, dynamic>? currentOrder;

  Future<int> createOrder({
    required int customerId,
    required int pharmacyId,
    int? addressId,
    required Map<String, dynamic> shipping,
    required double subtotal,
  }) async {
    loading = true;
    notifyListeners();

    final shippingPrice = toDouble(shipping['price']);
    final total = subtotal + shippingPrice;
    final deliveryMethod = shipping['method']?.toString() ?? 'shipping';
    final companyName = shipping['company']?['name']?.toString();
    final serviceName = shipping['name']?.toString();
    final deliveryLabel = [
      companyName,
      serviceName,
    ].whereType<String>().where((value) => value.isNotEmpty).join(' - ');

    final id = await _service.createOrder(
      customerId: customerId,
      pharmacyId: pharmacyId,
      addressId: addressId,
      shippingPrice: shippingPrice,
      deliveryMethod: deliveryMethod,
      deliveryLabel: deliveryLabel.isEmpty ? null : deliveryLabel,
      subtotal: subtotal,
      total: total,
    );

    currentOrderId = id;

    loading = false;
    notifyListeners();
    return id;
  }

  Future<void> createOrderItems(int orderId, List<CartItem> items) async {
    for (final item in items) {
      await _service.createOrderItem(
        orderId: orderId,
        inventoryId: item.item.id,
        quantity: item.quantity,
        price: item.item.price,
      );
    }
  }

  Future<void> load(int customerId) async {
    loading = true;
    notifyListeners();

    orders = await _service.getOrdersByCustomer(customerId);

    loading = false;
    notifyListeners();
  }

  Future<void> loadOrderDetail(int orderId) async {
    loading = true;
    notifyListeners();

    currentOrder = await _service.getOrderDetail(orderId);

    loading = false;
    notifyListeners();
  }
}
