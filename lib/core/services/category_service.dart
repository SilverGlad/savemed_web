import 'dart:convert';

import '../../models/category.dart';
import '../api/api_client.dart';

class CategoryService {
  Future<List<Category>> getCategories() async {
    final response = await ApiClient.get(
      '/categories',
      query: {}, // 👈 obrigatório
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar categorias');
    }

    final data = jsonDecode(response.body) as List;

    return data.map((e) => Category.fromJson(e)).toList();
  }
}
