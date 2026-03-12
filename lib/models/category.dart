import 'package:SaveMed/models/subcategory.dart';

class Category {
  final int id;
  final String name;
  final String? description;
  final List<Subcategory> subcategories;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.subcategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['ID'],
      name: json['NAME'],
      description: json['DESCRIPTION'],
      subcategories: (json['subcategories'] as List? ?? [])
          .map((e) => Subcategory.fromJson(e))
          .toList(),
    );
  }

  /// ✅ Categoria vazia (fallback seguro)
  factory Category.empty() {
    return Category(
      id: -1,
      name: '',
      description: null,
      subcategories: const [],
    );
  }
}
