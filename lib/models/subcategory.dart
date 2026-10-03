class Subcategory {
  final int id;
  final int categoryId;
  final String name;

  const Subcategory({
    required this.id,
    required this.categoryId,
    required this.name,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id:
          _asInt(json['ID']) ??
          (throw const FormatException('Subcategoria inválida.')),
      categoryId: _asInt(json['CATEGORY_ID']) ?? 0,
      name: json['NAME']?.toString() ?? '',
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
