import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/api/api_response.dart';
import 'package:savemed/core/services/admin_service.dart';
import 'package:savemed/core/theme/app_theme.dart';
import 'package:savemed/features/admin/domain/order_queue.dart';
import 'package:savemed/features/admin/order_queue_page.dart';
import 'package:savemed/models/customer_order.dart';
import 'package:savemed/models/financial_summary.dart';

final clock = DateTime(2026, 9, 27, 14);
CustomerOrder order(
  int id, {
  String payment = 'paid',
  String stage = 'new',
  String status = 'confirmed',
  bool uncertain = false,
}) => CustomerOrder(
  id: id,
  status: status,
  paymentStatus: payment,
  totalAmount: 25.9,
  createdAt: clock.subtract(const Duration(minutes: 20)),
  paidAt: clock.subtract(const Duration(minutes: 18)),
  pharmacyName: 'Farmácia Central',
  fulfillmentStage: stage,
  unresolvedPaymentAttempt: uncertain,
  items: const [
    CustomerOrderItem(
      productName: 'Produto de teste',
      quantity: 2,
      totalPrice: 20.9,
    ),
  ],
);

void main() {
  setUpAll(() async {
    await (FontLoader(
      'Montserrat',
    )..addFont(rootBundle.load('assets/fonts/Montserrat-Regular.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  test(
    'operational queues separate payment, completion, cancellation and incidents',
    () {
      expect(queueForOrder(order(1), clock), OrderQueue.newOrders);
      expect(
        queueForOrder(order(1, payment: 'pending'), clock),
        OrderQueue.payment,
      );
      expect(
        queueForOrder(order(1, payment: 'pending', uncertain: true), clock),
        OrderQueue.issues,
      );
      expect(
        queueForOrder(order(1, stage: 'pedmoto_uncertain'), clock),
        OrderQueue.issues,
      );
      expect(
        queueForOrder(order(1, stage: 'refund_pending'), clock),
        OrderQueue.issues,
      );
      expect(
        queueForOrder(order(1, stage: 'pedmoto_requested'), clock),
        OrderQueue.ready,
      );
      expect(
        queueForOrder(order(1, stage: 'delivered'), clock),
        OrderQueue.completed,
      );
      expect(
        queueForOrder(order(1, status: 'canceled'), clock),
        OrderQueue.issues,
      );
      expect(isActiveOrder(order(1, stage: 'delivered')), false);
      expect(isActiveOrder(order(1, status: 'canceled')), false);
      expect(isActiveOrder(order(1, payment: 'pending')), false);
      expect(isActiveOrder(order(1, stage: 'preparing')), true);
      expect(orderAttention(order(1), clock), contains('15 min'));
    },
  );

  test(
    'financial model keeps unknown payout and product totals distinct from zero',
    () {
      final legacy = FinancialSummary.fromJson({'paidAmount': 20});
      expect(legacy.paidProductsAmount, isNull);
      expect(legacy.payoutsConfigured, false);
      final current = FinancialSummary.fromJson({
        'paidAmount': 20,
        'paidProductsAmount': 15,
        'paidShippingAmount': 5,
      });
      expect(current.paidProductsAmount, 15);
      expect(current.paidShippingAmount, 5);
    },
  );

  Future<void> open(
    WidgetTester tester,
    _Service service,
    double width, {
    double scale = 1,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: OrderQueuePage(
            service: service,
            pharmacyId: 7,
            now: () => clock,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final width in [390.0, 1280.0]) {
    testWidgets('central filters orders and fits $width', (tester) async {
      final service = _Service();
      await open(tester, service, width);
      expect(find.text('Pedido #1'), findsOneWidget);
      expect(find.text('Pedido #2'), findsNothing);
      expect(find.text('Novos (1)'), findsOneWidget);
      await expectLater(
        find.byType(OrderQueuePage),
        matchesGoldenFile('goldens/queue_${width.toInt()}.png'),
      );
      await tester.ensureVisible(find.text('Preparando (1)'));
      await tester.tap(find.text('Preparando (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Pedido #2'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'sem resultado');
      await tester.pumpAndSettle();
      expect(find.text('Nenhum pedido encontrado.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('central fits 320px with 200 percent text', (tester) async {
    await open(tester, _Service(), 320, scale: 2);
    expect(find.text('Central de pedidos'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'background refresh announces newly paid orders and preserves data on error',
    (tester) async {
      final service = _Service();
      await open(tester, service, 390);
      service.orders = [...service.orders, order(5)];
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      expect(find.text('1 novos pedidos recebidos'), findsOneWidget);
      expect(find.text('Novos (2)'), findsOneWidget);
      service.fail = true;
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Exibindo a última atualização'),
        findsOneWidget,
      );
      expect(find.text('Novos (2)'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      final requests = service.reads;
      await tester.pump(const Duration(seconds: 60));
      expect(service.reads, requests);
      await tester.pumpWidget(const SizedBox());
    },
  );
}

class _Service extends AdminService {
  List<CustomerOrder> orders = [
    order(1),
    order(2, stage: 'preparing'),
    order(3, payment: 'pending'),
    order(4, stage: 'delivered'),
  ];
  int reads = 0;
  bool fail = false;
  @override
  Future<List<CustomerOrder>> listOrders({int? pharmacyId}) async {
    reads++;
    if (fail) throw const ApiResponseException('Falha temporária.', 503);
    return orders;
  }
}
