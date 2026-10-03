import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/api/api_response.dart';
import 'package:savemed/core/services/order_service.dart';
import 'package:savemed/features/profile/delivery_code_panel.dart';

void main() {
  testWidgets(
    'customer code loads on demand and preserves four digits on mobile',
    (tester) async {
      final service = _Codes();
      await tester.binding.setSurfaceSize(const Size(320, 650));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryCodePanel(orderId: 42, service: service),
          ),
        ),
      );
      expect(service.calls, 0);
      expect(find.text('0123'), findsNothing);
      await tester.tap(find.text('Ver código'));
      await tester.pumpAndSettle();
      expect(service.calls, 1);
      expect(find.text('0123'), findsOneWidget);
      expect(
        find.text('Informe ao entregador somente quando receber os produtos.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('expired delivery hides the old code after refresh fails', (
    tester,
  ) async {
    final service = _Codes();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DeliveryCodePanel(orderId: 42, service: service)),
      ),
    );
    await tester.tap(find.text('Ver código'));
    await tester.pumpAndSettle();
    service.unavailable = true;
    await tester.tap(find.text('Atualizar código'));
    await tester.pumpAndSettle();
    expect(find.text('0123'), findsNothing);
    expect(find.text('Entrega já encerrada.'), findsOneWidget);
  });
}

class _Codes extends OrderService {
  int calls = 0;
  bool unavailable = false;
  @override
  Future<String> deliveryCode(int orderId) async {
    calls++;
    if (unavailable) {
      throw const ApiResponseException('Entrega já encerrada.', 409);
    }
    return '0123';
  }
}
