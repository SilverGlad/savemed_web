import 'package:savemed/core/utils/number_parser.dart';

class CustomerOrder {
  final int id;
  final String status;
  final String paymentStatus;
  final double totalAmount;
  final DateTime? createdAt;
  final String pharmacyName;
  final String? customerName;
  final String deliveryMethod;
  final String deliveryLabel;
  final List<CustomerOrderItem> items;
  final String fulfillmentStage;
  final DateTime? paidAt;
  final bool unresolvedPaymentAttempt;
  final bool deliveryIssue;

  const CustomerOrder({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.createdAt,
    required this.pharmacyName,
    this.customerName,
    this.deliveryMethod = '',
    this.deliveryLabel = '',
    required this.items,
    this.fulfillmentStage = 'new',
    this.paidAt,
    this.unresolvedPaymentAttempt = false,
    this.deliveryIssue = false,
  });

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['ID']);
    if (id == null) {
      throw const FormatException('Pedido sem identificador válido.');
    }
    final pharmacy = json['pharmacy'] ?? json['Pharmacy'];
    final customer = json['customer'] ?? json['Customer'];
    final rawCustomerName = customer is Map
        ? (customer['NAME'] ?? customer['name'])?.toString().trim()
        : null;
    final rawItems = json['items'] ?? json['OrderItems'];
    final fulfillment = json['FULFILLMENT'];
    final courier = fulfillment is Map ? fulfillment['pedmoto'] : null;
    return CustomerOrder(
      id: id,
      status: (json['STATUS'] ?? 'pending').toString(),
      paymentStatus: (json['PAYMENT_STATUS'] ?? 'pending').toString(),
      totalAmount: _asDouble(json['TOTAL_AMOUNT']) ?? 0,
      createdAt: DateTime.tryParse(json['CREATED_AT']?.toString() ?? ''),
      paidAt: DateTime.tryParse(json['PAID_AT']?.toString() ?? ''),
      deliveryIssue:
          courier is Map &&
          ['CANCELLED', 'RIDE_FAILED'].contains(courier['status']),
      unresolvedPaymentAttempt:
          (json['PAYMENT_TRANSACTION_ID']?.toString() ?? '').startsWith(
            'attempt_',
          ),
      pharmacyName: pharmacy is Map
          ? (pharmacy['NAME'] ?? 'Farmácia').toString()
          : 'Farmácia',
      customerName: rawCustomerName == null || rawCustomerName.isEmpty
          ? null
          : rawCustomerName,
      deliveryMethod: (json['DELIVERY_METHOD'] ?? '').toString(),
      deliveryLabel: (json['DELIVERY_LABEL'] ?? '').toString(),
      fulfillmentStage: json['FULFILLMENT'] is Map
          ? (json['FULFILLMENT']['stage'] ?? 'new').toString()
          : 'new',
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) => CustomerOrderItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const [],
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

class CustomerOrderItem {
  final String productName;
  final int quantity;
  final double totalPrice;

  const CustomerOrderItem({
    required this.productName,
    required this.quantity,
    required this.totalPrice,
  });

  factory CustomerOrderItem.fromJson(Map<String, dynamic> json) {
    final inventory = json['inventory'];
    final medication = inventory is Map ? inventory['medication'] : null;
    return CustomerOrderItem(
      productName: medication is Map
          ? (medication['NAME'] ?? 'Produto').toString()
          : 'Produto',
      quantity: CustomerOrder._asInt(json['QUANTITY']) ?? 0,
      totalPrice: CustomerOrder._asDouble(json['TOTAL_PRICE']) ?? 0,
    );
  }
}
