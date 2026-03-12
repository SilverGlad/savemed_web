import 'package:flutter/material.dart';
import 'home_inventory_controller.dart';
import '../../models/inventory_item.dart';

class SearchController extends ChangeNotifier {
  final HomeInventoryController home;

  SearchController({required this.home});

  String query = '';
  List<InventoryItem> products = [];

  void search(String value) {
    query = value.trim();

    if (query.length < 2) {
      products = [];
      notifyListeners();
      return;
    }

    final q = query.toLowerCase();

    final allItems = [
      ...home.products,
      ...home.highlights,
      ...home.bestSellers,
    ];

    products = allItems.where((item) {
      final med = item.medication;

      final text = ('${med.name} ${med.description} ').toLowerCase();

      return text.contains(q);
    }).toList();

    debugPrint('SEARCH → inventory items: ${allItems.length}');
    debugPrint('SEARCH → query: $query');
    debugPrint('SEARCH → products found: ${products.length}');

    notifyListeners();
  }

  void clear() {
    query = '';
    products = [];
    notifyListeners();
  }
}
