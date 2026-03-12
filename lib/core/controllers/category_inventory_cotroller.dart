import 'package:flutter/material.dart';
import '../../models/inventory_item.dart';
import '../services/inventory_service.dart';

enum InventoryOrder { priceAsc, priceDesc }

class CategoryInventoryController extends ChangeNotifier {
  final InventoryService _service = InventoryService();

  bool loading = false;

  int? categoryId;
  int? subcategoryId;
  InventoryOrder? order;

  List<InventoryItem> items = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();

    try {
      items = await _service.getInventory(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        order: order == InventoryOrder.priceAsc
            ? 'price_asc'
            : order == InventoryOrder.priceDesc
            ? 'price_desc'
            : null,
      );
    } catch (e) {
      debugPrint('Erro ao carregar categoria: $e');
    }

    loading = false;
    notifyListeners();
  }

  void setCategory(int id) {
    categoryId = id;
    subcategoryId = null;
    load();
  }

  void setSubcategory(int? id) {
    subcategoryId = id;
    load();
  }

  void setOrder(InventoryOrder? value) {
    order = value;
    load();
  }
}
