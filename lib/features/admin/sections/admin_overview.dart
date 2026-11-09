part of '../admin_page.dart';

class _OverviewPage extends StatelessWidget {
  final int? pharmacyId;
  final bool isAppAdmin;
  final AdminService service;

  const _OverviewPage({
    required this.pharmacyId,
    required this.isAppAdmin,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return _AdminPageFrame(
      title: isAppAdmin ? 'Operação da plataforma' : 'Operação da farmácia',
      subtitle: isAppAdmin
          ? 'Resumo da operação SaveMed.'
          : 'Resumo operacional da sua farmácia.',
      actions: const [],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _ResponsiveMetricGrid(
            children: [
              if (isAppAdmin)
                _MetricFuture(
                  label: 'Farmácias',
                  icon: Icons.storefront_outlined,
                  future: service.listPharmacies(),
                  valueBuilder: (items) => items.length.toString(),
                ),
              _MetricFuture(
                label: 'Categorias',
                icon: Icons.category_outlined,
                future: service.listCategories(pharmacyId: pharmacyId),
                valueBuilder: (items) => items.length.toString(),
              ),
              _MetricFuture(
                label: 'Produtos',
                icon: Icons.medication_outlined,
                future: service.listMedications(pharmacyId: pharmacyId),
                valueBuilder: (items) => items.length.toString(),
              ),
              _MetricFuture(
                label: 'Estoque',
                icon: Icons.inventory_2_outlined,
                future: service.listInventory(pharmacyId: pharmacyId),
                valueBuilder: (items) => items.length.toString(),
              ),
              _MetricFuture(
                label: 'Estoque baixo',
                icon: Icons.warning_amber_outlined,
                future: service.listInventory(pharmacyId: pharmacyId),
                danger: true,
                valueBuilder: (items) {
                  final count = items.where((item) => item.stock <= 5).length;
                  return count.toString();
                },
              ),
              _MetricFuture(
                label: 'Pedidos',
                icon: Icons.receipt_long_outlined,
                future: service.listOrders(pharmacyId: pharmacyId),
                valueBuilder: (items) => items.length.toString(),
              ),
              _MetricFuture(
                label: 'Pedidos ativos',
                icon: Icons.pending_actions_outlined,
                future: service.listOrders(pharmacyId: pharmacyId),
                valueBuilder: (items) {
                  final count = items.where(isActiveOrder).length;
                  return count.toString();
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          _FinancialSummarySection(service: service, pharmacyId: pharmacyId),
          const SizedBox(height: 18),
          _InfoPanel(
            icon: Icons.security_outlined,
            title: isAppAdmin ? 'Escopo de plataforma' : 'Escopo da farmácia',
            body: isAppAdmin
                ? 'Você está visualizando dados de toda a operação SaveMed.'
                : 'Você está visualizando apenas dados vinculados à sua farmácia.',
          ),
        ],
      ),
    );
  }
}

class _FinancialSummarySection extends StatefulWidget {
  final AdminService service;
  final int? pharmacyId;
  const _FinancialSummarySection({required this.service, this.pharmacyId});

  @override
  State<_FinancialSummarySection> createState() =>
      _FinancialSummarySectionState();
}

class _FinancialSummarySectionState extends State<_FinancialSummarySection> {
  late Future<FinancialSummary> _summary;

  @override
  void initState() {
    super.initState();
    _summary = widget.service.getFinancialSummary(
      pharmacyId: widget.pharmacyId,
    );
  }

  @override
  void didUpdateWidget(covariant _FinancialSummarySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service ||
        oldWidget.pharmacyId != widget.pharmacyId) {
      _summary = widget.service.getFinancialSummary(
        pharmacyId: widget.pharmacyId,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          tooltip: 'Atualizar financeiro',
          icon: const Icon(Icons.refresh),
          onPressed: () {
            final nextSummary = widget.service.getFinancialSummary(
              pharmacyId: widget.pharmacyId,
            );
            setState(() {
              _summary = nextSummary;
            });
          },
        ),
      ),
      FutureBuilder<FinancialSummary>(
        future: _summary,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _FinancialSummaryLoading();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _InfoPanel(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Resumo financeiro indisponível',
              body:
                  'Não foi possível carregar os valores agora. Tente atualizar o painel.',
            );
          }
          return _FinancialSummaryPanel(summary: snapshot.data!);
        },
      ),
    ],
  );
}

