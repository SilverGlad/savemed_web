import 'package:flutter/material.dart';
import '../../models/inventory_item.dart';
import '../services/inventory_service.dart';
import '../logging/app_logger.dart';

class HomeInventoryController extends ChangeNotifier {
  final InventoryService _service;

  HomeInventoryController({InventoryService? service})
    : _service = service ?? InventoryService();

  bool loading = false;
  Object? error;

  List<InventoryItem> highlights = [];
  List<InventoryItem> products = [];
  List<InventoryItem> bestSellers = [];

  Future<void> load() async {
    if (loading) return;

    loading = true;
    error = null;
    notifyListeners();

    final results = await Future.wait([
      _loadSection(highlightOnly: true),
      _loadSection(),
      _loadSection(order: 'price_desc'),
    ]);

    if (results[0] != null) highlights = results[0]!;
    if (results[1] != null) products = results[1]!;
    if (results[2] != null) bestSellers = results[2]!;

    if (error != null) {
      AppLogger.event(AppLogEvent.homeInventoryLoadFailed);
    }

    loading = false;
    notifyListeners();
  }

  Future<List<InventoryItem>?> _loadSection({
    bool highlightOnly = false,
    String? order,
  }) async {
    try {
      return await _service.getInventory(
        highlightOnly: highlightOnly,
        order: order,
      );
    } catch (loadError) {
      error ??= loadError;
      return null;
    }
  }

  bool get isEmpty =>
      highlights.isEmpty && products.isEmpty && bestSellers.isEmpty;
}
