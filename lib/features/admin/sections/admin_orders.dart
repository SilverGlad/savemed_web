part of '../admin_page.dart';

class _OrdersPage extends _AdminListPage {
  const _OrdersPage({required super.pharmacyId, required super.service});

  @override
  State<_OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends _AdminListPageState<_OrdersPage, CustomerOrder> {
  @override
  String get title => 'Pedidos';

  @override
  String get subtitle => 'Acompanhamento de status, pagamento e operação.';

  @override
  bool get canCreate => false;

  @override
  Future<List<CustomerOrder>> fetch() =>
      service.listOrders(pharmacyId: widget.pharmacyId);

  @override
  bool matches(CustomerOrder item, String query) =>
      item.id.toString().contains(query) ||
      (item.customerName?.toLowerCase().contains(query) ?? false) ||
      item.pharmacyName.toLowerCase().contains(query) ||
      item.deliveryMethod.toLowerCase().contains(query) ||
      item.deliveryLabel.toLowerCase().contains(query) ||
      item.status.toLowerCase().contains(query) ||
      item.paymentStatus.toLowerCase().contains(query) ||
      fulfillmentStageLabel(
        item.fulfillmentStage,
      ).toLowerCase().contains(query);

  @override
  List<DataColumn> get columns => const [
    DataColumn(label: Text('Pedido')),
    DataColumn(label: Text('Cliente')),
    DataColumn(label: Text('Data/hora')),
    DataColumn(label: Text('Farmácia')),
    DataColumn(label: Text('Status')),
    DataColumn(label: Text('Pagamento')),
    DataColumn(label: Text('Total')),
    DataColumn(label: Text('Ações')),
  ];

  @override
  DataRow buildRow(CustomerOrder item) {
    final canRefund =
        !fulfillmentBlocksRefund(item.fulfillmentStage) &&
        OrderStatusRules.canRefund(
          orderStatus: OrderStatus.fromApi(item.status),
          paymentStatus: PaymentStatus.fromApi(item.paymentStatus),
        );
    return DataRow(
      cells: [
        DataCell(
          _PrimaryCell(title: '#${item.id}', subtitle: _deliveryMethod(item)),
        ),
        DataCell(Text(item.customerName ?? '—')),
        DataCell(Text(_createdAt(item))),
        DataCell(Text(item.pharmacyName)),
        DataCell(
          Text(
            item.status == 'canceled'
                ? 'Cancelado'
                : fulfillmentStageLabel(item.fulfillmentStage),
          ),
        ),
        DataCell(_StatusChip(label: item.paymentStatus)),
        DataCell(Text(formatBrl(item.totalAmount))),
        DataCell(
          _RowActions(
            onEdit: () => _openDetails(item),
            editLabel: 'Abrir pedido',
            editIcon: Icons.receipt_long_outlined,
            extra: canRefund
                ? TextButton(
                    onPressed: () => _confirmRefund(item),
                    child: const Text('Estornar'),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget buildMobileItem(CustomerOrder item) {
    final canRefund =
        !fulfillmentBlocksRefund(item.fulfillmentStage) &&
        OrderStatusRules.canRefund(
          orderStatus: OrderStatus.fromApi(item.status),
          paymentStatus: PaymentStatus.fromApi(item.paymentStatus),
        );
    return _CompactTile(
      title: 'Pedido #${item.id}',
      subtitle: '${item.customerName ?? 'Cliente'} · ${item.pharmacyName}',
      chips: [
        _StatusChip(label: item.status, prefix: 'Pedido'),
        _StatusChip(
          label: fulfillmentStageLabel(item.fulfillmentStage),
          prefix: 'Preparo/entrega',
        ),
        _StatusChip(label: item.paymentStatus, prefix: 'Pagamento'),
        _SmallChip(_deliveryMethod(item)),
        _SmallChip(_createdAt(item)),
        _SmallChip(formatBrl(item.totalAmount)),
      ],
      onEdit: () => _openDetails(item),
      editLabel: 'Abrir pedido',
      editIcon: Icons.receipt_long_outlined,
      extra: canRefund
          ? TextButton(
              onPressed: () => _confirmRefund(item),
              child: const Text('Estornar'),
            )
          : null,
    );
  }

  String _createdAt(CustomerOrder item) {
    final value = item.createdAt?.toLocal();
    if (value == null) return 'Data não informada';
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} às $hour:$minute';
  }

  String _deliveryMethod(CustomerOrder item) {
    final value = item.deliveryMethod.toLowerCase();
    if (value.contains('pickup') || value.contains('retirada')) {
      return 'Retirada';
    }
    if (value.contains('delivery') || value.contains('entrega')) {
      return 'Entrega';
    }
    return item.deliveryMethod.isEmpty
        ? 'Modalidade não informada'
        : item.deliveryMethod;
  }

  @override
  Future<void> onCreate() async {}

  Future<void> _openDetails(CustomerOrder item) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderOperationsPage(orderId: item.id, service: service),
      ),
    );
    if (mounted) await reload();
  }

  Future<void> _confirmRefund(CustomerOrder item) async {
    final formKey = GlobalKey<FormState>();
    var refundReason = '';
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Estornar pedido #${item.id}'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OrderDetailRow(label: 'Farmácia', value: item.pharmacyName),
                _OrderDetailRow(
                  label: 'Total',
                  value: formatBrl(item.totalAmount),
                ),
                _OrderDetailRow(
                  label: 'Pedido',
                  value: _statusLabel(item.status),
                ),
                _OrderDetailRow(
                  label: 'Pagamento',
                  value: _statusLabel(item.paymentStatus),
                ),
                _OrderDetailRow(
                  label: 'Entrega',
                  value: item.deliveryLabel.isEmpty
                      ? 'Não informada'
                      : item.deliveryLabel,
                ),
                const SizedBox(height: 14),
                const Text(
                  'O pagamento será estornado e o pedido será cancelado. Esta ação não pode ser desfeita.',
                  style: TextStyle(color: AppColors.danger, height: 1.4),
                ),
                const SizedBox(height: 16),
                Form(
                  key: formKey,
                  child: TextFormField(
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Justificativa do estorno',
                      hintText: 'Informe o motivo para o histórico da operação',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if ((value?.trim().length ?? 0) < 10) {
                        return 'Informe pelo menos 10 caracteres.';
                      }
                      return null;
                    },
                    onChanged: (value) => refundReason = value,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, refundReason.trim());
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Confirmar estorno'),
          ),
        ],
      ),
    );
    if (reason != null && mounted) {
      await handle(() => service.refundOrder(item.id, reason: reason));
    }
  }
}

class _OrderDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _OrderDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: _AdminColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _AdminColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
