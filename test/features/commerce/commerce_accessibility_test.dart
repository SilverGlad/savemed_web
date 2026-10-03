import 'package:flutter/material.dart' hide SearchController;
import 'dart:convert';
import 'dart:ui' show SemanticsAction;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:savemed/core/controllers/address_controller.dart';
import 'package:savemed/core/theme/app_theme.dart';
import 'package:savemed/core/utils/money_formatter.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/controllers/card_controller.dart';
import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/controllers/home_inventory_controller.dart';
import 'package:savemed/core/controllers/payment_controller.dart';
import 'package:savemed/core/navigation/app_routes.dart';
import 'package:savemed/core/services/inventory_service.dart';
import 'package:savemed/core/domain/payment_method.dart';
import 'package:savemed/core/controllers/pharmacy_controller.dart';
import 'package:savemed/core/services/pharmacy_service.dart';
import 'package:savemed/core/services/address_service.dart';
import 'package:savemed/core/auth/user_role.dart';
import 'package:savemed/models/user.dart';
import 'package:savemed/features/profile/profile_page.dart';
import 'package:savemed/features/pharmacy/pharmacy_page.dart';
import 'package:savemed/core/controllers/search_controller.dart';
import 'package:savemed/features/cart/cart_page.dart';
import 'package:savemed/features/product_detail/product_detail_page.dart';
import 'package:savemed/features/payment/payment_page.dart';
import 'package:savemed/models/active_ingredient.dart';
import 'package:savemed/core/widgets/inventory_card.dart';
import 'package:savemed/models/inventory_item.dart';
import 'package:savemed/models/medication.dart';
import 'package:savemed/models/pharmacy.dart';
import 'package:savemed/models/postal_address.dart';
import 'package:savemed/models/payment_card.dart';
import 'package:savemed/core/widgets/savemed_button.dart';
import 'package:savemed/core/widgets/savemed_header.dart';
import 'package:savemed/features/payment/payment_result_page.dart';

