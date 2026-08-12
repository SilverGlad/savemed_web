import 'package:savemed/models/medication.dart';
import 'package:savemed/models/pharmacy.dart';

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
  bool get available => stock > 0;

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['ID']);
    final price = _asDouble(json['PRICE']);
    final stock = _asInt(json['STOCK']);
    final pharmacy = json['Pharmacy'];
    final medication = json['Medication'];

    if (id == null ||
        price == null ||
        stock == null ||
        pharmacy is! Map<String, dynamic> ||
        medication is! Map<String, dynamic>) {
      throw const FormatException('Item de estoque com dados invalidos.');
    }

    return InventoryItem(
      id: id,
      price: price,
      originalPrice: _asDouble(json['ORIGINAL_PRICE']) ?? price,
      stock: stock,
      pharmacy: Pharmacy.fromJson(pharmacy),
      medication: Medication.fromJson(medication),
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
