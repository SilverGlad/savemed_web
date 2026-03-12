import 'package:flutter/material.dart';
import '../../models/inventory_item.dart';
import '../services/inventory_service.dart';

class HomeInventoryController extends ChangeNotifier {
  final InventoryService _service = InventoryService();

  bool loading = false;

  List<InventoryItem> highlights = [];
  List<InventoryItem> products = [];
  List<InventoryItem> bestSellers = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();

    try {
      highlights = await _service.getInventory(highlightOnly: true);
      products = await _service.getInventory();
      bestSellers = await _service.getInventory(order: 'price_desc');
    } catch (e) {
      debugPrint('Erro ao carregar home inventory: $e');
    }

    loading = false;
    notifyListeners();
  }
}
