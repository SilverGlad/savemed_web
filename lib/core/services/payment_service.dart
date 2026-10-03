import 'package:savemed/core/domain/payment_method.dart';

import '../api/api_client.dart';
import '../api/api_response.dart';

class PaymentService {
  Future<Map<String, dynamic>> pay({
    required int orderId,
    required double amount,
    required PaymentMethod method,
    Map<String, dynamic>? card,
    required Map<String, dynamic> customer,
    required String deviceId,
  }) async {
    final response = await ApiClient.post('/pay', {
      'order_id': orderId,
      'amount': amount,
      'method': method.name,
      'card': card,
      'customer': customer,
      'device_id': deviceId,
    });
    return ApiResponse.object(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao processar pagamento',
    );
  }

  Future<String> checkStatus({required int orderId}) async {
    final response = await ApiClient.get('/orders/$orderId/status');
    final body = ApiResponse.object(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao consultar status do pagamento',
    );
    final status = body['status'];
    if (status is String) return status;
    throw ApiResponseException(
      'Resposta inválida do servidor.',
      response.statusCode,
    );
  }
}
