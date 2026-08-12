part of '../admin_page.dart';

class _OverviewPage extends StatelessWidget {
  final int? pharmacyId;
  final bool isAppAdmin;
  final AdminService service = AdminService();

  _OverviewPage({required this.pharmacyId, required this.isAppAdmin});

  @override
  Widget build(BuildContext context) {
    return _AdminPageFrame(
      title: isAppAdmin ? 'Operacao da plataforma' : 'Operacao da farmacia',
      subtitle: isAppAdmin
          ? 'Indicadores em tempo real do backoffice SaveMed.'
          : 'Resumo operacional da sua loja.',
      actions: const [],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _ResponsiveMetricGrid(
            children: [
              if (isAppAdmin)
                _MetricFuture(
                  label: 'Farmacias',
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
                  final count = items.where((item) {
                    final stock = int.tryParse(
                      (item as Map<String, dynamic>)['STOCK']?.toString() ?? '',
                    );
                    return (stock ?? 0) <= 5;
                  }).length;
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
                  final count = items.where((item) {
                    final status = (item as Map<String, dynamic>)['STATUS']
                        ?.toString()
                        .toLowerCase();
                    return status != 'completed' && status != 'cancelled';
                  }).length;
                  return count.toString();
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          _InfoPanel(
            icon: Icons.security_outlined,
            title: isAppAdmin ? 'Escopo de plataforma' : 'Escopo da farmacia',
            body: isAppAdmin
                ? 'Voce esta visualizando dados de toda a operacao SaveMed.'
                : 'Voce esta visualizando apenas dados vinculados a sua farmacia.',
          ),
        ],
      ),
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

class _MetricFuture extends StatelessWidget {
  final String label;
  final IconData icon;
  final Future<List<dynamic>> future;
  final String Function(List<dynamic>) valueBuilder;
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
    return FutureBuilder<List<dynamic>>(
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
          height: 112,
          padding: const EdgeInsets.all(14),
          decoration: _panelDecoration(),
          child: Column(
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
              const Spacer(),
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
