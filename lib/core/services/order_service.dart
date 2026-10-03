import 'package:http/http.dart' as http;

import '../api/api_client.dart';
import '../api/api_response.dart';
import '../../models/customer_order.dart';

class OrderService {
  final Future<http.Response> Function(String path, Map body) _post;

  OrderService({Future<http.Response> Function(String path, Map body)? post})
    : _post = post ?? ApiClient.post;

  Future<int> checkout({
    required int customerId,
    required int pharmacyId,
    int? addressId,
    required double shippingPrice,
    required String deliveryMethod,
    String? deliveryLabel,
    required double subtotal,
    required List<Map<String, num>> items,
  }) async {
    final response = await _post('/orders/checkout', {
      'CUSTOMER_ID': customerId,
      'PHARMACY_ID': pharmacyId,
      'ADDRESS_ID': addressId,
      'SHIPPING_PRICE': shippingPrice,
      'DELIVERY_METHOD': deliveryMethod,
      'DELIVERY_LABEL': deliveryLabel,
      'EXPECTED_SUBTOTAL': subtotal,
      'ITEMS': items
          .map(
            (item) => {
              'INVENTORY_ID': item['inventoryId'],
              'QUANTITY': item['quantity'],
            },
          )
          .toList(),
    });

    final data = ApiResponse.object(
      response,
      expectedStatusCodes: {201},
      fallback: 'Erro ao criar pedido',
    );
    final order = data['order'];
    final id = order is Map ? order['ID'] : null;
    if (id is int) return id;
    throw ApiResponseException(
      'Resposta inválida do servidor.',
      response.statusCode,
    );
  }

  Future<List<CustomerOrder>> getOrdersByCustomer(int customerId) async {
    final res = await ApiClient.get('/orders/$customerId');

    final payload = ApiResponse.list(
      res,
      expectedStatusCodes: {200},
      fallback: 'Erro ao buscar pedidos',
    );
    return payload
        .whereType<Map>()
        .map((item) => CustomerOrder.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<CustomerOrder> getOrderDetail(int orderId) async {
    final res = await ApiClient.get('/orders/detail/$orderId');

    return CustomerOrder.fromJson(
      ApiResponse.object(
        res,
        expectedStatusCodes: {200},
        fallback: 'Erro ao buscar detalhes do pedido',
      ),
    );
  }

  Future<String> deliveryCode(int orderId) async {
    final response = await ApiClient.get('/orders/$orderId/delivery-code');
    final data = ApiResponse.object(
      response,
      expectedStatusCodes: {200},
      fallback: 'Não foi possível consultar o código de entrega.',
    );
    final code = data['code'];
    if (code is! String || !RegExp(r'^\d{4}$').hasMatch(code)) {
      throw const FormatException('Código de entrega inválido.');
    }
    return code;
  }
}
