import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/controllers/home_inventory_controller.dart';
import 'package:savemed/core/services/inventory_service.dart';
import 'package:savemed/features/home/widgets/catalog_status.dart';
import 'package:savemed/models/inventory_item.dart';

void main() {
  testWidgets('partial catalog warning and retry fit 320px at 200% text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    const size = Size(320, 640);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = HomeInventoryController(
      service: _RetryInventoryService(_inventoryItem()),
    );
    await controller.load();

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(2),
        ),
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ListenableBuilder(
                listenable: controller,
                builder: (_, __) => HomeCatalogStatus(controller: controller),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Catálogo parcialmente carregado'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.text('Catálogo parcialmente carregado'))
          .getSemanticsData()
          .flagsCollection
          .isLiveRegion,
      isTrue,
    );
    expect(tester.takeException(), isNull);

    final retry = find.widgetWithText(OutlinedButton, 'Tentar novamente');
    await tester.ensureVisible(retry);
    await tester.tap(retry);
    await tester.pumpAndSettle();

    expect(controller.error, isNull);
    expect(find.text('Catálogo parcialmente carregado'), findsNothing);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}

class _RetryInventoryService extends InventoryService {
  final InventoryItem item;
  int _calls = 0;

  _RetryInventoryService(this.item);

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

InventoryItem _inventoryItem() {
  return InventoryItem.fromJson({
    'ID': 2,
    'PRICE': 12.50,
    'STOCK': 4,
    'Pharmacy': {'ID': 2, 'NAME': 'Farmacia'},
    'Medication': {'ID': 2, 'NAME': 'Paracetamol', 'CATEGORY_ID': 3},
  });
}
