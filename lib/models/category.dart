import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/models/subcategory.dart';

class Category {
  final int id;
  final String name;
  final String? description;
  final int? pharmacyId;
  final String? image;
  final List<Subcategory> subcategories;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.pharmacyId,
    this.image,
    required this.subcategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final rawSubcategories =
        json['subcategories'] ?? json['Subcategories'] ?? const [];
    return Category(
      id:
          _asInt(json['ID']) ??
          (throw const FormatException('Categoria inválida.')),
      name: json['NAME']?.toString() ?? '',
      description: json['DESCRIPTION']?.toString(),
      pharmacyId: _asInt(json['PHARMACY_ID']),
      image: _resolveImage(json['IMAGE'] ?? json['image'], json['ID']),
      subcategories: (rawSubcategories as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(Subcategory.fromJson)
          .toList(),
    );
  }

  static String? _resolveImage(Object? value, Object? idValue) {
    final id = int.tryParse(idValue?.toString() ?? '');
    if (id == null || value == null) return null;
    if (value is Map || value is List) {
      return '${ApiClient.baseUrl}/categories/$id/image';
    }
    final raw = value.toString().trim();
    return raw.isEmpty ? null : raw;
  }

  /// ✅ Categoria vazia (fallback seguro)
  factory Category.empty() {
    return Category(
      id: -1,
      name: '',
      description: null,
      pharmacyId: null,
      subcategories: const [],
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
