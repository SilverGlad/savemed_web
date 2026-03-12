import 'dart:convert';

import '../api/api_client.dart';

class OrderService {
  Future<int> createOrder({
    required int customerId,
    required int pharmacyId,
    required int addressId,
    required double shippingPrice,
    required double subtotal,
    required double total,
  }) async {
    final res = await ApiClient.post('/orders', {
      'CUSTOMER_ID': customerId,
      'PHARMACY_ID': pharmacyId,
      'ADDRESS_ID': addressId,
      'SHIPPING_PRICE': shippingPrice,
      'SUBTOTAL': subtotal,
      'TOTAL_AMOUNT': total,
    });

    final data = jsonDecode(res.body);

    if (res.statusCode != 201) {
      throw Exception(data['error'] ?? 'Erro ao criar pedido');
    }

    return data['ID'];
  }

  Future<void> createOrderItem({
    required int orderId,
    required int inventoryId,
    required int quantity,
    required double price,
  }) async {
    final res = await ApiClient.post('/order-items', {
      'ORDER_ID': orderId,
      'INVENTORY_ID': inventoryId,
      'QUANTITY': quantity,
      'UNIT_PRICE': price,
      'TOTAL_PRICE': price * quantity,
    });

    if (res.statusCode != 201) {
      final data = jsonDecode(res.body);
      throw Exception(data['error'] ?? 'Erro ao criar item do pedido');
    }
  }

  Future<List<dynamic>> getOrdersByCustomer(int customerId) async {
    final res = await ApiClient.get('/orders/$customerId');

    if (res.statusCode != 200) {
      throw Exception('Erro ao buscar pedidos');
    }

    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getOrderDetail(int orderId) async {
    final res = await ApiClient.get('/orders/detail/$orderId');

    if (res.statusCode != 200) {
      throw Exception('Erro ao buscar detalhes do pedido');
    }

    return jsonDecode(res.body);
  }
}
