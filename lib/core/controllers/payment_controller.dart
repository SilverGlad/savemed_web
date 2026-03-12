import 'package:flutter/material.dart';
import 'package:SaveMed/features/payment/payment_page.dart';
import '../services/payment_service.dart';

class PaymentController extends ChangeNotifier {
  final PaymentService _service = PaymentService();

  bool loading = false;

  // =========================
  // PAGAR (CRÉDITO / DÉBITO / PIX)
  // =========================
  Future<Map<String, dynamic>> pay({
    required int orderId,
    required double amount,
    required PaymentMethod method,
    Map<String, dynamic>? card,
    required Map<String, dynamic> customer,
    required String deviceId,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final result = await _service.pay(
        orderId: orderId,
        amount: amount,
        method: method,
        card: card,
        customer: customer,
        deviceId: deviceId,
      );

      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =========================
  // CONSULTAR STATUS (PIX POLLING)
  // =========================
  Future<String?> checkStatus({required int orderId}) async {
    try {
      final status = await _service.checkStatus(orderId: orderId);
      return status; // waiting_payment | paid | canceled
    } catch (e) {
      debugPrint('Erro ao verificar status: $e');
      return null;
    }
  }
}
