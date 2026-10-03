import 'dart:async';
import 'package:flutter/material.dart';
import 'package:savemed/core/api/api_error_message.dart';
import 'package:savemed/core/domain/order_status.dart';
import 'package:savemed/core/services/admin_service.dart';
import 'package:savemed/core/utils/money_formatter.dart';
import 'package:savemed/models/customer_order.dart';
import 'package:savemed/models/order_fulfillment.dart';
import 'domain/order_queue.dart';
import 'order_operations_page.dart';
import 'pharmacy_operation_panel.dart';

class OrderQueuePage extends StatefulWidget {
  final AdminService service;
  final int? pharmacyId;
  final Future<void> Function()? onHistory;
  final DateTime Function()? now;
  const OrderQueuePage({
    super.key,
    required this.service,
    this.pharmacyId,
    this.onHistory,
    this.now,
  });

  @override
  State<OrderQueuePage> createState() => _OrderQueuePageState();
}

class _OrderQueuePageState extends State<OrderQueuePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabs;
  final _search = TextEditingController();
  Timer? _timer;
  List<CustomerOrder> _orders = [];
  bool _loading = false;
  bool _automatic = true;
  bool _foreground = true;
  bool _opening = false;
  bool _loaded = false;
  String? _error;
  DateTime? _updated;
  int _newCount = 0;
  int _generation = 0;
  DateTime get _now => widget.now?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabs = TabController(length: OrderQueue.values.length, vsync: this)
      ..addListener(_refresh);
    _search.addListener(_refresh);
    _load();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_automatic &&
          _foreground &&
          !_opening &&
          (ModalRoute.of(context)?.isCurrent ?? true)) {
        _load();
      }
    });
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant OrderQueuePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pharmacyId != widget.pharmacyId ||
        oldWidget.service != widget.service) {
      _generation++;
      _orders = [];
      _loaded = false;
      _loading = false;
      _updated = null;
      _newCount = 0;
      _error = null;
      _load();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground && _automatic && !_opening) _load();
  }

  Future<void> _load() async {
    if (_loading || !mounted) return;
    final generation = _generation;
    setState(() => _loading = true);
    try {
      final orders = await widget.service.listOrders(
        pharmacyId: widget.pharmacyId,
      );
      if (!mounted || generation != _generation) return;
      final previous = _orders
          .where((o) => queueForOrder(o, _now) == OrderQueue.newOrders)
          .map((o) => o.id)
          .toSet();
      setState(() {
        _newCount = _loaded
            ? orders
                  .where(
                    (o) =>
                        queueForOrder(o, _now) == OrderQueue.newOrders &&
                        !previous.contains(o.id),
                  )
                  .length
            : 0;
        _orders = orders;
        _updated = _now;
        _loaded = true;
        _error = null;
      });
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(
          () => _error = ApiErrorMessage.forUser(
            error,
            fallback: 'Não foi possível atualizar os pedidos.',
          ),
        );
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _open(CustomerOrder order) async {
    if (_opening) return;
    _opening = true;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            OrderOperationsPage(orderId: order.id, service: widget.service),
      ),
    );
    _opening = false;
    if (mounted) await _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = _now;
    final selected = OrderQueue.values[_tabs.index];
    final query = _search.text.trim().toLowerCase();
    final counts = {for (final queue in OrderQueue.values) queue: 0};
    for (final order in _orders) {
      counts[queueForOrder(order, now)] =
          counts[queueForOrder(order, now)]! + 1;
    }
    final visible = _orders
        .where(
          (order) =>
              queueForOrder(order, now) == selected &&
              (query.isEmpty ||
                  '#${order.id} ${order.pharmacyName} ${order.items.map((i) => i.productName).join(' ')}'
                      .toLowerCase()
                      .contains(query)),
        )
        .toList();
    visible.sort((a, b) {
      final comparison = (a.createdAt ?? DateTime(1970)).compareTo(
        b.createdAt ?? DateTime(1970),
      );
      return [OrderQueue.completed, OrderQueue.canceled].contains(selected)
          ? -comparison
          : comparison;
    });
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              const Text(
                'Central de pedidos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              Wrap(
                spacing: 8,
                children: [
                  if (widget.onHistory != null)
                    TextButton.icon(
                      onPressed: widget.onHistory,
                      icon: const Icon(Icons.history),
                      label: const Text('Histórico e estornos'),
                    ),
                  IconButton(
                    tooltip: 'Atualizar pedidos',
                    onPressed: _loading ? null : _load,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.pharmacyId != null)
            ExpansionTile(
              title: const Text('Operação da loja'),
              leading: const Icon(Icons.storefront_outlined),
              children: [
                PharmacyOperationPanel(
                  key: ValueKey(widget.pharmacyId),
                  pharmacyId: widget.pharmacyId!,
                  service: widget.service,
                ),
              ],
            ),
          TextField(
            controller: _search,
            decoration: const InputDecoration(
              labelText: 'Buscar pedido, produto ou farmácia',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: _automatic,
                    onChanged: (value) {
                      setState(() => _automatic = value);
                      if (value) _load();
                    },
                  ),
                  const Flexible(child: Text('Atualização automática')),
                ],
              ),
              if (_updated != null)
                Text(
                  'Atualizado às ${_time(_updated!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          if (_newCount > 0)
            Semantics(
              liveRegion: true,
              child: Text(
                '$_newCount novos pedidos recebidos',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          if (_error != null)
            Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '$_error${_loaded ? ' Exibindo a última atualização.' : ''}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final queue in OrderQueue.values)
                Tab(text: '${queue.label} (${counts[queue]})'),
            ],
          ),
          SizedBox(
            height: 3,
            child: _loading ? const LinearProgressIndicator() : null,
          ),
          Expanded(
            child: !_loaded && _loading
                ? const Center(child: CircularProgressIndicator())
                : visible.isEmpty
                ? Center(
                    child: Text(
                      query.isEmpty
                          ? 'Nenhum pedido nesta etapa.'
                          : 'Nenhum pedido encontrado.',
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _OrderQueueTile(
                      order: visible[index],
                      now: now,
                      onOpen: () => _open(visible[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

String _time(DateTime value) =>
    '${value.toLocal().hour.toString().padLeft(2, '0')}:${value.toLocal().minute.toString().padLeft(2, '0')}';

class _OrderQueueTile extends StatelessWidget {
  final CustomerOrder order;
  final DateTime now;
  final VoidCallback onOpen;
  const _OrderQueueTile({
    required this.order,
    required this.now,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final attention = orderAttention(order, now);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 20,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                'Pedido #${order.id}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                formatBrl(order.totalAmount),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(order.pharmacyName),
          Text(
            '${order.items.fold<int>(0, (n, item) => n + item.quantity)} itens · ${orderStatusLabel(order.paymentStatus)}',
          ),
          Text(fulfillmentStageLabel(order.fulfillmentStage)),
          if (order.createdAt != null)
            Text(
              'Recebido em ${order.createdAt!.day.toString().padLeft(2, '0')}/${order.createdAt!.month.toString().padLeft(2, '0')} às ${_time(order.createdAt!)}',
            ),
          if (attention != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                attention,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Abrir pedido'),
            ),
          ),
        ],
      ),
    );
  }
}
