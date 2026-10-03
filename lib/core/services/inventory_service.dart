import 'package:http/http.dart' as http;

import '../../models/inventory_item.dart';
import '../../models/pharmacy.dart';
import '../api/api_client.dart';
import '../api/api_response.dart';

typedef InventoryGet =
    Future<http.Response> Function(String path, {Map<String, String>? query});

class InventoryService {
  final InventoryGet _get;

  InventoryService({InventoryGet? get}) : _get = get ?? ApiClient.get;

  Future<List<InventoryItem>> getInventory({
    bool highlightOnly = false,
    String? order,
    int? categoryId,
    int? subcategoryId,
    double? minPrice,
    double? maxPrice,
    bool? onlyAvailable = false,
  }) async {
    final response = await _get(
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
      fallback: 'Erro ao buscar inventário',
    );
    return data
        .whereType<Map<String, dynamic>>()
        .map(InventoryItem.fromJson)
        .toList();
  }

  Future<List<InventoryItem>> getInventoryForPharmacy(Pharmacy pharmacy) async {
    final response = await _get('/inventory/pharmacy/${pharmacy.id}');
    final data = ApiResponse.list(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao buscar produtos da farmácia',
    );
    return data
        .whereType<Map<String, dynamic>>()
        .map((item) => InventoryItem.fromJson(item, pharmacyFallback: pharmacy))
        .toList(growable: false);
  }
}
