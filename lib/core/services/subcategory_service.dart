import '../../models/subcategory.dart';
import '../api/api_client.dart';
import '../api/api_response.dart';

class SubcategoryService {
  Future<List<Subcategory>> getByCategory(int categoryId) async {
    final response = await ApiClient.get(
      '/subcategories',
      query: {'category_id': '$categoryId'},
    );
    final data = ApiResponse.list(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao buscar subcategorias',
    );
    return data
        .whereType<Map<String, dynamic>>()
        .map(Subcategory.fromJson)
        .toList();
  }
}
