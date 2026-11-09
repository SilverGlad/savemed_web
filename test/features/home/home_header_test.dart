import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/controllers/category_controller.dart';
import 'package:savemed/core/controllers/home_inventory_controller.dart';
import 'package:savemed/core/controllers/search_controller.dart';
import 'package:savemed/core/services/category_service.dart';
import 'package:savemed/core/services/inventory_service.dart';
import 'package:savemed/core/storage/token_storage.dart';
import 'package:savemed/core/theme/app_theme.dart';
import 'package:savemed/core/widgets/savemed_header.dart';
import 'package:savemed/features/home/home_page.dart';
import 'package:savemed/models/category.dart';
import 'package:savemed/models/inventory_item.dart';

import '../../support/in_memory_token_vault.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('Montserrat')
      ..addFont(rootBundle.load('assets/fonts/Montserrat-Regular.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  testWidgets('home keeps the shared header visible while catalog scrolls', (
    tester,
  ) async {
    const viewport = Size(390, 844);
    await tester.binding.setSurfaceSize(viewport);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    TokenStorage.resetForTesting();
    TokenStorage.setVaultForTesting(InMemoryTokenVault());

    final apiClient = MockClient((_) async => http.Response('{}', 503));
    ApiClient.setClientForTesting(apiClient);
    final auth = AuthController()..loading = false;
    final cart = CartController();
    final home = HomeInventoryController(service: _TestInventoryService());
    final categories = CategoryController(
      categoryService: _EmptyCategoryService(),
    );
    final search = SearchController(home: home);
    addTearDown(() {
      apiClient.close();
      ApiClient.setClientForTesting(null);
      auth.dispose();
      cart.dispose();
      home.dispose();
      categories.dispose();
      search.dispose();
      TokenStorage.resetForTesting();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthController>.value(value: auth),
          ChangeNotifierProvider<CartController>.value(value: cart),
          ChangeNotifierProvider<HomeInventoryController>.value(value: home),
          ChangeNotifierProvider<CategoryController>.value(value: categories),
          ChangeNotifierProvider<SearchController>.value(value: search),
        ],
        child: MaterialApp(theme: AppTheme.light, home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    final header = find.byType(SaveMedHeader);
    expect(header, findsOneWidget);
    final initialHeaderRect = tester.getRect(header);
    expect(initialHeaderRect.top, greaterThanOrEqualTo(0));

    final scrollable = find.byType(CustomScrollView);
    await tester.drag(scrollable, const Offset(0, -600));
    await tester.pumpAndSettle();

    final scrollState = tester.state<ScrollableState>(
      find.descendant(of: scrollable, matching: find.byType(Scrollable)).first,
    );
    expect(scrollState.position.pixels, greaterThan(0));
    final scrolledHeaderRect = tester.getRect(header);
    expect(scrolledHeaderRect.top, initialHeaderRect.top);
    expect(scrolledHeaderRect.bottom, lessThan(viewport.height));
    if (!kIsWeb) {
      await expectLater(
        find.byType(HomePage),
        matchesGoldenFile('goldens/home_header_fixed_390.png'),
      );
    }
    expect(tester.takeException(), isNull);
  });
}

class _EmptyCategoryService extends CategoryService {
  @override
  Future<List<Category>> getCategories() async => [];
}

class _TestInventoryService extends InventoryService {
  final items = List.generate(
    12,
    (index) => InventoryItem.fromJson({
      'ID': index + 1,
      'PRICE': 12.5 + index,
      'ORIGINAL_PRICE': 20 + index,
      'STOCK': 5,
      'Pharmacy': {'ID': 1, 'NAME': 'Farmácia Teste'},
      'Medication': {
        'ID': index + 1,
        'NAME': 'Produto de teste ${index + 1}',
        'DESCRIPTION': 'Apresentação de teste',
        'CATEGORY_ID': 1,
      },
    }),
  );

  @override
  Future<List<InventoryItem>> getInventory({
    bool highlightOnly = false,
    String? order,
    int? categoryId,
    int? subcategoryId,
    double? minPrice,
    double? maxPrice,
    bool? onlyAvailable = false,
  }) async => items;
}
