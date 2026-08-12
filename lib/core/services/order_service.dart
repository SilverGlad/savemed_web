import '../api/api_client.dart';
import '../api/api_response.dart';

class OrderService {
  Future<int> createOrder({
    required int customerId,
    required int pharmacyId,
    int? addressId,
    required double shippingPrice,
    required String deliveryMethod,
    String? deliveryLabel,
    required double subtotal,
    required double total,
  }) async {
    final res = await ApiClient.post('/orders', {
      'CUSTOMER_ID': customerId,
      'PHARMACY_ID': pharmacyId,
      'ADDRESS_ID': addressId,
      'SHIPPING_PRICE': shippingPrice,
      'DELIVERY_METHOD': deliveryMethod,
      'DELIVERY_LABEL': deliveryLabel,
      'SUBTOTAL': subtotal,
      'TOTAL_AMOUNT': total,
    });

    final data = ApiResponse.object(
      res,
      expectedStatusCodes: {201},
      fallback: 'Erro ao criar pedido',
    );
    final id = data['ID'];
    if (id is int) return id;
    throw ApiResponseException(
      'Resposta invalida do servidor.',
      res.statusCode,
    );
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

    ApiResponse.success(
      res,
      expectedStatusCodes: {201},
      fallback: 'Erro ao criar item do pedido',
    );
  }

  Future<List<dynamic>> getOrdersByCustomer(int customerId) async {
    final res = await ApiClient.get('/orders/$customerId');

    return ApiResponse.list(
      res,
      expectedStatusCodes: {200},
      fallback: 'Erro ao buscar pedidos',
    );
  }

  Future<Map<String, dynamic>> getOrderDetail(int orderId) async {
    final res = await ApiClient.get('/orders/detail/$orderId');

    return ApiResponse.object(
      res,
      expectedStatusCodes: {200},
      fallback: 'Erro ao buscar detalhes do pedido',
    );
  }
}
