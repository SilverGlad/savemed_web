import 'package:flutter/material.dart';
import 'package:savemed/core/api/api_error_message.dart';
import 'package:savemed/core/services/admin_service.dart';
import 'package:savemed/core/utils/money_formatter.dart';
import 'package:savemed/core/domain/order_status.dart';
import 'package:savemed/models/order_fulfillment.dart';
import 'delivery_confirmation_dialog.dart';
import 'pedmoto_panel.dart';

class OrderOperationsPage extends StatefulWidget {
  final int orderId;
  final AdminService service;
  const OrderOperationsPage({
    super.key,
    required this.orderId,
    required this.service,
  });

  @override
  State<OrderOperationsPage> createState() => _OrderOperationsPageState();
}

class _OrderOperationsPageState extends State<OrderOperationsPage> {
  OrderFulfillment? _order;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final order = await widget.service.orderFulfillment(widget.orderId);
      if (mounted) setState(() => _order = order);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = ApiErrorMessage.forUser(
            error,
            fallback: 'Não foi possível carregar o pedido.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _act(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    if (_busy || _order == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final order = await widget.service.actOnOrder(
        widget.orderId,
        _order!.version,
        action,
        values,
      );
      if (mounted) setState(() => _order = order);
    } catch (error) {
      if (!mounted) return;
      final message = ApiErrorMessage.forUser(
        error,
        fallback: 'Não foi possível atualizar o pedido.',
      );
      // Reload authoritative state even when an external delivery result was uncertain.
      try {
        final order = await widget.service.orderFulfillment(widget.orderId);
        if (mounted) setState(() => _order = order);
      } catch (_) {
        /* Keep details visible until the operator can reconnect. */
      }
      if (mounted) setState(() => _error = message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDelivery() async {
    final result = await showDialog<OrderFulfillment>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          DeliveryConfirmationDialog(order: _order!, service: widget.service),
    );
    if (mounted) {
      if (result != null) {
        setState(() => _order = result);
      } else {
        await _load();
      }
    }
  }

  Future<void> _ownDelivery() async {
    final form = GlobalKey<FormState>();
    var name = '';
    var phone = '';
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entrega própria'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    onChanged: (value) => name = value,
                    maxLength: 100,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nome do entregador',
                    ),
                    validator: (value) => (value?.trim().length ?? 0) < 2
                        ? 'Informe o nome.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    onChanged: (value) => phone = value,
                    keyboardType: TextInputType.phone,
                    maxLength: 20,
                    decoration: const InputDecoration(
                      labelText: 'Telefone com DDD',
                    ),
                    validator: (value) =>
                        !RegExp(
                          r'^\d{10,11}$',
                        ).hasMatch((value ?? '').replaceAll(RegExp(r'\D'), ''))
                        ? 'Informe um telefone válido com DDD.'
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(context, {
                  'driverName': name.trim(),
                  'driverPhone': phone,
                });
              }
            },
            child: const Text('Confirmar saída'),
          ),
        ],
      ),
    );
    if (result != null && mounted) await _act('dispatch_own', result);
  }

  Widget _button(String label, IconData icon, VoidCallback action) =>
      FilledButton.icon(
        onPressed: _busy ? null : action,
        icon: Icon(icon, size: 18),
        label: Text(label),
      );

  Widget _section(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );

  Widget _actions(OrderFulfillment order) {
    if (!order.canOperate) {
      return const Text(
        'O preparo e a entrega são liberados após a confirmação do pagamento. Pedidos cancelados não podem ser atendidos.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (order.stage == 'new')
              _button(
                'Aceitar e preparar',
                Icons.task_alt,
                () => _act('accept'),
              ),
            if (order.stage == 'preparing')
              _button(
                'Marcar como pronto',
                Icons.inventory_2_outlined,
                () => _act('ready'),
              ),
            if (order.stage == 'ready' && order.pickup)
              _button(
                'Confirmar retirada',
                Icons.storefront_outlined,
                _confirmDelivery,
              ),
            if (order.stage == 'ready' && !order.pickup) ...[
              _button(
                'Entrega própria',
                Icons.local_shipping_outlined,
                _ownDelivery,
              ),
            ],
            if (order.stage == 'on_way' &&
                ['own', 'pedmoto'].contains(order.mode))
              _button(
                'Confirmar entrega',
                Icons.check_circle_outline,
                _confirmDelivery,
              ),
            if (order.stage == 'on_way' && order.mode == 'own')
              OutlinedButton.icon(
                onPressed: _busy ? null : _returnDelivery,
                icon: const Icon(Icons.assignment_return_outlined),
                label: const Text('Interromper entrega'),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _returnDelivery() async {
    final form = GlobalKey<FormState>();
    var reason = '';
    var returned = false;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Interromper entrega'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'O pedido voltará para pronto. Isso não cancela a compra nem estorna o pagamento.',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      minLines: 2,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'Motivo do retorno',
                      ),
                      onChanged: (value) => reason = value,
                      validator: (value) => (value?.trim().length ?? 0) < 10
                          ? 'Informe pelo menos 10 caracteres.'
                          : null,
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: returned,
                      title: const Text('Os produtos retornaram à farmácia'),
                      onChanged: (value) =>
                          update(() => returned = value ?? false),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: !returned
                  ? null
                  : () {
                      if (form.currentState!.validate()) {
                        Navigator.pop(context, reason.trim());
                      }
                    },
              child: const Text('Confirmar retorno'),
            ),
          ],
        ),
      ),
    );
    if (result != null && mounted) {
      await _act('return_to_pharmacy', {'returned': true, 'reason': result});
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Pedido #${widget.orderId}'),
      actions: [
        IconButton(
          tooltip: 'Atualizar pedido',
          onPressed: _busy ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: Column(
      children: [
        SizedBox(
          height: 3,
          child: _busy ? const LinearProgressIndicator() : null,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null)
                      Semantics(
                        liveRegion: true,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    if (_order == null && !_busy)
                      OutlinedButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    if (_order case final order?) ...[
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Text(
                            fulfillmentStageLabel(order.stage),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Pagamento: ${orderStatusLabel(order.paymentStatus)}',
                          ),
                          Text('Total: ${formatBrl(order.total)}'),
                          if (order.inventoryLabel != null)
                            Text('Estoque: ${order.inventoryLabel}'),
                        ],
                      ),
                      if (!order.canOperate ||
                          [
                            'new',
                            'preparing',
                            'ready',
                            'on_way',
                          ].contains(order.stage))
                        _section('Atendimento', [_actions(order)]),
                      if (order.canOperate &&
                          !order.pickup &&
                          (order.stage == 'ready' || order.mode == 'pedmoto'))
                        _section('PedMoto', [
                          PedMotoPanel(
                            order: order,
                            busy: _busy,
                            onAction: _act,
                          ),
                        ]),
                      const Divider(height: 1),
                      _section('Produtos', [
                        for (final item in order.items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item['quantity']} × ${item['name']}',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  formatBrl((item['total'] as num).toDouble()),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          'Frete pago pelo cliente: ${formatBrl(order.shippingPrice)}',
                        ),
                      ]),
                      const Divider(height: 1),
                      _section('Cliente', [
                        SelectableText(order.customerName),
                        if (order.customerPhone.isNotEmpty)
                          SelectableText(order.customerPhone),
                      ]),
                      _section(
                        order.pickup
                            ? 'Retirada na farmácia'
                            : 'Endereço de entrega',
                        [
                          SelectableText(
                            order.pickup
                                ? order.origin
                                : order.destination.isEmpty
                                ? 'Endereço não informado'
                                : order.destination,
                          ),
                        ],
                      ),
                      if (!order.pickup)
                        _section('Origem da entrega', [
                          SelectableText(
                            order.origin.isEmpty
                                ? 'Endereço não informado'
                                : order.origin,
                          ),
                        ]),
                      if (order.delivery['driverName'] != null)
                        _section('Entregador', [
                          SelectableText(
                            '${order.delivery['driverName']} · ${order.delivery['driverPhone']}',
                          ),
                        ]),
                      if (order.history.isNotEmpty) ...[
                        const Divider(height: 1),
                        _section('Histórico', [
                          for (final event in order.history.reversed)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                '${_eventLabel(event['action'])} · ${_date(event['at'])}${event['reason'] == null ? '' : '\n${event['reason']}'}',
                              ),
                            ),
                        ]),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

String _date(Object? value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (date == null) return '';
  String pad(int n) => n.toString().padLeft(2, '0');
  return '${pad(date.day)}/${pad(date.month)} ${pad(date.hour)}:${pad(date.minute)}';
}

String _eventLabel(Object? value) =>
    const {
      'accept': 'Pedido aceito',
      'ready': 'Pedido pronto',
      'dispatch_own': 'Saiu para entrega',
      'delivered': 'Entrega confirmada',
      'picked_up': 'Retirado pelo cliente',
      'return_to_pharmacy': 'Produtos devolvidos à farmácia',
      'quote_pedmoto': 'Cotação PedMoto atualizada',
      'dispatch_pedmoto': 'Solicitação PedMoto iniciada',
      'pedmoto_requested': 'Corrida PedMoto vinculada',
      'pedmoto_uncertain': 'Solicitação PedMoto exige conferência',
      'refresh_pedmoto': 'Status PedMoto consultado',
      'pedmoto_collected': 'Produtos coletados pela PedMoto',
    }[value] ??
    'Pedido atualizado';
