import '../../models/inventory_item.dart';
import '../api/api_client.dart';
import '../api/api_response.dart';

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
        if (minPrice != null) 'min_price': '$minPrice',
        if (maxPrice != null) 'max_price': '$maxPrice',
        if (onlyAvailable == true) 'only_available': 'true',
      },
    );
    final data = ApiResponse.list(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao buscar inventario',
    );
    return data
        .whereType<Map<String, dynamic>>()
        .map(InventoryItem.fromJson)
        .toList();
  }
}
