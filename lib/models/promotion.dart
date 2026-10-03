import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/core/utils/number_parser.dart';

class Promotion {
  final int id;
  final int pharmacyId;
  final int medicationId;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final String productName;
  final String pharmacyName;
  final bool hasImage;
  final String? image;

  const Promotion({
    required this.id,
    required this.pharmacyId,
    required this.medicationId,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    required this.productName,
    required this.pharmacyName,
    required this.hasImage,
    this.image,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['ID'] ?? json['id']);
    final pharmacyId = _asInt(json['PHARMACY_ID'] ?? json['pharmacyId']);
    final medicationId = _asInt(json['MEDICATION_ID'] ?? json['medicationId']);
    final discount = _asDouble(
      json['DISCOUNT_PERCENTAGE'] ?? json['discountPercentage'],
    );
    final start = DateTime.tryParse(
      (json['START_DATE'] ?? json['startDate'])?.toString() ?? '',
    );
    final end = DateTime.tryParse(
      (json['END_DATE'] ?? json['endDate'])?.toString() ?? '',
    );
    if (id == null ||
        pharmacyId == null ||
        medicationId == null ||
        discount == null ||
        start == null ||
        end == null) {
      throw const FormatException('Promoção com dados inválidos.');
    }

    final medication = json['Medication'] ?? json['medication'];
    final pharmacy = json['Pharmacy'] ?? json['pharmacy'];
    final image = json['HIGHLIGHT_IMAGE'] ?? json['highlightImage'];
    return Promotion(
      id: id,
      pharmacyId: pharmacyId,
      medicationId: medicationId,
      discountPercentage: discount,
      startDate: start,
      endDate: end,
      productName: medication is Map
          ? (medication['NAME'] ?? medication['name'] ?? 'Produto').toString()
          : 'Produto #$medicationId',
      pharmacyName: pharmacy is Map
          ? (pharmacy['NAME'] ?? pharmacy['name'] ?? 'Farmácia').toString()
          : 'Farmácia #$pharmacyId',
      hasImage: image != null && image.toString().isNotEmpty,
      image: image is Map || image is List
          ? '${ApiClient.baseUrl}/highlights/$id/image'
          : (image?.toString().startsWith('http') == true
                ? image.toString()
                : null),
    );
  }

  bool get isScheduled => DateTime.now().isBefore(startDate);

  bool get isEnded =>
      DateTime.now().isAfter(endDate.add(const Duration(days: 1)));

  static int? _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _asDouble(Object? value) {
    return parseFiniteNumber(value);
  }
}
