import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/core/api/api_response.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/controllers/payment_controller.dart';
import 'package:savemed/core/domain/payment_method.dart';
import 'package:savemed/core/services/payment_service.dart';
import 'package:savemed/core/storage/card_storage.dart';
import 'package:savemed/core/storage/token_storage.dart';
import '../../support/in_memory_token_vault.dart';

void main() {
  setUp(() {
    TokenStorage.resetForTesting();
    TokenStorage.setVaultForTesting(InMemoryTokenVault());
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'late payment completion cannot reset a newer session request',
    () async {
      SharedPreferences.setMockInitialValues({});
      await CardStorage.clear();
      final oldRequest = Completer<Map<String, dynamic>>();
      final newRequest = Completer<Map<String, dynamic>>();
      final service = _PaymentService([oldRequest, newRequest]);
      final payments = PaymentController(service: service);
      final auth = AuthController(payments: payments);
      addTearDown(payments.dispose);
      addTearDown(auth.dispose);

      final oldCompletion = expectLater(_pay(payments), throwsStateError);
      await auth.logout();
      final newPayment = _pay(payments);
      expect(payments.loading, isTrue);

      oldRequest.complete({'success': true});
      await oldCompletion;
      expect(payments.loading, isTrue);

      newRequest.complete({'success': true});
      expect(await newPayment, {'success': true});
      expect(payments.loading, isFalse);
    },
  );

  test('status response is discarded after session clear', () async {
    final status = Completer<String>();
    final payments = PaymentController(
      service: _PaymentService([], status: status),
    );
    addTearDown(payments.dispose);

    final pendingStatus = payments.checkStatus(orderId: 10);
    payments.clear();
    status.complete('paid');

    expect(await pendingStatus, isNull);
  });

  test('network failure marks payment outcome as uncertain', () async {
    final controller = PaymentController(
      service: _PaymentService(
        [],
        payError: const ApiConnectionException('offline'),
      ),
    );
    addTearDown(controller.dispose);

    final result = await _pay(controller);

    expect(result['success'], isFalse);
    expect(result['outcome_unknown'], isTrue);
  });

  test('validation failure is not marked as an uncertain charge', () async {
    final controller = PaymentController(
      service: _PaymentService(
        [],
        payError: const ApiResponseException('Invalid payment', 422),
      ),
    );
    addTearDown(controller.dispose);

    final result = await _pay(controller);

    expect(result['success'], isFalse);
    expect(result['outcome_unknown'], isFalse);
  });
}

Future<Map<String, dynamic>> _pay(PaymentController controller) =>
    controller.pay(
      orderId: 10,
      amount: 20,
      method: PaymentMethod.pix,
      customer: const {},
      deviceId: 'test',
    );

class _PaymentService extends PaymentService {
  final List<Completer<Map<String, dynamic>>> requests;
  final Completer<String>? status;
  final Object? payError;

  _PaymentService(this.requests, {this.status, this.payError});

  @override
  Future<Map<String, dynamic>> pay({
    required int orderId,
    required double amount,
    required PaymentMethod method,
    Map<String, dynamic>? card,
    required Map<String, dynamic> customer,
    required String deviceId,
  }) =>
      payError == null ? requests.removeAt(0).future : Future.error(payError!);

  @override
  Future<String> checkStatus({required int orderId}) => status!.future;
}
