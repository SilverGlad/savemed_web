import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/models/active_ingredient.dart';

class Medication {
  final int id;
  final int? pharmacyId;
  final String name;
  final String description;
  final String? brand;
  final String? unit;
  final String? eanCode;
  final String? image;
  final int categoryId;
  final int? subcategoryId;
  final bool requiresPrescription;
  final List<ActiveIngredient> activeIngredients;

  const Medication({
    required this.id,
    this.pharmacyId,
    required this.name,
    required this.description,
    this.brand,
    this.unit,
    this.eanCode,
    this.image,
    required this.categoryId,
    this.subcategoryId,
    required this.requiresPrescription,
    this.activeIngredients = const [],
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    final name = (json['NAME'] ?? json['name'] ?? '').toString().trim();
    final id = _asInt(json['ID'] ?? json['id']);
    final categoryId = _asInt(json['CATEGORY_ID'] ?? json['categoryId']);

    if (id == null || categoryId == null || name.isEmpty) {
      throw const FormatException('Produto com dados obrigatórios inválidos.');
    }

    final rawIngredients =
        json['activeIngredients'] ?? json['ActiveIngredients'];
    return Medication(
      id: id,
      pharmacyId: _asInt(json['PHARMACY_ID'] ?? json['pharmacyId']),
      name: name,
      description: (json['DESCRIPTION'] ?? json['description'] ?? '')
          .toString(),
      brand: _optionalText(json['BRAND'] ?? json['brand']),
      unit: _optionalText(json['UNIT'] ?? json['unit']),
      eanCode: _optionalText(json['EAN_CODE'] ?? json['eanCode']),
      image: _resolveImage(
        json['IMAGE_URL'] ?? json['imageUrl'] ?? json['IMAGE'] ?? json['image'],
        id,
      ),
      categoryId: categoryId,
      subcategoryId: _asInt(json['SUBCATEGORY_ID'] ?? json['subcategoryId']),
      requiresPrescription:
          json['REQUIRES_RX'] == true ||
          json['REQUIRES_PRESCRIPTION'] == true ||
          json['requiresPrescription'] == true,
      activeIngredients: rawIngredients is List
          ? rawIngredients
                .whereType<Map<String, dynamic>>()
                .map(ActiveIngredient.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  static String? _resolveImage(Object? imageValue, int medicationId) {
    final raw = imageValue?.toString().trim();
    if (raw == null || raw.isEmpty) return null;

    if (imageValue is Map || imageValue is List) {
      return _imageEndpoint(medicationId);
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      if (raw.contains('bravelight.com.br/savemed/images/')) {
        return _imageEndpoint(medicationId);
      }
      return raw;
    }

    return _imageEndpoint(medicationId);
  }

  static String _imageEndpoint(int medicationId) =>
      '${ApiClient.baseUrl}/medications/$medicationId/image';

  static int? _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _optionalText(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
