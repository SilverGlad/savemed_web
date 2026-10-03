import 'package:savemed/core/utils/number_parser.dart';

class FinancialSummary {
  final int orders;
  final double totalAmount;
  final int paidOrders;
  final double paidAmount;
  final int pendingOrders;
  final double pendingAmount;
  final int refundedOrders;
  final double refundedAmount;
  final int failedOrders;
  final double failedAmount;
  final int canceledOrders;
  final int? pharmacyId;
  final double? paidProductsAmount;
  final double? paidShippingAmount;
  final bool payoutsConfigured;

  const FinancialSummary({
    required this.orders,
    required this.totalAmount,
    required this.paidOrders,
    required this.paidAmount,
    required this.pendingOrders,
    required this.pendingAmount,
    required this.refundedOrders,
    required this.refundedAmount,
    required this.failedOrders,
    required this.failedAmount,
    required this.canceledOrders,
    required this.pharmacyId,
    this.paidProductsAmount,
    this.paidShippingAmount,
    this.payoutsConfigured = false,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    double number(String key) => parseFiniteNumber(json[key]) ?? 0;
    int integer(String key) => int.tryParse('${json[key] ?? 0}') ?? 0;

    return FinancialSummary(
      orders: integer('orders'),
      totalAmount: number('totalAmount'),
      paidOrders: integer('paidOrders'),
      paidAmount: number('paidAmount'),
      pendingOrders: integer('pendingOrders'),
      pendingAmount: number('pendingAmount'),
      refundedOrders: integer('refundedOrders'),
      refundedAmount: number('refundedAmount'),
      failedOrders: integer('failedOrders'),
      failedAmount: number('failedAmount'),
      canceledOrders: integer('canceledOrders'),
      pharmacyId: int.tryParse('${json['pharmacyId'] ?? ''}'),
      paidProductsAmount: parseFiniteNumber(json['paidProductsAmount']),
      paidShippingAmount: parseFiniteNumber(json['paidShippingAmount']),
      payoutsConfigured: json['payoutsConfigured'] == true,
    );
  }
}
