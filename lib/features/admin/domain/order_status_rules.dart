import 'package:savemed/core/domain/order_status.dart';

abstract final class OrderStatusRules {
  static List<OrderStatus> allowedOrderTransitions(OrderStatus current) {
    return switch (current) {
      OrderStatus.pending => const [
        OrderStatus.pending,
        OrderStatus.confirmed,
        OrderStatus.canceled,
      ],
      OrderStatus.confirmed => const [
        OrderStatus.confirmed,
        OrderStatus.canceled,
      ],
      OrderStatus.canceled => const [OrderStatus.canceled],
      OrderStatus.unknown => const [OrderStatus.unknown],
    };
  }

  static List<PaymentStatus> allowedPaymentTransitions(PaymentStatus current) {
    return switch (current) {
      PaymentStatus.pending => const [
        PaymentStatus.pending,
        PaymentStatus.paid,
        PaymentStatus.failed,
      ],
      PaymentStatus.failed => const [
        PaymentStatus.failed,
        PaymentStatus.pending,
        PaymentStatus.paid,
      ],
      PaymentStatus.paid => const [PaymentStatus.paid],
      PaymentStatus.refunded => const [PaymentStatus.refunded],
      PaymentStatus.unknown => const [PaymentStatus.unknown],
    };
  }

  static String label(String value) {
    return orderStatusLabel(value);
  }
}
