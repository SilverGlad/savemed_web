import '../../models/category.dart';
import '../api/api_client.dart';
import '../api/api_response.dart';

class CategoryService {
  Future<List<Category>> getCategories() async {
    final response = await ApiClient.get('/categories');
    final data = ApiResponse.list(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao buscar categorias',
    );
    return data
        .whereType<Map<String, dynamic>>()
        .map(Category.fromJson)
        .toList();
  }
}
