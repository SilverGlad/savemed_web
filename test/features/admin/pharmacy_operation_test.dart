import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/api/api_response.dart';
import 'package:savemed/core/services/admin_service.dart';
import 'package:savemed/features/admin/pharmacy_operation_panel.dart';
import 'package:savemed/features/profile/order_progress.dart';
import 'package:savemed/models/customer_order.dart';
import 'package:savemed/models/pharmacy_operation.dart';

class _Service extends AdminService {
  PharmacyOperation value = const PharmacyOperation(
    id: 7,
    version: 0,
    active: true,
    isOpen: true,
  );
  bool fail = false;
  int writes = 0;
  @override
  Future<PharmacyOperation> pharmacyOperation(int id) async => value;
  @override
  Future<PharmacyOperation> updatePharmacyOperation(
    int id,
    int version,
    Map<String, dynamic> values,
  ) async {
    writes++;
    expect(version, value.version);
    if (fail) throw const ApiResponseException('Falha temporária.', 503);
    return value = PharmacyOperation(
      id: id,
      version: version + 1,
      active: true,
      isOpen: values['isOpen'] as bool? ?? value.isOpen,
      preparationMinutes:
          values['preparationMinutes'] as int? ?? value.preparationMinutes,
      payoutTermDays: values['payoutTermDays'] as int? ?? value.payoutTermDays,
    );
  }
}

void main() {
  Future<void> open(
    WidgetTester tester,
    Widget child, {
    double scale = 1,
  }) async {
    await tester.binding.setSurfaceSize(const Size(320, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'pause requires confirmation and failed reopen keeps server state',
    (tester) async {
      final service = _Service();
      await open(
        tester,
        PharmacyOperationPanel(pharmacyId: 7, service: service),
      );
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();
      expect(service.writes, 0);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pausar loja'));
      await tester.pumpAndSettle();
      expect(find.text('Loja pausada'), findsOneWidget);
      service.fail = true;
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('Loja pausada'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('preparation and payout preferences persist separately', (
    tester,
  ) async {
    final service = _Service();
    await open(tester, PharmacyOperationPanel(pharmacyId: 7, service: service));
    await tester.tap(find.byType(DropdownButtonFormField<int>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('30 minutos').last);
    await tester.pumpAndSettle();
    expect(service.value.preparationMinutes, 30);
    await tester.tap(find.byType(DropdownButtonFormField<int>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('15 dias').last);
    await tester.pumpAndSettle();
    expect(service.value.payoutTermDays, 15);
    expect(service.value.preparationMinutes, 30);
    expect(find.textContaining('não efetua transferências'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('operation fits narrow screen and enlarged text', (tester) async {
    await open(
      tester,
      PharmacyOperationPanel(pharmacyId: 7, service: _Service()),
      scale: 2,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('unpaid orders do not show preparation progress', (tester) async {
    await open(
      tester,
      OrderProgress(
        order: CustomerOrder.fromJson({
          'ID': 1,
          'PAYMENT_STATUS': 'pending',
          'TOTAL_AMOUNT': 20,
        }),
      ),
    );
    expect(find.textContaining('Aguardando confirmação'), findsOneWidget);
    expect(find.text('Em preparação'), findsNothing);
  });

  testWidgets(
    'paid pickup progress fits enlarged mobile without delivery step',
    (tester) async {
      await open(
        tester,
        OrderProgress(
          order: CustomerOrder.fromJson({
            'ID': 1,
            'PAYMENT_STATUS': 'paid',
            'TOTAL_AMOUNT': 20,
            'DELIVERY_METHOD': 'pickup',
            'FULFILLMENT': {'stage': 'ready'},
          }),
        ),
        scale: 2,
      );
      expect(find.text('Pronto para retirada'), findsOneWidget);
      expect(find.text('A caminho'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
