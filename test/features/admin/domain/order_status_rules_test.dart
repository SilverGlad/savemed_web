import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/domain/order_status.dart';
import 'package:savemed/features/admin/domain/order_status_rules.dart';

void main() {
  group('OrderStatusRules', () {
    test('prevents terminal order transitions', () {
      expect(OrderStatusRules.allowedOrderTransitions(OrderStatus.canceled), [
        OrderStatus.canceled,
      ]);
      expect(OrderStatusRules.allowedOrderTransitions(OrderStatus.confirmed), [
        OrderStatus.confirmed,
        OrderStatus.canceled,
      ]);
    });

    test('requires the refund flow after a paid payment', () {
      expect(OrderStatusRules.allowedPaymentTransitions(PaymentStatus.paid), [
        PaymentStatus.paid,
      ]);
      expect(
        OrderStatusRules.allowedPaymentTransitions(PaymentStatus.refunded),
        [PaymentStatus.refunded],
      );
      expect(
        OrderStatusRules.canRefund(
          orderStatus: OrderStatus.confirmed,
          paymentStatus: PaymentStatus.paid,
        ),
        isTrue,
      );
      expect(
        OrderStatusRules.canRefund(
          orderStatus: OrderStatus.canceled,
          paymentStatus: PaymentStatus.paid,
        ),
        isFalse,
      );
      expect(
        OrderStatusRules.canRefund(
          orderStatus: OrderStatus.confirmed,
          paymentStatus: PaymentStatus.refunded,
        ),
        isFalse,
      );
    });

    test('allows pending payment outcomes', () {
      expect(
        OrderStatusRules.allowedPaymentTransitions(PaymentStatus.pending),
        [PaymentStatus.pending, PaymentStatus.paid, PaymentStatus.failed],
      );
    });

    test('provides user-facing labels', () {
      expect(OrderStatusRules.label('confirmed'), 'Confirmado');
      expect(OrderStatusRules.label('refunded'), 'Estornado');
    });
  });
}
