import 'dart:async';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:savemed/core/auth/user_role.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/controllers/home_inventory_controller.dart';
import 'package:savemed/core/controllers/order_controller.dart';
import 'package:savemed/core/controllers/search_controller.dart';
import 'package:savemed/core/services/auth_service.dart';
import 'package:savemed/core/services/order_service.dart';
import 'package:savemed/core/services/support_contact_service.dart';
import 'package:savemed/features/profile/profile_page.dart';
import 'package:savemed/models/customer_order.dart';
import 'package:savemed/models/user.dart';
import 'package:url_launcher/url_launcher.dart';

const user = AppUser(
  id: 1,
  name: 'Cliente de teste',
  email: 'cliente@example.com',
  role: UserRole.customer,
);

class ProfileService extends AuthService {
  final result = Completer<AppUser>();
  @override
  Future<AppUser> updateProfile({
    required String name,
    required String phone,
  }) => result.future;
}

class OrdersService extends OrderService {
  int loadCount = 0;
  bool fail = false;
  List<CustomerOrder> orders = const [];

  @override
  Future<List<CustomerOrder>> getOrdersByCustomer(int customerId) async {
    loadCount++;
    if (fail) throw Exception('offline');
    return orders;
  }
}

Future<void> openProfile(
  WidgetTester tester,
  ProfileService service, {
  OrdersService? ordersService,
  SupportContactService supportContactService = const SupportContactService(),
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final auth = AuthController(service: service)
    ..user = user
    ..token = 'test'
    ..loading = false;
  final home = HomeInventoryController();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: auth),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => SearchController(home: home)),
        ChangeNotifierProvider(
          create: (_) =>
              OrderController(service: ordersService ?? OrdersService()),
        ),
      ],
      child: MaterialApp(
        home: ProfilePage(supportContactService: supportContactService),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('order support opens WhatsApp without exposing customer data', (
    tester,
  ) async {
    final orderService = OrdersService()
      ..orders = const [
        CustomerOrder(
          id: 42,
          status: 'confirmed',
          paymentStatus: 'paid',
          totalAmount: 23.5,
          createdAt: null,
          pharmacyName: 'Farmácia Teste',
          items: [],
        ),
      ];
    Uri? openedUri;
    final supportService = SupportContactService(
      launch: (uri, mode) async {
        openedUri = uri;
        expect(mode, LaunchMode.externalApplication);
        return false;
      },
    );
    await openProfile(
      tester,
      ProfileService(),
      ordersService: orderService,
      supportContactService: supportService,
    );

    await tester.tap(find.text('Pedidos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pedido #42'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Falar com suporte da SaveMed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Falar com suporte da SaveMed'));
    await tester.pumpAndSettle();

    expect(openedUri?.host, 'wa.me');
    expect(openedUri?.path, '/5519991707830');
    expect(openedUri?.queryParameters['text'], contains('pedido #42'));
    expect(openedUri?.queryParameters['text'], isNot(contains(user.email)));
    expect(
      find.textContaining('Não foi possível abrir o WhatsApp.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('orders network failure is not shown as an empty order list', (
    tester,
  ) async {
    final orderService = OrdersService()..fail = true;
    await openProfile(tester, ProfileService(), ordersService: orderService);

    await tester.tap(find.text('Pedidos'));
    await tester.pumpAndSettle();
    expect(find.text('Você ainda não possui pedidos'), findsNothing);
    expect(
      find.text('Não foi possível atualizar seus pedidos.'),
      findsOneWidget,
    );

    orderService.fail = false;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.text('Você ainda não possui pedidos'), findsOneWidget);
    expect(find.text('Não foi possível atualizar seus pedidos.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('orders refresh in foreground only while their tab is active', (
    tester,
  ) async {
    final orderService = OrdersService();
    await openProfile(tester, ProfileService(), ordersService: orderService);
    expect(orderService.loadCount, 0);

    await tester.tap(find.text('Pedidos'));
    await tester.pumpAndSettle();
    expect(orderService.loadCount, 1);

    await tester.pump(const Duration(seconds: 30));
    await tester.pump();
    expect(orderService.loadCount, 2);

    await tester.tap(find.text('Meus dados'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 60));
    expect(orderService.loadCount, 2);

    await tester.tap(find.text('Pedidos'));
    await tester.pumpAndSettle();
    expect(orderService.loadCount, 3);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    await tester.pump(const Duration(seconds: 60));
    expect(orderService.loadCount, 3);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();
    expect(orderService.loadCount, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'profile leaves enough mobile space and only confirms after persistence',
    (tester) async {
      final service = ProfileService();
      await openProfile(tester, service);
      final save = find.text('Salvar alterações');
      expect(tester.getBottomRight(save).dy, lessThan(844));
      await tester.tap(save);
      await tester.pump();
      expect(find.text('Dados atualizados'), findsNothing);
      service.result.complete(user);
      await tester.pumpAndSettle();
      expect(find.text('Dados atualizados'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'profile keeps input and does not claim success after save failure',
    (tester) async {
      final service = ProfileService();
      await openProfile(tester, service);
      await tester.enterText(find.byType(TextField).at(1), 'Novo nome');
      await tester.tap(find.text('Salvar alterações'));
      await tester.pump();
      service.result.completeError(Exception('offline'));
      await tester.pumpAndSettle();
      expect(find.text('Dados atualizados'), findsNothing);
      expect(find.text('Não foi possível salvar seus dados.'), findsOneWidget);
      expect(find.text('Novo nome'), findsOneWidget);
    },
  );
}
