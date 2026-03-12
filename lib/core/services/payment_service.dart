import 'dart:convert';
import 'package:SaveMed/features/payment/payment_page.dart';
import '../api/api_client.dart';

class PaymentService {
  // =========================
  // PAGAMENTO (CRÉDITO / DÉBITO / PIX)
  // =========================
  Future<Map<String, dynamic>> pay({
    required int orderId,
    required double amount,
    required PaymentMethod method,
    Map<String, dynamic>? card,
    required Map<String, dynamic> customer,
    required String deviceId,
  }) async {
    final res = await ApiClient.post('/pay', {
      'order_id': orderId,
      'amount': amount,
      'method': method.name, // credit | debit | pix
      'card': card,
      'customer': customer,
      'device_id': deviceId,
    });

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception('Erro ao processar pagamento');
  }

  // =========================
  // CONSULTAR STATUS (PIX POLLING)
  // =========================
  Future<String> checkStatus({required int orderId}) async {
    final res = await ApiClient.get('/orders/$orderId/status');

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);

      /*
        esperado:
        {
          "status": "waiting_payment" | "paid" | "canceled"
        }
      */

      return body['status'];
    }

    throw Exception('Erro ao consultar status do pagamento');
  }
}
