part of '../admin_page.dart';

class _OrdersPage extends _AdminListPage {
  const _OrdersPage({required super.pharmacyId});

  @override
  State<_OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends _AdminListPageState<_OrdersPage> {
  @override
  String get title => 'Pedidos';

  @override
  String get subtitle => 'Acompanhamento de status, pagamento e operacao.';

  @override
  bool get canCreate => false;

  @override
  Future<List<dynamic>> fetch() =>
      service.listOrders(pharmacyId: widget.pharmacyId);

  @override
  bool matches(Map<String, dynamic> item, String query) =>
      textMatch(item, query);

  @override
  List<DataColumn> get columns => const [
    DataColumn(label: Text('Pedido')),
    DataColumn(label: Text('Farmacia')),
    DataColumn(label: Text('Status')),
    DataColumn(label: Text('Pagamento')),
    DataColumn(label: Text('Total')),
    DataColumn(label: Text('Acoes')),
  ];

  @override
  DataRow buildRow(Map<String, dynamic> item) {
    final pharmacy = item['pharmacy'] as Map<String, dynamic>?;
    final canRefund =
        PaymentStatus.fromApi(item['PAYMENT_STATUS']) == PaymentStatus.paid;
    return DataRow(
      cells: [
        DataCell(
          _PrimaryCell(
            title: '#${item['ID']}',
            subtitle: _str(item['DELIVERY_METHOD']),
          ),
        ),
        DataCell(Text(_str(pharmacy?['NAME'], fallback: 'Farmacia'))),
        DataCell(_StatusChip(label: _str(item['STATUS']))),
        DataCell(_StatusChip(label: _str(item['PAYMENT_STATUS']))),
        DataCell(Text('R\$ ${_str(item['TOTAL_AMOUNT'], fallback: '0')}')),
        DataCell(
          _RowActions(
            onEdit: () => _showDialog(item),
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
  Widget buildMobileItem(Map<String, dynamic> item) {
    final pharmacy = item['pharmacy'] as Map<String, dynamic>?;
    final canRefund =
        PaymentStatus.fromApi(item['PAYMENT_STATUS']) == PaymentStatus.paid;
    return _CompactTile(
      title: 'Pedido #${item['ID']}',
      subtitle:
          '${_str(pharmacy?['NAME'], fallback: 'Farmacia')} - R\$ ${_str(item['TOTAL_AMOUNT'], fallback: '0')}',
      chips: [
        _StatusChip(label: _str(item['STATUS'])),
        _StatusChip(label: _str(item['PAYMENT_STATUS'])),
      ],
      onEdit: () => _showDialog(item),
      extra: canRefund
          ? TextButton(
              onPressed: () => _confirmRefund(item),
              child: const Text('Estornar'),
            )
          : null,
    );
  }

  @override
  Future<void> onCreate() async {}

  Future<void> _showDialog(Map<String, dynamic> item) async {
    var status = OrderStatus.fromApi(item['STATUS']);
    var paymentStatus = PaymentStatus.fromApi(item['PAYMENT_STATUS']);
    final allowedOrderStatuses = OrderStatusRules.allowedOrderTransitions(
      status,
    ).map((value) => value.apiValue).toList();
    final allowedPaymentStatuses = OrderStatusRules.allowedPaymentTransitions(
      paymentStatus,
    ).map((value) => value.apiValue).toList();
    await _showAdminDialog(
      context: context,
      title: 'Editar pedido #${item['ID']}',
      child: _FormGrid(
        children: [
          _stringDropdown(
            label: 'Status do pedido',
            value: status.apiValue,
            values: allowedOrderStatuses,
            onChanged: (value) => status = OrderStatus.fromApi(value),
          ),
          _stringDropdown(
            label: 'Status do pagamento',
            value: paymentStatus.apiValue,
            values: allowedPaymentStatuses,
            onChanged: (value) => paymentStatus = PaymentStatus.fromApi(value),
          ),
        ],
      ),
      onSave: () => handle(() async {
        if (!allowedOrderStatuses.contains(status.apiValue) ||
            !allowedPaymentStatuses.contains(paymentStatus.apiValue)) {
          throw Exception('Selecione status validos para o pedido.');
        }
        await service.updateOrder(item['ID'], {
          'STATUS': status.apiValue,
          'PAYMENT_STATUS': paymentStatus.apiValue,
        });
      }),
    );
  }

  Future<void> _confirmRefund(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Estornar pedido #${item['ID']}'),
        content: const Text(
          'O pagamento sera estornado e o pedido sera cancelado. Esta acao nao pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Confirmar estorno'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await handle(() => service.refundOrder(item['ID']));
    }
  }
}
