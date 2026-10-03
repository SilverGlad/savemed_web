import 'package:flutter/material.dart';
import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/core/api/api_response.dart';
import 'package:savemed/core/domain/payment_method.dart';
import '../services/payment_service.dart';
import '../logging/app_logger.dart';
import '../api/api_error_message.dart';

class PaymentController extends ChangeNotifier {
  final PaymentService _service;
  int _generation = 0;

  PaymentController({PaymentService? service})
    : _service = service ?? PaymentService();

  bool loading = false;

  void clear() {
    _generation++;
    loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }

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
    if (loading) throw StateError('Já existe um pagamento em andamento.');
    final generation = ++_generation;
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
      if (generation != _generation) {
        throw StateError('A sessão foi encerrada durante o pagamento.');
      }
      return result;
    } catch (error) {
      if (generation != _generation) {
        throw StateError('A sessão foi encerrada durante o pagamento.');
      }
      AppLogger.event(AppLogEvent.paymentRequestFailed);
      return {
        'success': false,
        'outcome_unknown':
            error is ApiConnectionException ||
            (error is ApiResponseException && error.isServerError),
        'message': ApiErrorMessage.forUser(
          error,
          fallback: 'Não foi possível processar o pagamento agora.',
        ),
      };
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  // =========================
  // CONSULTAR STATUS (PIX POLLING)
  // =========================
  Future<String?> checkStatus({required int orderId}) async {
    final generation = _generation;
    try {
      final status = await _service.checkStatus(orderId: orderId);
      return generation == _generation
          ? status
          : null; // waiting_payment | paid | canceled
    } catch (e) {
      if (generation != _generation) return null;
      AppLogger.event(AppLogEvent.paymentStatusCheckFailed);
      return null;
    }
  }
}