class _FinancialSummaryPanel extends StatelessWidget {
  final FinancialSummary summary;

  const _FinancialSummaryPanel({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Financeiro',
                  style: TextStyle(
                    color: _AdminColors.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${summary.orders} pedidos',
                style: const TextStyle(
                  color: _AdminColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Pagamento aprovado não significa dinheiro já repassado à farmácia.',
            style: TextStyle(color: _AdminColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  constraints.maxWidth < 440 ||
                      MediaQuery.textScalerOf(context).scale(1) > 1.4
                  ? 1
                  : constraints.maxWidth >= 850
                  ? 4
                  : 2;
              final gap = 10.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              final metrics = [
                _FinancialMetric(
                  label: 'Pagamentos aprovados',
                  value: formatBrl(summary.paidAmount),
                  detail: '${summary.paidOrders} pedidos',
                  icon: Icons.check_circle_outline,
                  color: AppColors.primary,
                ),
                _FinancialMetric(
                  label: 'Pendente',
                  value: formatBrl(summary.pendingAmount),
                  detail: '${summary.pendingOrders} pedidos',
                  icon: Icons.schedule_outlined,
                  color: const Color(0xFFB36B00),
                ),
                _FinancialMetric(
                  label: 'Estornado',
                  value: formatBrl(summary.refundedAmount),
                  detail: '${summary.refundedOrders} pedidos',
                  icon: Icons.undo_outlined,
                  color: const Color(0xFF7C4D9E),
                ),
                _FinancialMetric(
                  label: 'Falhou',
                  value: formatBrl(summary.failedAmount),
                  detail: '${summary.failedOrders} pedidos',
                  icon: Icons.error_outline,
                  color: AppColors.danger,
                ),
              ];
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: metrics
                    .map((metric) => SizedBox(width: width, child: metric))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          if (summary.paidProductsAmount != null)
            Text('Produtos pagos: ${formatBrl(summary.paidProductsAmount!)}'),
          if (summary.paidShippingAmount != null)
            Text(
              'Frete pago pelos clientes: ${formatBrl(summary.paidShippingAmount!)}',
            ),
          const SizedBox(height: 12),
          const Text(
            'Repasses às farmácias',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            summary.payoutsConfigured
                ? 'Consulte a conciliação dos repasses no provedor.'
                : 'Comissão SaveMed: 20% sobre os produtos, sem incluir o frete. A SaveMed absorve a taxa de pagamento na sua comissão. Prazo por farmácia: 15 ou 30 dias após a confirmação da entrega ou retirada. Transferências ainda não configuradas; os pagamentos exibidos não representam saldo disponível para repasse.',
          ),
        ],
      ),
    );
  }
}

class _FinancialMetric extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;

  const _FinancialMetric({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: _AdminColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            detail,
            style: const TextStyle(color: _AdminColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _FinancialSummaryLoading extends StatelessWidget {
  const _FinancialSummaryLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: _panelDecoration(),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ResponsiveMetricGrid extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveMetricGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1180
            ? 4
            : width >= 760
            ? 3
            : width >= 520
            ? 2
            : 1;
        final gap = 12.0;
        final itemWidth = (width - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}

class _MetricFuture<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final Future<List<T>> future;
  final String Function(List<T>) valueBuilder;
  final bool danger;

  const _MetricFuture({
    required this.label,
    required this.icon,
    required this.future,
    required this.valueBuilder,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState != ConnectionState.done;
        final failed = snapshot.hasError;
        final value = failed
            ? '--'
            : loading
            ? '...'
            : valueBuilder(snapshot.data ?? const []);
        final color = failed
            ? AppColors.danger
            : danger && value != '0'
            ? AppColors.danger
            : AppColors.primary;

        return Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(14),
          decoration: _panelDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 19),
                  const Spacer(),
                  if (failed)
                    const Tooltip(
                      message: 'Falha ao carregar este indicador',
                      child: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.danger,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _AdminColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
