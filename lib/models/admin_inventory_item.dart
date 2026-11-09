import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/core/utils/number_parser.dart';

class AdminInventoryItem {
  final int id;
  final int pharmacyId;
  final int medicationId;
  final double price;
  final double originalPrice;
  final int stock;
  final String medicationName;
  final String? image;
  final String? unit;
  final DateTime? updatedAt;

  const AdminInventoryItem({
    required this.id,
    required this.pharmacyId,
    required this.medicationId,
    required this.price,
    required this.originalPrice,
    required this.stock,
    required this.medicationName,
    this.image,
    this.unit,
    this.updatedAt,
  });

  factory AdminInventoryItem.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['ID'] ?? json['id']);
    final pharmacyId = _asInt(json['PHARMACY_ID'] ?? json['pharmacyId']);
    final medicationId = _asInt(json['MEDICATION_ID'] ?? json['medicationId']);
    final price = _asDouble(json['PRICE'] ?? json['price']);
    final stock = _asInt(json['STOCK'] ?? json['stock']);
    if (id == null ||
        pharmacyId == null ||
        medicationId == null ||
        price == null ||
        stock == null) {
      throw const FormatException('Item de estoque com dados inválidos.');
    }

    final medication = json['Medication'] ?? json['medication'];
    return AdminInventoryItem(
      id: id,
      pharmacyId: pharmacyId,
      medicationId: medicationId,
      price: price,
      originalPrice:
          _asDouble(json['ORIGINAL_PRICE'] ?? json['originalPrice']) ?? price,
      stock: stock,
      medicationName: medication is Map
          ? (medication['NAME'] ?? medication['name'] ?? 'Produto').toString()
          : 'Produto',
      image:
          medication is Map &&
              (medication['IMAGE'] ?? medication['image']) != null
          ? '${ApiClient.baseUrl}/medications/$medicationId/image'
          : null,
      unit: medication is Map
          ? _optionalText(medication['UNIT'] ?? medication['unit'])
          : null,
      updatedAt: DateTime.tryParse(
        (json['UPDATED_AT'] ??
                    json['updatedAt'] ??
                    json['CREATED_AT'] ??
                    json['createdAt'])
                ?.toString() ??
            '',
      ),
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _asDouble(Object? value) {
    return parseFiniteNumber(value);
  }

  static String? _optionalText(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