void main() {
  for (final profile in [false, true]) {
    testWidgets(
      'address failure is not empty state and can retry (profile: $profile)',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        const size = Size(390, 1000);
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final service = _RetryAddressService();
        final addresses = AddressController(service: service);
        await addresses.reloadForUi(1);
        final auth = AuthController()
          ..user = const AppUser(
            id: 1,
            name: 'Cliente teste',
            email: 'cliente@example.invalid',
            role: UserRole.customer,
          );
        final cart = CartController()..addItem(_inventoryItem());
        await tester.pumpWidget(
          _commerceApp(
            cart: cart,
            size: size,
            textScaler: TextScaler.noScaling,
            session: auth,
            addresses: addresses,
            home: profile ? const ProfilePage(initialTab: 1) : const CartPage(),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Não foi possível carregar seus endereços.'),
          findsOneWidget,
        );
        expect(find.text('Nenhum endereço cadastrado'), findsNothing);
        expect(
          find.text('Cadastre um endereço para liberar o frete.'),
          findsNothing,
        );
        service.fail = false;
        final retry = find.widgetWithText(
          TextButton,
          'Tentar carregar endereços novamente',
        );
        await tester.ensureVisible(retry);
        await tester.pumpAndSettle();
        await tester.tap(retry);
        await tester.pumpAndSettle();
        expect(addresses.error, isNull);
        expect(addresses.addresses, hasLength(1));
        expect(find.text('Rua Teste, 10'), findsOneWidget);
        expect(retry, findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
  test('cart rejects other pharmacies and quantities above known stock', () {
    final cart = CartController();
    addTearDown(cart.dispose);
    final item = _inventoryItem(stock: 2);
    expect(cart.addItem(item), isTrue);
    expect(cart.addItem(item), isTrue);
    final revision = cart.shippingInputRevision;
    expect(cart.addItem(item), isFalse);
    cart.increase(cart.items.single);
    expect(cart.totalItems, 2);
    expect(cart.shippingInputRevision, revision);
    expect(cart.addItem(_inventoryItem(pharmacyId: 99)), isFalse);
    expect(cart.pharmacyId, 7);
    expect(cart.totalItems, 2);
    cart.clear();
    expect(cart.addItem(_inventoryItem(pharmacyId: 99)), isTrue);
    expect(cart.pharmacyId, 99);
  });

  testWidgets(
    'cart disables increase at stock limit and enables it after decrease',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      const size = Size(390, 1000);
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final cart = CartController()..addItem(_inventoryItem(stock: 2));
      await tester.pumpWidget(
        _commerceApp(
          cart: cart,
          size: size,
          textScaler: TextScaler.noScaling,
          home: const CartPage(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Aumentar quantidade'));
      await tester.tap(find.byTooltip('Aumentar quantidade'));
      await tester.pumpAndSettle();
      expect(cart.totalItems, 2);
      final limit = find.widgetWithIcon(IconButton, Icons.add);
      expect(tester.widget<IconButton>(limit).onPressed, isNull);
      expect(find.byTooltip('Limite do estoque disponível'), findsOneWidget);
      await tester.tap(find.byTooltip('Diminuir quantidade'));
      await tester.pumpAndSettle();
      expect(cart.totalItems, 1);
      expect(tester.widget<IconButton>(limit).onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('cart product image failure shows its fallback icon', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    const size = Size(390, 1000);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final cart = CartController()
      ..addItem(_inventoryItem(imageUrl: 'invalid://product-image'));

    await tester.pumpWidget(
      _commerceApp(
        cart: cart,
        size: size,
        textScaler: TextScaler.noScaling,
        home: const CartPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.medication_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('header search image failure shows its fallback icon', (
    tester,
  ) async {
    const size = Size(1280, 900);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController()..loading = false;
    final cart = CartController();
    final home = HomeInventoryController()
      ..products = [_inventoryItem(imageUrl: 'invalid://product-image')];
    final search = SearchController(home: home);
    addTearDown(auth.dispose);
    addTearDown(cart.dispose);
    addTearDown(home.dispose);
    addTearDown(search.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthController>.value(value: auth),
          ChangeNotifierProvider<CartController>.value(value: cart),
          ChangeNotifierProvider<SearchController>.value(value: search),
        ],
        child: const MaterialApp(home: Scaffold(body: SaveMedHeader())),
      ),
    );
    await tester.enterText(find.byType(TextField), 'produto');
    await tester.pumpAndSettle();

    expect(find.text('Produto de teste'), findsOneWidget);
    expect(find.byIcon(Icons.medication_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'product card does not report success when stock limit is reached',
    (tester) async {
      final cart = CartController()..addItem(_inventoryItem(stock: 1));
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: cart,
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: InventoryCard(item: _inventoryItem(stock: 1)),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();
      expect(cart.totalItems, 1);
      expect(
        find.textContaining('Não foi possível adicionar mais unidades'),
        findsOneWidget,
      );
      expect(find.text('Produto adicionado ao carrinho'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('paused pharmacy is labeled and cannot be added from a card', (
    tester,
  ) async {
    final cart = CartController();
    addTearDown(cart.dispose);
    final item = _inventoryItem(pharmacyOpen: false);
    expect(cart.addItem(item), isFalse);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: cart,
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 300, child: InventoryCard(item: item)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Loja fechada'), findsOneWidget);
    final button = find
        .ancestor(of: find.text('Loja fechada'), matching: find.byType(InkWell))
        .first;
    expect(tester.widget<InkWell>(button).onTap, isNull);
    expect(cart.totalItems, 0);
    expect(tester.takeException(), isNull);
  });

  for (final scenario in [
    (size: const Size(390, 844), scale: TextScaler.noScaling),
    (size: const Size(320, 568), scale: const TextScaler.linear(2)),
  ]) {
    testWidgets(
      'product detail purchase bar fits ${scenario.size.width}px at scale ${scenario.scale.scale(1)}',
      (tester) async {
        await tester.binding.setSurfaceSize(scenario.size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final cart = CartController();
        addTearDown(cart.dispose);

        await tester.pumpWidget(
          _commerceApp(
            cart: cart,
            size: scenario.size,
            textScaler: scenario.scale,
            home: ProductDetailPage(item: _inventoryItem()),
          ),
        );
        await tester.pumpAndSettle();

        final purchase = find.widgetWithText(FilledButton, 'Adicionar');
        expect(purchase, findsOneWidget);
        expect(tester.getSize(purchase).height, 48);
        await tester.tap(purchase);
        await tester.pumpAndSettle();

        expect(cart.totalItems, 1);
        expect(find.byType(CartPage), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('product detail disables purchase for unavailable stock', (
    tester,
  ) async {
    const size = Size(390, 844);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final cart = CartController();
    addTearDown(cart.dispose);

    await tester.pumpWidget(
      _commerceApp(
        cart: cart,
        size: size,
        textScaler: TextScaler.noScaling,
        home: ProductDetailPage(item: _inventoryItem(stock: 0)),
      ),
    );
    await tester.pumpAndSettle();

    final unavailable = find.widgetWithText(FilledButton, 'Esgotado');
    expect(unavailable, findsOneWidget);
    expect(tester.widget<FilledButton>(unavailable).onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('product detail explains when its pharmacy is paused', (
    tester,
  ) async {
    const size = Size(390, 844);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final cart = CartController();
    addTearDown(cart.dispose);

    await tester.pumpWidget(
      _commerceApp(
        cart: cart,
        size: size,
        textScaler: TextScaler.noScaling,
        home: ProductDetailPage(item: _inventoryItem(pharmacyOpen: false)),
      ),
    );
    await tester.pumpAndSettle();

    final unavailable = find.widgetWithText(FilledButton, 'Loja fechada');
    expect(unavailable, findsOneWidget);
    expect(tester.widget<FilledButton>(unavailable).onPressed, isNull);
    expect(cart.totalItems, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('product detail opens its pharmacy store and filters products', (
    tester,
  ) async {
    const size = Size(390, 1000);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final cart = CartController();
    addTearDown(cart.dispose);
    String? requestedPath;
    final storeInventory = InventoryService(
      get: (path, {query}) async {
        requestedPath = path;
        return http.Response(
          jsonEncode([
            {
              'ID': 12,
              'PRICE': 19.9,
              'ORIGINAL_PRICE': 22,
              'STOCK': 2,
              'Medication': {
                'ID': 14,
                'NAME': 'Protetor Solar',
                'DESCRIPTION': 'FPS 50',
                'CATEGORY_ID': 3,
              },
            },
          ]),
          200,
        );
      },
    );

    await tester.pumpWidget(
      _commerceApp(
        cart: cart,
        size: size,
        textScaler: TextScaler.noScaling,
        home: ProductDetailPage(item: _inventoryItem(pharmacyOpen: false)),
        storeInventory: storeInventory,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Farmácia Central'));
    await tester.tap(find.widgetWithText(TextButton, 'Farmácia Central'));
    await tester.pumpAndSettle();

    expect(requestedPath, '/inventory/pharmacy/7');
    expect(find.text('Farmácia Central'), findsNWidgets(2));
    expect(find.text('Temporariamente fechada'), findsOneWidget);
    expect(find.text('Protetor Solar'), findsOneWidget);
    expect(find.text('Loja fechada'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Buscar produtos nesta farmácia',
      ),
      'vitamina',
    );
    await tester.pumpAndSettle();
    expect(find.text('Protetor Solar'), findsNothing);
    expect(
      find.text('Nenhum produto encontrado nesta farmácia.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final layout in [
    (Size(320, 800), 2.0),
    (Size(390, 844), 1.0),
    (Size(1280, 900), 2.0),
  ]) {
    testWidgets(
      'pharmacy store summary fits ${layout.$1.width}px at ${layout.$2}x text scale',
      (tester) async {
        final size = layout.$1;
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final cart = CartController();
        addTearDown(cart.dispose);
        const pharmacy = Pharmacy(
          id: 7,
          name: 'Farmácia Central com um nome extenso para teste responsivo',
          isOpen: false,
          acceptsPickup: true,
          acceptsOwnDelivery: true,
          preparationMinutes: 25,
        );
        final storeInventory = InventoryService(
          get: (path, {query}) async => http.Response('[]', 200),
        );

        await tester.pumpWidget(
          _commerceApp(
            cart: cart,
            size: size,
            textScaler: TextScaler.linear(layout.$2),
            home: PharmacyPage(
              pharmacy: pharmacy,
              inventoryService: storeInventory,
            ),
            storeInventory: storeInventory,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(pharmacy.name), findsOneWidget);
        expect(find.text('Temporariamente fechada'), findsOneWidget);
        expect(find.text('Retirada no local'), findsOneWidget);
        expect(find.text('Entrega da farmácia'), findsOneWidget);
        expect(
          find.bySemanticsLabel('Farmácia temporariamente fechada'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('product detail hides sticky purchase while keyboard is open', (
    tester,
  ) async {
    const size = Size(390, 844);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final cart = CartController();
    addTearDown(cart.dispose);

    await tester.pumpWidget(
      _commerceApp(
        cart: cart,
        size: size,
        textScaler: TextScaler.noScaling,
        viewInsets: const EdgeInsets.only(bottom: 300),
        home: ProductDetailPage(item: _inventoryItem()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Adicionar'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('product detail shows pharmacy-provided product information', (
    tester,
  ) async {
    const size = Size(390, 844);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final semantics = tester.ensureSemantics();
    final cart = CartController();
    addTearDown(cart.dispose);

    await tester.pumpWidget(
      _commerceApp(
        cart: cart,
        size: size,
        textScaler: TextScaler.noScaling,
        home: ProductDetailPage(
          item: _inventoryItem(
            requiresPrescription: true,
            brand: 'Laboratório Teste',
            unit: '30 comprimidos',
            activeIngredients: const [
              ActiveIngredient(id: 1, name: 'Vitamina C'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Informações do produto'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'A farmácia informa que este produto exige apresentação de receita.',
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        'A farmácia informa que este produto exige apresentação de receita.',
      ),
      findsOneWidget,
    );
    expect(find.text('Laboratório Teste'), findsOneWidget);
    expect(find.text('30 comprimidos'), findsOneWidget);
    expect(find.text('Vitamina C'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets(
    'cart requotes quantity and a different address with the same CEP',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      const size = Size(390, 1000);
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final cart = _ShippingCartController()
        ..addItem(_inventoryItem())
        ..selectAddress(PostalAddress.fromJson({'ID': 1, 'CEP': '01002000'}));
      await tester.pumpWidget(
        _commerceApp(
          cart: cart,
          size: size,
          textScaler: TextScaler.noScaling,
          home: const CartPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(cart.quotes, 1);
      await tester.ensureVisible(find.byTooltip('Aumentar quantidade'));
      await tester.tap(find.byTooltip('Aumentar quantidade'));
      await tester.pumpAndSettle();
      expect(cart.totalItems, 2);
      expect(cart.quotes, 2);
      cart.selectAddress(PostalAddress.fromJson({'ID': 2, 'CEP': '01002000'}));
      await tester.pumpAndSettle();
      expect(cart.quotes, 3);
      await tester.pumpAndSettle();
      expect(cart.quotes, 3);
      expect(tester.takeException(), isNull);
    },
  );
  setUpAll(() async {
    await (FontLoader(
      'Montserrat',
    )..addFont(rootBundle.load('assets/fonts/Montserrat-Regular.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  testWidgets(
    'cart explains pharmacy address failure and retries from the UI',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      const size = Size(390, 1000);
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final service = _RetryPharmacyService();
      final pharmacy = PharmacyController(service: service);
      final cart = _ShippingCartController()
        ..addItem(_inventoryItem())
        ..selectAddress(PostalAddress.fromJson({'ID': 1, 'CEP': '01002000'}));
      await tester.pumpWidget(
        _commerceApp(
          cart: cart,
          size: size,
          textScaler: TextScaler.noScaling,
          home: const CartPage(),
          pharmacy: pharmacy,
        ),
      );
      await tester.pumpAndSettle();
      expect(pharmacy.loadingAddress, isFalse);
      expect(cart.quotes, 0);
      expect(
        find.textContaining('Não foi possível carregar o endereço da farmácia'),
        findsOneWidget,
      );
      service.fail = false;
      final retry = find.widgetWithText(
        TextButton,
        'Tentar carregar a farmácia novamente',
      );
      await tester.ensureVisible(retry);
      await tester.pumpAndSettle();
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(service.calls, 2);
      expect(cart.quotes, 1);
      expect(pharmacy.addressError, isNull);
      expect(retry, findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'cart keeps address and delivery when crossing responsive layouts',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final cart = _ShippingCartController()..addItem(_inventoryItem());
      Future<void> resize(double width) async {
        final size = Size(width, 1000);
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(
          _commerceApp(
            cart: cart,
            size: size,
            textScaler: TextScaler.noScaling,
            home: const CartPage(),
          ),
        );
        await tester.pumpAndSettle();
      }

      await resize(390);
      final address = PostalAddress.fromJson({
        'ID': 1,
        'CEP': '01002000',
        'STREET': 'Rua Teste',
        'NUMBER': '10',
        'CITY': 'São Paulo',
        'STATE': 'SP',
      });
      cart.selectAddress(address);
      await tester.pumpAndSettle();
      cart.selectShipping(cart.localDeliveryOptions.single);
      await tester.pumpAndSettle();
      expect(cart.quotes, 1);
      for (final width in [1280.0, 390.0, 1280.0]) {
        await resize(width);
        expect(cart.selectedAddress, address);
        expect(cart.isPickupSelected, isTrue);
        expect(cart.quotes, 1);
        expect(tester.takeException(), isNull);
      }
      cart.clear();
      expect(cart.selectedAddress, isNull);
      expect(cart.selectedShipping, isNull);
      expect(cart.pharmacyId, isNull);
      await tester.pumpAndSettle();
    },
  );
  testWidgets('mounting cart summary does not discard an existing address', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    const size = Size(390, 1000);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final address = PostalAddress.fromJson({
      'ID': 1,
      'CEP': '01002000',
      'STREET': 'Rua Teste',
      'NUMBER': '10',
    });
    final cart = _ShippingCartController()
      ..addItem(_inventoryItem())
      ..selectAddress(address);
    await tester.pumpWidget(
      _commerceApp(
        cart: cart,
        size: size,
        textScaler: TextScaler.noScaling,
        home: const CartPage(),
      ),
    );
    await tester.pumpAndSettle();
    expect(cart.selectedAddress, address);
    expect(cart.quotes, 1);
    expect(tester.takeException(), isNull);
  });
  for (final (width, scale) in [(390.0, 1.0), (320.0, 2.0), (1280.0, 1.0)]) {
    testWidgets(
      'cart review bar fits and navigates at $width px scale $scale',
      (tester) async {
        final size = Size(width, 1000);
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        addTearDown(tester.view.resetViewInsets);
        SharedPreferences.setMockInitialValues({});
        final cart = CartController()..addItem(_inventoryItem());
        await tester.pumpWidget(
          _commerceApp(
            cart: cart,
            size: size,
            textScaler: TextScaler.linear(scale),
            home: const CartPage(),
          ),
        );
        await tester.pumpAndSettle();
        final review = find.widgetWithText(FilledButton, 'Revisar pedido');
        if (width >= 1040) {
          expect(review, findsNothing);
        } else {
          expect(review, findsOneWidget);
          final position = tester.getTopLeft(review);
          expect(
            tester.getBottomRight(review).dy,
            lessThanOrEqualTo(size.height),
          );
          cart.addItem(_inventoryItem());
          await tester.pumpAndSettle();
          final bottomBar = tester
              .widget<Scaffold>(find.byType(Scaffold).first)
              .bottomNavigationBar!;
          expect(
            find.descendant(
              of: find.byWidget(bottomBar),
              matching: find.text(formatBrl(25)),
            ),
            findsOneWidget,
          );
          await tester.tap(review);
          await tester.pumpAndSettle();
          expect(tester.getTopLeft(review), position);
          final summary = tester.getRect(find.text('Resumo da compra'));
          expect(summary.top, greaterThanOrEqualTo(0));
          expect(summary.bottom, lessThan(position.dy));
          await expectLater(
            find.byType(CartPage),
            matchesGoldenFile('goldens/cart_review_${width.toInt()}.png'),
          );
          tester.view.viewInsets = const FakeViewPadding(bottom: 300);
          await tester.pumpAndSettle();
          expect(review, findsNothing);
          tester.view.resetViewInsets();
          await tester.pumpAndSettle();
          expect(review, findsOneWidget);
          cart.clear();
          await tester.pumpAndSettle();
          expect(review, findsNothing);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('header cart opens through accessibility action', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _commerceApp(
        cart: CartController(),
        size: const Size(800, 600),
        textScaler: TextScaler.noScaling,
        home: Scaffold(body: SaveMedHeader()),
      ),
    );
    await tester.pumpAndSettle();
    for (final label in [
      'Ir para a página inicial',
      'Entrar na conta',
      'Abrir carrinho, vazio',
    ]) {
      final node = tester.getSemantics(find.bySemanticsLabel(label));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    }
    final node = tester.getSemantics(
      find.bySemanticsLabel('Abrir carrinho, vazio'),
    );
    tester.binding.rootPipelineOwner.visitChildren((owner) {
      owner.semanticsOwner?.performAction(node.id, SemanticsAction.tap);
    });
    await tester.pumpAndSettle();
    expect(find.byType(CartPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('out of stock product exposes no accessible purchase action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final cart = CartController();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: cart,
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: InventoryCard(item: _inventoryItem(stock: 0)),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final node = tester.getSemantics(
      find.bySemanticsLabel('Produto de teste: Esgotado'),
    );
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    expect(cart.totalItems, 0);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  for (final method in ['Crédito', 'Débito']) {
    for (final outcome in ['paid', 'failed']) {
      testWidgets('$method pending blocks retries then resolves to $outcome', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({});
        await tester.binding.setSurfaceSize(const Size(390, 1100));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final cart = CartController()..addItem(_inventoryItem());
        final payment = _PendingPaymentController();
        final cards = _TestCardController();
        await tester.pumpWidget(
          _commerceApp(
            cart: cart,
            size: const Size(390, 1100),
            textScaler: TextScaler.noScaling,
            home: const PaymentPage(orderId: 42),
            payment: payment,
            cards: cards,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(method).first);
        await tester.pump();
        final pay = find.widgetWithText(SaveMedButton, 'Pagar agora');
        await tester.ensureVisible(pay);
        await tester.tap(pay);
        await tester.pump();
        expect(payment.calls, 1);
        expect(payment.receivedCardDetails, isTrue);
        expect(cards.cards, isEmpty);
        expect(cards.selected, isNull);
        expect(tester.widget<SaveMedButton>(pay).onPressed, isNull);
        expect(cart.subtotal, greaterThan(0));
        expect(find.textContaining('Não pague novamente'), findsOneWidget);
        payment.status = outcome;
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        if (outcome == 'paid') {
          expect(cart.subtotal, 0);
          expect(find.byType(PaymentResultPage), findsOneWidget);
        } else {
          expect(cart.subtotal, greaterThan(0));
          expect(tester.widget<SaveMedButton>(pay).onPressed, isNull);
          expect(find.text('Nenhum cartão informado.'), findsOneWidget);
          expect(find.text('Adicionar cartão'), findsOneWidget);
          expect(find.textContaining('Pagamento não aprovado'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  for (final status in <String?>['paid', 'pending', 'failed', null]) {
    testWidgets('uncertain card result reconciles before retry ($status)', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(const Size(390, 1100));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final cart = CartController()..addItem(_inventoryItem());
      final payment = _UnknownOutcomePaymentController(status);
      final cards = _TestCardController();
      await tester.pumpWidget(
        _commerceApp(
          cart: cart,
          size: const Size(390, 1100),
          textScaler: TextScaler.noScaling,
          home: const PaymentPage(orderId: 42),
          payment: payment,
          cards: cards,
        ),
      );
      await tester.pumpAndSettle();
      final pay = find.widgetWithText(SaveMedButton, 'Pagar agora');
      await tester.ensureVisible(pay);
      await tester.tap(pay);
      await tester.pump();

      expect(payment.receivedCardDetails, isTrue);
      expect(cards.cards, isEmpty);
      expect(cards.selected, isNull);
      expect(payment.statusChecks, 1);
      if (status == 'paid') {
        await tester.pumpAndSettle();
        expect(cart.subtotal, 0);
        expect(find.byType(PaymentResultPage), findsOneWidget);
      } else if (status == 'failed') {
        expect(cart.subtotal, greaterThan(0));
        expect(tester.widget<SaveMedButton>(pay).onPressed, isNull);
        expect(find.text('Nenhum cartão informado.'), findsOneWidget);
        expect(find.text('Adicionar cartão'), findsOneWidget);
      } else {
        expect(cart.subtotal, greaterThan(0));
        expect(tester.widget<SaveMedButton>(pay).onPressed, isNull);
        expect(
          find.textContaining(
            status == 'pending' ? 'em processamento' : 'resultado da',
          ),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('cart remains usable at 320px with text scaled to 200 percent', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});

    final cart = CartController()..addItem(_inventoryItem());
    await tester.pumpWidget(
      _commerceApp(
        cart: cart,
        size: const Size(320, 1000),
        textScaler: const TextScaler.linear(2),
        home: const CartPage(),
      ),
    );
    await tester.pump();

    expect(find.text('Produtos no carrinho'), findsOneWidget);
    expect(find.byTooltip('Diminuir quantidade'), findsOneWidget);
    expect(find.byTooltip('Aumentar quantidade'), findsOneWidget);
    expect(
      find.widgetWithText(TextButton, 'Remover do carrinho'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('payment methods expose selected semantics and fit mobile text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(320, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      _commerceApp(
        cart: CartController(),
        size: const Size(320, 1000),
        textScaler: const TextScaler.linear(2),
        home: const PaymentPage(orderId: 42),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Crédito, forma de pagamento' &&
            widget.properties.selected == true,
      ),
      findsOneWidget,
    );

    final pixMethod = find.bySemanticsLabel('Pix, forma de pagamento');
    await tester.ensureVisible(pixMethod);
    final pixNode = tester.getSemantics(pixMethod);
    expect(pixNode.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    tester.binding.rootPipelineOwner.visitChildren((owner) {
      owner.semanticsOwner?.performAction(pixNode.id, SemanticsAction.tap);
    });
    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Pix, forma de pagamento' &&
            widget.properties.selected == true,
      ),
      findsOneWidget,
    );
    expect(find.text('Gerar Pix'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('card form does not collect a redundant CPF', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      _commerceApp(
        cart: CartController()..addItem(_inventoryItem()),
        size: const Size(390, 1100),
        textScaler: TextScaler.noScaling,
        home: const PaymentPage(orderId: 42),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar cartão').last);
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'CPF',
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('abandoning payment clears card details from session memory', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final cards = _TestCardController();

    await tester.pumpWidget(
      _commerceApp(
        cart: CartController()..addItem(_inventoryItem()),
        size: const Size(390, 844),
        textScaler: TextScaler.noScaling,
        cards: cards,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PaymentPage(orderId: 42),
                ),
              ),
              child: const Text('Abrir pagamento'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir pagamento'));
    await tester.pumpAndSettle();

    expect(cards.selected?.number, '4000000000000010');
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(cards.cards, isEmpty);
    expect(cards.selected, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('backgrounding clears selected card details from memory', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final cards = _TestCardController();

    await tester.pumpWidget(
      _commerceApp(
        cart: CartController()..addItem(_inventoryItem()),
        size: const Size(390, 844),
        textScaler: TextScaler.noScaling,
        cards: cards,
        home: const PaymentPage(orderId: 42),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('•••• 0010'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpAndSettle();

    expect(cards.cards, isEmpty);
    expect(cards.selected, isNull);
    expect(find.text('Nenhum cartão informado.'), findsOneWidget);
    expect(find.textContaining('foram apagados'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
  });

  testWidgets('backgrounding clears the unsent card form draft', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      _commerceApp(
        cart: CartController()..addItem(_inventoryItem()),
        size: const Size(390, 1100),
        textScaler: TextScaler.noScaling,
        home: const PaymentPage(orderId: 42),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar cartão').last);
    await tester.pumpAndSettle();

    final fields = find.descendant(
      of: find.byType(AlertDialog).last,
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), '4000000000000010');
    await tester.enterText(fields.at(1), 'CLIENTE TESTE');
    await tester.enterText(fields.at(2), '1230');
    await tester.enterText(fields.at(3), '123');
    await tester.pumpAndSettle();
    expect(find.textContaining('0010'), findsWidgets);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpAndSettle();

    for (var index = 0; index < 4; index++) {
      final field = tester.widget<TextField>(fields.at(index));
      expect(field.controller?.text, isEmpty);
    }
    expect(find.byKey(const ValueKey('card-security-message')), findsOneWidget);
    expect(find.textContaining('foram apagados'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
  });

  testWidgets('card form gives inline validation before accepting the card', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final cards = CardController();

    await tester.pumpWidget(
      _commerceApp(
        cart: CartController()..addItem(_inventoryItem()),
        size: const Size(390, 1100),
        textScaler: TextScaler.noScaling,
        cards: cards,
        home: const PaymentPage(orderId: 42),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Adicionar cart'));
    await tester.pumpAndSettle();
    expect(find.text('Usar cartão'), findsOneWidget);
    expect(find.text('Salvar cartão'), findsNothing);
    await tester.tap(find.text('Usar cartão'));
    await tester.pumpAndSettle();

    expect(find.textContaining('13 e 19'), findsOneWidget);
    expect(find.text('Informe o nome do titular.'), findsOneWidget);
    expect(find.text('Informe a validade no formato MM/AA.'), findsOneWidget);
    expect(find.textContaining('CVV de 3 ou 4'), findsOneWidget);
    expect(cards.cards, isEmpty);

    final fields = find.descendant(
      of: find.byType(AlertDialog).last,
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), '4000000000000011');
    await tester.enterText(fields.at(1), 'CLIENTE TESTE');
    await tester.enterText(fields.at(2), '1330');
    await tester.enterText(fields.at(3), '12');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usar cartão'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Confira o número'), findsOneWidget);
    expect(find.text('Informe um mês entre 01 e 12.'), findsOneWidget);
    expect(find.textContaining('CVV de 3 ou 4'), findsOneWidget);
    expect(cards.cards, isEmpty);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'card form accepts valid details and displays only the last four',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1100));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({});
      final cards = CardController();

      await tester.pumpWidget(
        _commerceApp(
          cart: CartController()..addItem(_inventoryItem()),
          size: const Size(390, 1100),
          textScaler: TextScaler.noScaling,
          cards: cards,
          home: const PaymentPage(orderId: 42),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Adicionar cart'));
      await tester.pumpAndSettle();
      final fields = find.descendant(
        of: find.byType(AlertDialog).last,
        matching: find.byType(TextField),
      );
      await tester.enterText(fields.at(0), '4000000000000010');
      await tester.enterText(fields.at(1), 'CLIENTE TESTE');
      await tester.enterText(fields.at(2), '1230');
      await tester.enterText(fields.at(3), '123');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Usar cartão'));
      await tester.pumpAndSettle();

      expect(cards.selected?.last4, '0010');
      expect(cards.selected?.number, '4000000000000010');
      expect(find.textContaining('Nenhum cart'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('card validation fits 320px with 200 percent text', (
    tester,
  ) async {
    const size = Size(320, 800);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      _commerceApp(
        cart: CartController()..addItem(_inventoryItem()),
        size: size,
        textScaler: const TextScaler.linear(2),
        home: const PaymentPage(orderId: 42),
      ),
    );
    await tester.pumpAndSettle();
    final addCard = find.textContaining('Adicionar cart');
    await tester.ensureVisible(addCard);
    await tester.tap(addCard);
    await tester.pumpAndSettle();

    final useCard = find.text('Usar cartão');
    await tester.ensureVisible(useCard);
    await tester.tap(useCard);
    await tester.pumpAndSettle();

    final dialogRect = tester.getRect(find.byType(AlertDialog).last);
    expect(dialogRect.left, greaterThanOrEqualTo(0));
    expect(dialogRect.right, lessThanOrEqualTo(size.width));
    expect(dialogRect.top, greaterThanOrEqualTo(0));
    expect(dialogRect.bottom, lessThanOrEqualTo(size.height));
    expect(find.text('Informe o nome do titular.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('product card is keyboard accessible with enlarged text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartController(),
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 800),
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(
              body: Center(child: InventoryCard(item: _inventoryItem())),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Abrir detalhes de Produto de teste' &&
            widget.properties.button == true,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label ==
                'Adicionar Produto de teste ao carrinho' &&
            widget.properties.button == true,
      ),
      findsOneWidget,
    );
    final addNode = tester.getSemantics(
      find.bySemanticsLabel('Adicionar Produto de teste ao carrinho'),
    );
    expect(addNode.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    tester.binding.rootPipelineOwner.visitChildren((owner) {
      owner.semanticsOwner?.performAction(addNode.id, SemanticsAction.tap);
    });
    await tester.pump();
    expect(
      tester
          .element(find.byType(InventoryCard))
          .read<CartController>()
          .totalItems,
      1,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}

Widget _commerceApp({
  required CartController cart,
  required Size size,
  required TextScaler textScaler,
  required Widget home,
  PaymentController? payment,
  CardController? cards,
  PharmacyController? pharmacy,
  AddressController? addresses,
  AuthController? session,
  EdgeInsets? viewInsets,
  InventoryService? storeInventory,
}) {
  final inventory = HomeInventoryController();
  final auth = session ?? (AuthController()..loading = false);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>.value(value: auth),
      ChangeNotifierProvider<CartController>.value(value: cart),
      ChangeNotifierProvider<HomeInventoryController>.value(value: inventory),
      ChangeNotifierProvider<SearchController>(
        create: (_) => SearchController(home: inventory),
      ),
      ChangeNotifierProvider<AddressController>(
        create: (_) => addresses ?? AddressController(),
      ),
      ChangeNotifierProvider<PharmacyController>(
        create: (_) => pharmacy ?? _FakePharmacyController(),
      ),
      ChangeNotifierProvider<CardController>(
        create: (_) => cards ?? CardController(),
      ),
      ChangeNotifierProvider<PaymentController>(
        create: (_) => payment ?? PaymentController(),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      routes: {
        AppRoutes.pharmacy: (context) {
          final pharmacy = ModalRoute.of(context)?.settings.arguments;
          if (pharmacy is Pharmacy) {
            return PharmacyPage(
              pharmacy: pharmacy,
              inventoryService: storeInventory,
            );
          }
          return const Scaffold(
            body: Center(child: Text('Não foi possível abrir esta farmácia.')),
          );
        },
      },
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(size: size, textScaler: textScaler, viewInsets: viewInsets),
        child: child!,
      ),
      home: home,
    ),
  );
}

class _TestCardController extends CardController {
  _TestCardController() {
    selected = PaymentCard(
      id: 'test',
      brand: 'Visa',
      last4: '0010',
      expMonth: 12,
      expYear: 2030,
      number: '4000000000000010',
      holderName: 'TESTE',
      cvv: '123',
    );
    cards.add(selected!);
  }
  @override
  Future<void> loadCards() async {}
}

class _PendingPaymentController extends PaymentController {
  int calls = 0;
  String status = 'pending';
  bool receivedCardDetails = false;
  @override
  Future<Map<String, dynamic>> pay({
    required int orderId,
    required double amount,
    required PaymentMethod method,
    Map<String, dynamic>? card,
    required Map<String, dynamic> customer,
    required String deviceId,
  }) async {
    calls++;
    receivedCardDetails =
        card != null &&
        card['number'] == '4000000000000010' &&
        card['holderName'] == 'TESTE' &&
        card['cvv'] == '123';
    return {'success': false, 'status': 'pending', 'code': 'PAYMENT_PENDING'};
  }

  @override
  Future<String?> checkStatus({required int orderId}) async => status;
}

class _UnknownOutcomePaymentController extends PaymentController {
  final String? status;
  int statusChecks = 0;
  bool receivedCardDetails = false;

  _UnknownOutcomePaymentController(this.status);

  @override
  Future<Map<String, dynamic>> pay({
    required int orderId,
    required double amount,
    required PaymentMethod method,
    Map<String, dynamic>? card,
    required Map<String, dynamic> customer,
    required String deviceId,
  }) async {
    receivedCardDetails =
        card != null &&
        card['number'] == '4000000000000010' &&
        card['holderName'] == 'TESTE' &&
        card['cvv'] == '123';
    return {
      'success': false,
      'outcome_unknown': true,
      'message': 'Network timeout',
    };
  }

  @override
  Future<String?> checkStatus({required int orderId}) async {
    statusChecks++;
    return status;
  }
}

InventoryItem _inventoryItem({
  int stock = 8,
  int pharmacyId = 7,
  bool pharmacyOpen = true,
  bool requiresPrescription = false,
  String? imageUrl,
  String? brand,
  String? unit,
  List<ActiveIngredient> activeIngredients = const [],
}) {
  return InventoryItem(
    id: 3,
    price: 12.5,
    originalPrice: 15,
    stock: stock,
    pharmacy: Pharmacy(
      id: pharmacyId,
      name: 'Farmácia Central',
      isOpen: pharmacyOpen,
      acceptsPickup: true,
    ),
    medication: Medication(
      id: 5,
      name: 'Produto de teste',
      description: 'Descrição',
      image: imageUrl,
      categoryId: 2,
      requiresPrescription: requiresPrescription,
      brand: brand,
      unit: unit,
      activeIngredients: activeIngredients,
    ),
  );
}

class _FakePharmacyController extends PharmacyController {
  @override
  Future<void> loadAddress(int pharmacyId) async {
    addressPharmacyId = pharmacyId;
    pharmacyAddress = PostalAddress.fromJson({'CEP': '01001000'});
    notifyListeners();
  }
}

class _ShippingCartController extends CartController {
  int quotes = 0;
  @override
  Future<void> calculateShipping(String fromCep) async {
    quotes++;
  }
}

class _RetryAddressService extends AddressService {
  bool fail = true;
  @override
  Future<List<PostalAddress>> getUserAddresses(int userId) async {
    if (fail) throw Exception('isolated failure');
    return [
      PostalAddress.fromJson({
        'ID': 1,
        'STREET': 'Rua Teste',
        'NUMBER': '10',
        'CITY': 'São Paulo',
        'STATE': 'SP',
        'CEP': '01001000',
      }),
    ];
  }
}

class _RetryPharmacyService extends PharmacyService {
  bool fail = true;
  int calls = 0;
  @override
  Future<PostalAddress> getPharmacyAddress(int pharmacyId) async {
    calls++;
    if (fail) throw Exception('isolated network failure');
    return PostalAddress.fromJson({'CEP': '01001000'});
  }
}
