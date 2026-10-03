import 'package:flutter/material.dart';
import 'package:savemed/models/customer_order.dart';

class OrderProgress extends StatelessWidget {
  final CustomerOrder order;
  const OrderProgress({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.status == 'canceled' || order.paymentStatus == 'refunded') {
      return Text(
        order.paymentStatus == 'refunded'
            ? 'Pagamento estornado.'
            : 'Pedido cancelado. Confira o pagamento com a farmácia.',
      );
    }
    if (order.paymentStatus != 'paid') {
      return Text(
        order.paymentStatus == 'failed'
            ? 'Pagamento não aprovado. O preparo ainda não foi iniciado.'
            : 'Aguardando confirmação do pagamento. O preparo começa após a aprovação.',
      );
    }
    if ([
          'refund_pending',
          'pedmoto_pending',
          'pedmoto_uncertain',
        ].contains(order.fulfillmentStage) ||
        order.deliveryIssue) {
      return const Text(
        'A farmácia está verificando uma ocorrência neste pedido.',
      );
    }
    final pickup = order.deliveryMethod == 'pickup';
    final labels = [
      'Pagamento aprovado',
      'Aceite da farmácia',
      'Em preparação',
      pickup ? 'Pronto para retirada' : 'Pronto para envio',
      if (!pickup) 'A caminho',
      pickup ? 'Retirado' : 'Entregue',
    ];
    final current = switch (order.fulfillmentStage) {
      'new' => 1,
      'preparing' => 2,
      'ready' || 'pedmoto_requested' => 3,
      'on_way' => 4,
      'delivered' => labels.length,
      _ => -1,
    };
    if (current < 0) return const Text('Aguardando atualização da farmácia.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < labels.length; index++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Semantics(
              label:
                  '${labels[index]}: ${index < current
                      ? 'concluído'
                      : index == current
                      ? 'etapa atual'
                      : 'aguardando'}',
              excludeSemantics: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    index < current
                        ? Icons.check_circle
                        : index == current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 22,
                    color: index <= current
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        fontWeight: index == current
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
