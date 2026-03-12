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
      "CUSTOMER_ID": customerId,
      "PHARMACY_ID": pharmacyId,
      "ADDRESS_ID": addressId,
      "SHIPPING_PRICE": shippingPrice,
      "SUBTOTAL": subtotal,
      "TOTAL_AMOUNT": total,
    });

    final data = jsonDecode(res.body);
    return data['ID']; // ⚠️ use o mesmo nome que o backend retorna
  }

  Future<void> createOrderItem({
    required int orderId,
    required int inventoryId,
    required int quantity,
    required double price,
  }) async {
    await ApiClient.post('/order-items', {
      'ORDER_ID': orderId,
      'INVENTORY_ID': inventoryId,
      'QUANTITY': quantity,
      'PRICE': price,
    });
  }

  Future<List<dynamic>> getOrdersByCustomer(int customerId) async {
    final res = await ApiClient.get('/orders/customer/$customerId');

    if (res.statusCode != 200) {
      throw Exception('Erro ao buscar pedidos');
    }

    return jsonDecode(res.body);
  }
}
