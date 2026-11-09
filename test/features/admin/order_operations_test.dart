import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/api/api_response.dart';
import 'package:savemed/core/services/admin_service.dart';
import 'package:savemed/core/theme/app_theme.dart';
import 'package:savemed/features/admin/order_operations_page.dart';
import 'package:savemed/models/order_fulfillment.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('Montserrat')
      ..addFont(rootBundle.load('assets/fonts/Montserrat-Regular.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  Future<void> open(
    WidgetTester tester,
    _Service service,
    double width, {
    double scale = 1,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 950));
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
        home: OrderOperationsPage(orderId: 42, service: service),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final width in [390.0, 1280.0]) {
    testWidgets('order details and own delivery work at $width', (
      tester,
    ) async {
      final service = _Service();
      await open(tester, service, width);
      expect(find.text('Estoque: Baixa de estoque registrada'), findsOneWidget);
      expect(find.text('2 × Produto de teste'), findsOneWidget);
      await tester.tap(find.text('Aceitar e preparar'));
      await tester.pumpAndSettle();
      expect(find.text('Em preparação'), findsOneWidget);
      await tester.tap(find.text('Marcar como pronto'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(OrderOperationsPage),
        matchesGoldenFile('goldens/order_${width.toInt()}.png'),
      );
      await tester.tap(find.text('Entrega própria'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar saída'));
      await tester.pumpAndSettle();
      expect(find.text('Informe o nome.'), findsOneWidget);
      expect(service.actions, ['accept', 'ready']);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Entregador teste',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '11999999999');
      await tester.tap(find.text('Confirmar saída'));
      await tester.pumpAndSettle();
      expect(find.text('Em entrega'), findsOneWidget);
      await tester.tap(find.text('Confirmar entrega'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Validar e concluir'));
      await tester.pumpAndSettle();
      expect(find.text('Informe os 4 dígitos.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '0123');
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AlertDialog),
        matchesGoldenFile('goldens/delivery_code_${width.toInt()}.png'),
      );
      await tester.tap(find.text('Validar e concluir'));
      await tester.pumpAndSettle();
      expect(find.text('Entregue'), findsOneWidget);
      expect(service.actions, ['accept', 'ready', 'dispatch_own', 'delivered']);
      expect(service.lastDetails['deliveryCode'], '0123');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'pending payment cannot start preparation at 320px with large text',
    (tester) async {
      final service = _Service()..payment = 'pending';
      await open(tester, service, 320, scale: 2);
      expect(find.text('Aceitar e preparar'), findsNothing);
      expect(service.actions, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('interrupted delivery requires reason and returned products', (
    tester,
  ) async {
    final service = _Service()..stage = 'on_way';
    await open(tester, service, 390);
    await tester.tap(find.text('Interromper entrega'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Confirmar retorno'),
          )
          .onPressed,
      isNull,
    );
    await tester.enterText(
      find.byType(TextFormField),
      'Cliente ausente no destino',
    );
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar retorno'));
    await tester.pumpAndSettle();
    expect(service.actions, ['return_to_pharmacy']);
    expect(service.lastDetails['returned'], true);
    expect(service.lastDetails['reason'], 'Cliente ausente no destino');
    expect(find.text('Pronto'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('conflict remains visible and reloads authoritative stage', (
    tester,
  ) async {
    final service = _Service()..conflict = true;
    await open(tester, service, 390);
    await tester.tap(find.text('Aceitar e preparar'));
    await tester.pumpAndSettle();
    expect(find.text('O pedido mudou. Atualize a tela.'), findsOneWidget);
    expect(find.text('Em preparação'), findsOneWidget);
    expect(service.reads, 2);
  });

  testWidgets(
    'wrong delivery code keeps the dialog open and preserves the order',
    (tester) async {
      final service = _Service()..stage = 'on_way';
      await open(tester, service, 390);
      await tester.tap(find.text('Confirmar entrega'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '9999');
      await tester.tap(find.text('Validar e concluir'));
      await tester.pumpAndSettle();
      expect(find.text('Código incorreto.'), findsOneWidget);
      expect(service.stage, 'on_way');
      await tester.enterText(find.byType(TextFormField), '0123');
      await tester.tap(find.text('Validar e concluir'));
      await tester.pumpAndSettle();
      expect(find.text('Entregue'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('delivery code dialog fits 320px with enlarged text', (
    tester,
  ) async {
    final service = _Service()..stage = 'on_way';
    await open(tester, service, 320, scale: 2);
    await tester.ensureVisible(find.text('Confirmar entrega'));
    await tester.tap(find.text('Confirmar entrega'));
    await tester.pumpAndSettle();
    expect(find.text('Código de entrega'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [390.0, 1280.0]) {
    testWidgets('PedMoto quotation, consent, collection and code at $width', (
      tester,
    ) async {
      final service = _Service()
        ..stage = 'ready'
        ..pedMotoAvailable = true;
      await open(tester, service, width);
      await tester.tap(find.text('Cotar PedMoto'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Corrida estimada:'), findsOneWidget);
      await tester.tap(find.text('Solicitar motoboy'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AlertDialog),
        matchesGoldenFile('goldens/pedmoto_consent_${width.toInt()}.png'),
      );
      expect(service.actions, ['quote_pedmoto']);
      await tester.tap(find.text('Confirmar solicitação'));
      await tester.pumpAndSettle();
      expect(service.lastDetails['quoteId'], 'quote-fixture');
      expect(service.lastDetails['acceptCost'], true);
      expect(find.text('Aguardando coleta PedMoto'), findsOneWidget);
      expect(find.text('Entrega própria'), findsNothing);
      await expectLater(
        find.byType(OrderOperationsPage),
        matchesGoldenFile('goldens/pedmoto_requested_${width.toInt()}.png'),
      );
      await tester.tap(find.text('Consultar PedMoto'));
      await tester.pumpAndSettle();
      expect(find.text('Aguardando coleta PedMoto'), findsOneWidget);
      await tester.tap(find.text('Confirmar coleta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Produtos coletados'));
      await tester.pumpAndSettle();
      expect(find.text('Em entrega'), findsOneWidget);
      expect(find.text('Interromper entrega'), findsNothing);
      await tester.tap(find.text('Confirmar entrega'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '0123');
      await tester.tap(find.text('Validar e concluir'));
      await tester.pumpAndSettle();
      expect(find.text('Entregue'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'PedMoto uncertainty blocks new dispatch at 320px and large text',
    (tester) async {
      final service = _Service()
        ..stage = 'pedmoto_uncertain'
        ..mode = 'pedmoto';
      await open(tester, service, 320, scale: 2);
      expect(find.text('Entrega própria'), findsNothing);
      expect(find.text('Solicitar motoboy'), findsNothing);
      expect(find.textContaining('Não solicite outra corrida'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('unconfigured PedMoto keeps own delivery available', (
    tester,
  ) async {
    await open(tester, _Service()..stage = 'ready', 390);
    expect(find.text('Entrega própria'), findsOneWidget);
    expect(find.text('Cotar PedMoto'), findsNothing);
    expect(find.textContaining('PedMoto ainda não habilitada'), findsOneWidget);
  });
}

class _Service extends AdminService {
  String stage = 'new';
  String payment = 'paid';
  bool conflict = false;
  bool pedMotoAvailable = false;
  bool quoted = false;
  String mode = 'own';
  int reads = 0;
  int version = 0;
  final actions = <String>[];
  Map<String, dynamic> lastDetails = {};

  OrderFulfillment get order => OrderFulfillment({
    'id': 42,
    'version': version,
    'status': 'confirmed',
    'paymentStatus': payment,
    'inventoryState': payment == 'paid' ? 'deducted' : 'reserved',
    'total': 25.0,
    'shippingPrice': 5.0,
    'deliveryMethod': 'shipping',
    'pedMotoAvailable': pedMotoAvailable,
    'customer': {'name': 'Cliente de teste', 'phone': '(11) 99999-9999'},
    'origin': {
      'STREET': 'Rua da Farmácia',
      'NUMBER': '20',
      'CITY': 'São Paulo',
      'STATE': 'SP',
    },
    'destination': {
      'STREET': 'Rua do Cliente',
      'NUMBER': '123',
      'COMPLEMENT': 'Apartamento 40',
      'CITY': 'São Paulo',
      'STATE': 'SP',
    },
    'items': [
      {'name': 'Produto de teste', 'quantity': 2, 'total': 20.0},
    ],
    'fulfillment': {
      'stage': stage,
      'mode': mode,
      'history': [],
      if (quoted) 'pedmotoQuote': {'id': 'quote-fixture', 'price': 12.5},
      if (mode == 'pedmoto')
        'pedmoto': {
          'reference': 'savemed-42-5aaf8589-1143-4656-8edb-abf438b8d61e',
          if (stage != 'pedmoto_uncertain') 'providerId': 'pm-42',
          'status': 'PENDING_ACCEPTANCE',
          'estimatedPrice': 12.5,
        },
    },
  });

  @override
  Future<OrderFulfillment> orderFulfillment(int id) async {
    reads++;
    return order;
  }

  @override
  Future<OrderFulfillment> actOnOrder(
    int id,
    int expectedVersion,
    String action, [
    Map<String, dynamic> details = const {},
  ]) async {
    actions.add(action);
    lastDetails = details;
    version++;
    if (action == 'delivered' && details['deliveryCode'] != '0123') {
      throw const ApiResponseException('Código incorreto.', 400);
    }
    if (conflict) {
      stage = 'preparing';
      throw const ApiResponseException('O pedido mudou. Atualize a tela.', 409);
    }
    if (action == 'quote_pedmoto') quoted = true;
    if (action == 'dispatch_pedmoto') mode = 'pedmoto';
    stage = switch (action) {
      'accept' => 'preparing',
      'ready' => 'ready',
      'dispatch_own' => 'on_way',
      'delivered' => 'delivered',
      'return_to_pharmacy' => 'ready',
      'dispatch_pedmoto' => 'pedmoto_requested',
      'pedmoto_collected' => 'on_way',
      _ => stage,
    };
    return order;
  }
}
