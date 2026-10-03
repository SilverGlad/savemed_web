import 'package:savemed/models/customer_order.dart';

enum OrderQueue {
  newOrders('Novos'),
  preparing('Preparando'),
  ready('Prontos'),
  delivery('Em entrega'),
  issues('Ocorrências'),
  payment('Pagamento'),
  completed('Concluídos'),
  canceled('Cancelados');

  final String label;
  const OrderQueue(this.label);
}

OrderQueue queueForOrder(CustomerOrder order, DateTime now) {
  if (order.fulfillmentStage == 'refund_pending') return OrderQueue.issues;
  if (order.deliveryIssue ||
      (order.status == 'canceled' && order.paymentStatus == 'paid')) {
    return OrderQueue.issues;
  }
  if (order.status == 'canceled' || order.paymentStatus == 'refunded') {
    return OrderQueue.canceled;
  }
  if ([
    'pedmoto_pending',
    'pedmoto_uncertain',
  ].contains(order.fulfillmentStage)) {
    return OrderQueue.issues;
  }
  if (order.paymentStatus != 'paid') {
    if (order.unresolvedPaymentAttempt &&
        order.createdAt != null &&
        now.difference(order.createdAt!).inMinutes >= 10) {
      return OrderQueue.issues;
    }
    return OrderQueue.payment;
  }
  return switch (order.fulfillmentStage) {
    'new' => OrderQueue.newOrders,
    'preparing' => OrderQueue.preparing,
    'ready' || 'pedmoto_requested' => OrderQueue.ready,
    'on_way' => OrderQueue.delivery,
    'delivered' => OrderQueue.completed,
    'canceled' => OrderQueue.canceled,
    _ => OrderQueue.issues,
  };
}

bool isActiveOrder(CustomerOrder order) =>
    order.status != 'canceled' &&
    order.paymentStatus == 'paid' &&
    !['delivered', 'canceled'].contains(order.fulfillmentStage);

String? orderAttention(CustomerOrder order, DateTime now) {
  if (order.status == 'canceled' && order.paymentStatus == 'paid') {
    return 'Pedido cancelado com pagamento aprovado; conferir estorno';
  }
  if (order.deliveryIssue) {
    return 'Ocorrência na entrega; confira com a PedMoto';
  }
  if (order.fulfillmentStage == 'refund_pending') {
    return 'Estorno exige acompanhamento';
  }
  if ([
    'pedmoto_pending',
    'pedmoto_uncertain',
  ].contains(order.fulfillmentStage)) {
    return 'Confira a corrida antes de solicitar outra';
  }
  if (queueForOrder(order, now) == OrderQueue.issues &&
      order.unresolvedPaymentAttempt) {
    return 'Pagamento sem resposta; confira antes de cobrar novamente';
  }
  final start = order.paidAt ?? order.createdAt;
  if (queueForOrder(order, now) == OrderQueue.newOrders &&
      start != null &&
      now.difference(start).inMinutes >= 15) {
    return 'Mais de 15 min sem aceite';
  }
  return null;
}
