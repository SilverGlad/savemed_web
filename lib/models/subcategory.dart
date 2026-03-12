class Subcategory {
  final int id;
  final int categoryId;
  final String name;

  Subcategory({required this.id, required this.categoryId, required this.name});

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['ID'],
      categoryId: json['CATEGORY_ID'],
      name: json['NAME'],
    );
  }
}
