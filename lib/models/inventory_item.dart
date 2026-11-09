import 'package:savemed/models/medication.dart';
import 'package:savemed/models/pharmacy.dart';
import 'package:savemed/core/utils/number_parser.dart';

class InventoryItem {
  final int id;
  final double price;
  final double originalPrice;
  final int stock;
  final Pharmacy pharmacy;
  final Medication medication;

  InventoryItem({
    required this.id,
    required this.price,
    required this.originalPrice,
    required this.stock,
    required this.pharmacy,
    required this.medication,
  });

  // ===============================
  // 🔥 GETTERS CALCULADOS
  // ===============================

  /// Percentual de desconto (ex: 30)
  int get discount {
    if (originalPrice <= price || originalPrice == 0) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }

  /// Produto disponível em estoque
  bool get available => stock > 0 && pharmacy.isActive && pharmacy.isOpen;

  String get unavailableLabel =>
      !pharmacy.isOpen || !pharmacy.isActive ? 'Loja fechada' : 'Esgotado';

  factory InventoryItem.fromJson(
    Map<String, dynamic> json, {
    Pharmacy? pharmacyFallback,
  }) {
    final id = _asInt(json['ID']);
    final price = _asDouble(json['PRICE']);
    final stock = _asInt(json['STOCK']);
    final rawPharmacy = json['Pharmacy'];
    final pharmacy = rawPharmacy is Map<String, dynamic>
        ? Pharmacy.fromJson(rawPharmacy)
        : pharmacyFallback;
    final medication = json['Medication'];

    if (id == null ||
        price == null ||
        stock == null ||
        pharmacy == null ||
        medication is! Map<String, dynamic>) {
      throw const FormatException('Item de estoque com dados inválidos.');
    }

    return InventoryItem(
      id: id,
      price: price,
      originalPrice: _asDouble(json['ORIGINAL_PRICE']) ?? price,
      stock: stock,
      pharmacy: pharmacy,
      medication: Medication.fromJson(medication),
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _asDouble(Object? value) {
    return parseFiniteNumber(value);
  }
}
