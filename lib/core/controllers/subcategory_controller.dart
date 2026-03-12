import 'package:flutter/foundation.dart' hide Category;

import '../../models/category.dart';
import '../services/category_service.dart';

class CategoryController extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  List<Category> categories = [];
  bool loading = false;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    categories = await _service.getCategories();

    loading = false;
    notifyListeners();
  }
}
