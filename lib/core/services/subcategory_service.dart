import 'dart:convert';

import '../../models/subcategory.dart';
import '../api/api_client.dart';

class SubcategoryService {
  Future<List<Subcategory>> getByCategory(int categoryId) async {
    final response = await ApiClient.get(
      '/subcategories',
      query: {'category_id': '$categoryId'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar subcategorias');
    }

    final data = jsonDecode(response.body) as List;

    return data.map((e) => Subcategory.fromJson(e)).toList();
  }
}
