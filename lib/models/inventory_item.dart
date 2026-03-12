import 'package:SaveMed/models/medication.dart';
import 'package:SaveMed/models/pharmacy.dart';

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
    return InventoryItem(
      id: json['ID'],
      price: double.parse(json['PRICE'].toString()),
      originalPrice: json['ORIGINAL_PRICE'] != null
          ? double.parse(json['ORIGINAL_PRICE'].toString())
          : double.parse(json['PRICE'].toString()),
      stock: json['STOCK'],
      pharmacy: Pharmacy.fromJson(json['Pharmacy']),
      medication: Medication.fromJson(json['Medication']),
    );
  }
}
