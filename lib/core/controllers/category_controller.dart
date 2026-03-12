import 'package:flutter/foundation.dart' hide Category;
import 'package:SaveMed/models/subcategory.dart';

import '../../models/category.dart';
import '../services/category_service.dart';

class CategoryController extends ChangeNotifier {
  final CategoryService categoryService;

  CategoryController({required this.categoryService});

  List<Category> categories = [];
  bool loading = false;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    categories = await categoryService.getCategories();

    loading = false;
    notifyListeners();
  }

  List<Subcategory> subcategoriesOf(int categoryId) {
    final cat = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => Category.empty(),
    );

    return cat.subcategories;
  }
}
