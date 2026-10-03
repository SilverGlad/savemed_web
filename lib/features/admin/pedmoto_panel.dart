import 'package:flutter/material.dart';
import 'package:savemed/core/utils/money_formatter.dart';
import 'package:savemed/models/order_fulfillment.dart';

class PedMotoPanel extends StatelessWidget {
  final OrderFulfillment order;
  final bool busy;
  final Future<void> Function(String, Map<String, dynamic>) onAction;

  const PedMotoPanel({
    super.key,
    required this.order,
    required this.busy,
    required this.onAction,
  });

  Future<void> _confirm(
    BuildContext context, {
    required bool collection,
  }) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(collection ? 'Confirmar coleta' : 'Solicitar PedMoto'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Text(
              collection
                  ? 'Os produtos foram entregues ao motoboy? O cliente receberá o código para confirmar a entrega no destino.'
                  : 'Valor estimado da corrida: ${formatBrl(order.pedMotoPrice)}. '
                        'Pagamento da corrida: dinheiro, conforme o acordo com a PedMoto. '
                        'Esse valor não será cobrado novamente do cliente pelo SaveMed. '
                        'Confirme somente se o responsável pelo pagamento já estiver definido.',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              collection ? 'Produtos coletados' : 'Confirmar solicitação',
            ),
          ),
        ],
      ),
    );
    if (approved == true) {
      await onAction(
        collection ? 'pedmoto_collected' : 'dispatch_pedmoto',
        collection
            ? {'collected': true}
            : {'quoteId': order.pedMotoQuote['id'], 'acceptCost': true},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final courier = order.pedMoto;
    final uncertain = [
      'pedmoto_pending',
      'pedmoto_uncertain',
    ].contains(order.stage);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (order.stage == 'ready' && !order.pedMotoAvailable)
          const Text(
            'PedMoto ainda não habilitada. Entrega própria disponível.',
          ),
        if (order.stage == 'ready' && order.pedMotoAvailable) ...[
          if (order.pedMotoQuote.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Corrida estimada: ${formatBrl(order.pedMotoPrice)} · Pagamento em dinheiro',
              ),
            ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: busy ? null : () => onAction('quote_pedmoto', {}),
                icon: const Icon(Icons.calculate_outlined),
                label: Text(
                  order.pedMotoQuote.isEmpty
                      ? 'Cotar PedMoto'
                      : 'Atualizar cotação',
                ),
              ),
              if (order.pedMotoQuote.isNotEmpty)
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () => _confirm(context, collection: false),
                  icon: const Icon(Icons.two_wheeler),
                  label: const Text('Solicitar motoboy'),
                ),
            ],
          ),
        ],
        if (uncertain)
          Semantics(
            liveRegion: true,
            child: const Text(
              'Solicitação sem confirmação. Não solicite outra corrida. Confira a referência abaixo com a PedMoto antes de alterar a entrega ou estornar o pedido.',
            ),
          ),
        if (courier['reference'] != null) ...[
          const SizedBox(height: 12),
          SelectableText('Referência SaveMed: ${courier['reference']}'),
        ],
        if (courier['providerId'] != null) ...[
          const SizedBox(height: 12),
          SelectableText('Corrida: ${courier['providerId']}'),
          Text('Status PedMoto: ${pedMotoStatusLabel(courier['status'])}'),
          Text('Valor estimado: ${formatBrl(order.pedMotoPrice)}'),
          if (courier['reportedPrice'] case final num price)
            Text(
              'Valor informado pela PedMoto: ${formatBrl(price.toDouble())}',
            ),
          if (courier['driver'] case final Map driver) ...[
            const SizedBox(height: 12),
            SelectableText('Motoboy: ${driver['name'] ?? ''}'),
            SelectableText('${driver['phone'] ?? ''}'),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: busy ? null : () => onAction('refresh_pedmoto', {}),
                icon: const Icon(Icons.refresh),
                label: const Text('Consultar PedMoto'),
              ),
              if (order.stage == 'pedmoto_requested' &&
                  !['CANCELLED', 'RIDE_FAILED'].contains(courier['status']))
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () => _confirm(context, collection: true),
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Confirmar coleta'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Cancelamentos e ocorrências devem ser tratados com a PedMoto. A entrega no SaveMed só é concluída com o código do cliente.',
          ),
        ],
      ],
    );
  }
}

String pedMotoStatusLabel(Object? value) =>
    const {
      'PENDING_ACCEPTANCE': 'Aguardando motoboy',
      'ACCEPTED': 'Aceita pelo motoboy',
      'DRIVER_ON_WAY': 'Motoboy a caminho da farmácia',
      'DRIVER_ARRIVED_ORIGIN': 'Motoboy na farmácia',
      'IN_TRANSIT': 'A caminho do cliente',
      'NEAR_DESTINATION': 'Próximo ao cliente',
      'ARRIVED_AT_DESTINATION': 'No endereço do cliente',
      'COMPLETED': 'Concluída no parceiro',
      'CANCELLED': 'Cancelada no parceiro; conferir com suporte',
      'RIDE_FAILED': 'Falha na corrida; conferir com suporte',
    }[value] ??
    'Situação não reconhecida; consulte a PedMoto';
