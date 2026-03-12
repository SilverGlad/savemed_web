import 'dart:convert';

import '../../models/inventory_item.dart';
import '../api/api_client.dart';

class InventoryService {
  Future<List<InventoryItem>> getInventory({
    bool highlightOnly = false,
    String? order,
    int? categoryId,
    int? subcategoryId,
    double? minPrice,
    double? maxPrice,
    bool? onlyAvailable = false,
  }) async {
    final response = await ApiClient.get(
      highlightOnly ? '/inventory/highlights' : '/inventory',
      query: {
        if (order != null) 'order': order,
        if (categoryId != null) 'category_id': '$categoryId',
        if (subcategoryId != null) 'subcategory_id': '$subcategoryId',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar inventory');
    }

    final data = jsonDecode(response.body) as List;

    return data.map((e) => InventoryItem.fromJson(e)).toList();
  }
}
