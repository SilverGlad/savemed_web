import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/core/auth/user_role.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/services/admin_service.dart';
import 'package:savemed/features/admin/admin_page.dart';
import 'package:savemed/models/admin_inventory_item.dart';
import 'package:savemed/models/category.dart';
import 'package:savemed/models/customer_order.dart';
import 'package:savemed/models/financial_summary.dart';
import 'package:savemed/models/medication.dart';
import 'package:savemed/models/user.dart';

class _FinancialAdminService extends AdminService {
  final FinancialSummary summary;
  int? requestedPharmacyId;
  int requests = 0;
  bool fail = false;

  _FinancialAdminService(this.summary);

  @override
  Future<List<Category>> listCategories({int? pharmacyId}) async => [];

  @override
  Future<List<Medication>> listMedications({int? pharmacyId}) async => [];

  @override
  Future<List<AdminInventoryItem>> listInventory({int? pharmacyId}) async => [];

  @override
  Future<List<CustomerOrder>> listOrders({int? pharmacyId}) async => [];

  @override
  Future<FinancialSummary> getFinancialSummary({int? pharmacyId}) async {
    requests++;
    requestedPharmacyId = pharmacyId;
    if (fail) throw const ApiConnectionException('Sem conexao');
    return summary;
  }
}

AuthController _pharmacyAdminAuth() => AuthController()
  ..loading = false
  ..user = const AppUser(
    id: 7,
    name: 'Farmacia Teste',
    email: 'farmacia@example.com',
    role: UserRole.pharmacyAdmin,
    pharmacyId: 7,
  )
  ..token = 'test-token';

FinancialSummary _summary() => const FinancialSummary(
  orders: 3,
  totalAmount: 139,
  paidOrders: 2,
  paidAmount: 112,
  pendingOrders: 1,
  pendingAmount: 27,
  refundedOrders: 0,
  refundedAmount: 0,
  failedOrders: 0,
  failedAmount: 0,
  canceledOrders: 0,
  pharmacyId: 7,
  paidProductsAmount: 100,
  paidShippingAmount: 12,
  payoutsConfigured: false,
);

void main() {
  testWidgets(
    'pharmacy finance separates gross payments and does not imply payout',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 960));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final service = _FinancialAdminService(_summary());
      final auth = _pharmacyAdminAuth();

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthController>.value(
          value: auth,
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: AdminPage(service: service),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Financeiro'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Pagamentos aprovados'), findsOneWidget);
      expect(find.text('Pendente'), findsOneWidget);
      expect(find.textContaining('Produtos pagos:'), findsOneWidget);
      expect(find.textContaining('Frete pago pelos clientes:'), findsOneWidget);
      expect(find.textContaining('Transfer'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              (widget.data?.contains('pagamentos exibidos') ?? false),
        ),
        findsOneWidget,
      );
      expect(service.requestedPharmacyId, 7);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('finance error stays distinct from zero and can recover', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final service = _FinancialAdminService(_summary())..fail = true;
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: _pharmacyAdminAuth(),
        child: MaterialApp(home: AdminPage(service: service)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('Resumo financeiro'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Resumo financeiro'), findsOneWidget);
    expect(find.text('Pagamentos aprovados'), findsNothing);
    expect(service.requests, 1);

    service.fail = false;
    await tester.tap(find.byTooltip('Atualizar financeiro'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Resumo financeiro'), findsNothing);
    expect(find.text('Pagamentos aprovados'), findsOneWidget);
    expect(service.requests, 2);
    expect(service.requestedPharmacyId, 7);
    expect(tester.takeException(), isNull);
  });
}
