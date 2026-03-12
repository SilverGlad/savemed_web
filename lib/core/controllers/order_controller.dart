import 'package:flutter/material.dart';
import 'package:SaveMed/core/utils/input_formatters.dart';
import 'package:SaveMed/models/cart_item.dart';
import '../services/order_service.dart';

class OrderController extends ChangeNotifier {
  final _service = OrderService();

  bool loading = false;
  List<dynamic> orders = [];
  int? currentOrderId;

  Future<int> createOrder({
    required int customerId,
    required int pharmacyId,
    required int addressId,
    required Map<String, dynamic> shipping,
    required double subtotal,
  }) async {
    loading = true;
    notifyListeners();

    final shippingPrice = toDouble(shipping['price']);
    final total = subtotal + shippingPrice;

    final id = await _service.createOrder(
      customerId: customerId,
      pharmacyId: pharmacyId,
      addressId: addressId,
      shippingPrice: shippingPrice,
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
}
