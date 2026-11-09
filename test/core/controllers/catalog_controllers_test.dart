import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/controllers/home_inventory_controller.dart';
import 'package:savemed/core/controllers/search_controller.dart';
import 'package:savemed/core/services/inventory_service.dart';
import 'package:savemed/models/inventory_item.dart';

void main() {
  test('home inventory exposes successful and empty catalog states', () async {
    final item = _inventoryItem(1, 'Dipirona');
    final controller = HomeInventoryController(
      service: _FakeInventoryService(items: [item]),
    );

    await controller.load();

    expect(controller.loading, isFalse);
    expect(controller.error, isNull);
    expect(controller.products, [item]);
    expect(controller.isEmpty, isFalse);

    final emptyController = HomeInventoryController(
      service: _FakeInventoryService(),
    );
    await emptyController.load();
    expect(emptyController.isEmpty, isTrue);
    expect(emptyController.error, isNull);
  });

  test('home inventory preserves a recoverable load error', () async {
    final controller = HomeInventoryController(
      service: _FakeInventoryService(error: Exception('offline')),
    );

    await controller.load();

    expect(controller.loading, isFalse);
    expect(controller.error, isNotNull);
    expect(controller.isEmpty, isTrue);
  });

  test(
    'home inventory keeps successful sections when one request fails',
    () async {
      final item = _inventoryItem(2, 'Paracetamol');
      final service = _PartiallyFailingInventoryService(item);
      final controller = HomeInventoryController(service: service);

      await controller.load();

      expect(controller.error, isNotNull);
      expect(controller.highlights, isEmpty);
      expect(controller.products, [item]);
      expect(controller.bestSellers, isEmpty);
      expect(controller.isEmpty, isFalse);

      await controller.load();

      expect(controller.error, isNull);
      expect(controller.isEmpty, isTrue);
    },
  );

  test(
    'home inventory preserves the last catalog during an offline refresh',
    () async {
      final item = _inventoryItem(3, 'Soro fisiológico');
      final controller = HomeInventoryController(
        service: _OfflineAfterInitialLoadInventoryService(item),
      );

      await controller.load();
      expect(controller.products, [item]);

      await controller.load();

      expect(controller.error, isNotNull);
      expect(controller.products, [item]);
      expect(controller.isEmpty, isFalse);
    },
  );

  test('catalog search removes products repeated between home sections', () {
    final item = _inventoryItem(7, 'Protetor solar');
    final home = HomeInventoryController()
      ..products = [item]
      ..highlights = [item]
      ..bestSellers = [item];
    final search = SearchController(home: home);

    search.search('protetor');

    expect(search.products, [item]);
  });
}

class _FakeInventoryService extends InventoryService {
  final List<InventoryItem> items;
  final Object? error;

  _FakeInventoryService({this.items = const [], this.error});

  @override
  Future<List<InventoryItem>> getInventory({
    bool highlightOnly = false,
    String? order,
    int? categoryId,
    int? subcategoryId,
    double? minPrice,
    double? maxPrice,
    bool? onlyAvailable = false,
  }) async {
    if (error != null) throw error!;
    return items;
  }
}

class _PartiallyFailingInventoryService extends InventoryService {
  final InventoryItem item;
  int _calls = 0;

  _PartiallyFailingInventoryService(this.item);

  @override
  Future<List<InventoryItem>> getInventory({
    bool highlightOnly = false,
    String? order,
    int? categoryId,
    int? subcategoryId,
    double? minPrice,
    double? maxPrice,
    bool? onlyAvailable = false,
  }) async {
    _calls++;
    if (_calls == 1) throw Exception('temporary connection failure');
    if (_calls == 2) return [item];
    return const [];
  }
}

class _OfflineAfterInitialLoadInventoryService extends InventoryService {
  final InventoryItem item;
  int _calls = 0;

  _OfflineAfterInitialLoadInventoryService(this.item);

  @override
  Future<List<InventoryItem>> getInventory({
    bool highlightOnly = false,
    String? order,
    int? categoryId,
    int? subcategoryId,
    double? minPrice,
    double? maxPrice,
    bool? onlyAvailable = false,
  }) async {
    _calls++;
    if (_calls > 3) throw Exception('network unavailable');
    if (_calls == 2) return [item];
    return const [];
  }
}

InventoryItem _inventoryItem(int id, String name) {
  return InventoryItem.fromJson({
    'ID': id,
    'PRICE': 12.50,
    'ORIGINAL_PRICE': 15,
    'STOCK': 4,
    'Pharmacy': {'ID': 2, 'NAME': 'Farmacia'},
    'Medication': {
      'ID': id,
      'NAME': name,
      'DESCRIPTION': 'Descricao do produto',
      'CATEGORY_ID': 3,
    },
  });
}
