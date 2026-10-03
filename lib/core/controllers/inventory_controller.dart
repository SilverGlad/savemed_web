import 'package:flutter/material.dart';

import '../../models/inventory_item.dart';
import '../services/inventory_service.dart';
import '../logging/app_logger.dart';

enum InventoryOrder { relevance, priceAsc, priceDesc, nameAsc }

class InventoryController extends ChangeNotifier {
  final InventoryService inventoryService;

  InventoryController({required this.inventoryService});

  // ======================
  // ESTADO
  // ======================
  bool loading = false;
  Object? error;

  List<InventoryItem> allItems = [];
  List<InventoryItem> items = [];

  // ======================
  // FILTROS
  // ======================
  int? categoryId;
  int? subcategoryId;

  bool onlyAvailable = false;
  bool onlyHighlight = false;

  InventoryOrder order = InventoryOrder.relevance;

  // ======================
  // LOAD
  // ======================
  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      allItems = await inventoryService.getInventory();
      _applyFilters();
    } catch (loadError) {
      error = loadError;
      AppLogger.event(AppLogEvent.inventoryLoadFailed);
    }

    loading = false;
    notifyListeners();
  }

  // ======================
  // FILTRAGEM CENTRAL
  // ======================
  void _applyFilters() {
    items = allItems.where((item) {
      final med = item.medication;

      if (categoryId != null && med.categoryId != categoryId) return false;
      if (subcategoryId != null && med.subcategoryId != subcategoryId) {
        return false;
      }
      if (onlyAvailable && item.stock <= 0) return false;
      if (onlyHighlight && item.originalPrice <= item.price) return false;

      // 🔎 BUSCA TEXTUAL
      if (search.isNotEmpty) {
        final text = ('${med.name} ${med.description} ').toLowerCase();

        if (!text.contains(search)) return false;
      }

      return true;
    }).toList();

    _applyOrder();
  }

  void _applyOrder() {
    switch (order) {
      case InventoryOrder.priceAsc:
        items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case InventoryOrder.priceDesc:
        items.sort((a, b) => b.price.compareTo(a.price));
        break;
      case InventoryOrder.nameAsc:
        items.sort((a, b) => a.medication.name.compareTo(b.medication.name));
        break;
      case InventoryOrder.relevance:
        // ordem da API
        break;
    }
  }

  // ======================
  // BUSCA
  // ======================
  String search = '';

  void setSearch(String value) {
    search = value.toLowerCase().trim();
    _applyFilters();
    notifyListeners();
  }

  // ======================
  // SETTERS
  // ======================
  void setCategory(int id) {
    categoryId = id;
    subcategoryId = null;
    _applyFilters();
    notifyListeners();
  }

  void setSubcategory(int value) {
    subcategoryId = value;
    _applyFilters();
    notifyListeners();
  }

  void setOnlyAvailable(bool value) {
    onlyAvailable = value;
    _applyFilters();
    notifyListeners();
  }

  void setOnlyHighlight(bool value) {
    onlyHighlight = value;
    _applyFilters();
    notifyListeners();
  }

  void setOrder(InventoryOrder value) {
    order = value;
    _applyOrder();
    notifyListeners();
  }
}
