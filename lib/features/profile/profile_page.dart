import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:SaveMed/core/controllers/address_controller.dart';
import 'package:SaveMed/core/controllers/auth_controller.dart';
import 'package:SaveMed/core/controllers/order_controller.dart';
import 'package:SaveMed/core/theme/app_colors.dart';
import 'package:SaveMed/core/widgets/address_modal.dart';
import 'package:SaveMed/core/widgets/savemed_button.dart';
import 'package:SaveMed/core/widgets/savemed_footer.dart';
import 'package:SaveMed/core/widgets/savemed_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    final isMobile = MediaQuery.of(context).size.width <= 760;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario nao autenticado')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              const SaveMedHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 12 : 24,
                    0,
                    isMobile ? 12 : 24,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileHero(user: user),
                      const SizedBox(height: 18),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: TabBar(
                                controller: _tabController,
                                isScrollable: isMobile,
                                indicator: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                dividerColor: Colors.transparent,
                                labelColor: Colors.white,
                                unselectedLabelColor: AppColors.textLight,
                                tabs: const [
                                  Tab(text: 'Meus dados'),
                                  Tab(text: 'Enderecos'),
                                  Tab(text: 'Pedidos'),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                isMobile ? 10 : 14,
                                4,
                                isMobile ? 10 : 14,
                                isMobile ? 10 : 14,
                              ),
                              child: SizedBox(
                                height: isMobile ? 820 : 760,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: const [
                                    _ProfileForm(),
                                    _AddressSection(),
                                    _OrdersSection(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      const SaveMedFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final Map<String, dynamic> user;

  const _ProfileHero({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = user['NAME'].toString().split(' ').first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF16342E), Color(0xFF168469)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Minha conta',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Ola, $firstName',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aqui voce acompanha seus dados, gerencia enderecos e ve todos os pedidos com mais clareza.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.84),
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeroStat(label: 'Email', value: user['EMAIL'] ?? '-'),
              _HeroStat(label: 'Perfil', value: user['USER_ROLE'] ?? '-'),
              _HeroStat(label: 'Telefone', value: user['PHONE_NUMBER'] ?? '-'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm();

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  late final TextEditingController nameCtrl;
  late final TextEditingController phoneCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().user!;
    nameCtrl = TextEditingController(text: user['NAME']);
    phoneCtrl = TextEditingController(text: user['PHONE_NUMBER'] ?? '');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthController>().user!;
    final isMobile = MediaQuery.of(context).size.width <= 760;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading(
            title: 'Dados pessoais',
            subtitle: 'Visualize e edite as principais informacoes da sua conta.',
          ),
          const SizedBox(height: 18),
          if (isMobile) ...[
            _InfoCard(
              child: Column(
                children: [
                  _readonly('Email', user['EMAIL']),
                  _readonly('CPF', user['CPF'] ?? '-'),
                  _input('Nome', nameCtrl),
                  _input('Telefone', phoneCtrl),
                ],
              ),
            ),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoCard(
                    child: Column(
                      children: [
                        _readonly('Email', user['EMAIL']),
                        _readonly('CPF', user['CPF'] ?? '-'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InfoCard(
                    child: Column(
                      children: [
                        _input('Nome', nameCtrl),
                        _input('Telefone', phoneCtrl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          SaveMedButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: const Text('Dados atualizados'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
            },
            label: 'Salvar alteracoes',
          ),
        ],
      ),
    );
  }

  Widget _readonly(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          TextField(controller: ctrl),
        ],
      ),
    );
  }
}

class _AddressSection extends StatefulWidget {
  const _AddressSection();

  @override
  State<_AddressSection> createState() => _AddressSectionState();
}

class _AddressSectionState extends State<_AddressSection> {
  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthController>().user!['ID'];
    context.read<AddressController>().load(userId);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AddressController>();
    final userId = context.read<AuthController>().user!['ID'];
    final isMobile = MediaQuery.of(context).size.width <= 760;

    if (ctrl.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            title: 'Enderecos',
            subtitle: ctrl.addresses.isEmpty
                ? 'Cadastre um endereco para facilitar suas proximas compras.'
                : 'Todos os seus enderecos cadastrados aparecem abaixo.',
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _openAddressModal(context, address: null),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Adicionar endereco'),
            ),
          ),
          const SizedBox(height: 16),
          if (ctrl.addresses.isEmpty)
            const _EmptyPanel(message: 'Nenhum endereco cadastrado ainda.')
          else
            Column(
              children: ctrl.addresses
                  .map((address) => _addressCard(context, address, userId))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _addressCard(BuildContext context, Map address, int userId) {
    final isDefault = address['IS_DEFAULT'] == true;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDefault ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDefault ? AppColors.surfaceMuted : AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isDefault ? Icons.check_circle : Icons.location_on_outlined,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${address['STREET']}, ${address['NUMBER'] ?? 's/n'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${address['NEIGHBORHOOD'] ?? ''} ${address['CITY']} - ${address['STATE']}',
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CEP ${address['CEP']}',
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Principal',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => _openAddressModal(context, address: address),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              FilledButton.icon(
                onPressed: () async {
                  await context.read<AddressController>().remove(
                    address['ID'],
                    userId,
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Excluir'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openAddressModal(BuildContext context, {Map? address}) {
    showDialog(
      context: context,
      builder: (_) => AddressModal(address: address),
    );
  }
}

class _OrdersSection extends StatefulWidget {
  const _OrdersSection();

  @override
  State<_OrdersSection> createState() => _OrdersSectionState();
}

class _OrdersSectionState extends State<_OrdersSection> {
  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthController>().user!['ID'];
    context.read<OrderController>().load(userId);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<OrderController>();
    final isMobile = MediaQuery.of(context).size.width <= 760;

    if (ctrl.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            title: 'Pedidos',
            subtitle: ctrl.orders.isEmpty
                ? 'Quando voce finalizar uma compra, ela aparece aqui.'
                : 'Veja status, farmacia, total e os itens de cada pedido.',
          ),
          const SizedBox(height: 16),
          if (ctrl.orders.isEmpty)
            const _EmptyPanel(message: 'Voce ainda nao possui pedidos.')
          else
            Column(
              children: ctrl.orders
                  .map((order) => _orderCard(order as Map<String, dynamic>))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final orderStatus = (order['STATUS'] ?? 'pending').toString();
    final paymentStatus = (order['PAYMENT_STATUS'] ?? 'pending').toString();
    final total = order['TOTAL_AMOUNT'];
    final createdAt = DateTime.parse(order['CREATED_AT']);
    final pharmacyName = order['pharmacy']?['NAME'] ?? 'Farmacia';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          'Pedido #${order['ID']}',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pharmacyName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: R\$ $total • ${_formatDate(createdAt)}',
                style: const TextStyle(color: AppColors.textLight),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _orderStatusChip(orderStatus),
                  _paymentChip(paymentStatus),
                ],
              ),
            ],
          ),
        ),
        children: [
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          ..._orderItems(order),
        ],
      ),
    );
  }

  List<Widget> _orderItems(Map<String, dynamic> order) {
    final items = order['items'] as List? ?? [];

    if (items.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(12),
          child: Text('Nenhum item encontrado'),
        ),
      ];
    }

    return items.map<Widget>((item) {
      final orderItem = item as Map<String, dynamic>;
      final medName =
          orderItem['inventory']?['medication']?['NAME'] ?? 'Produto';
      final qty = orderItem['QUANTITY'];
      final total = orderItem['TOTAL_PRICE'];

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.medication_outlined,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantidade: $qty',
                    style: const TextStyle(color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            Text(
              'R\$ $total',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _orderStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'confirmed':
        color = AppColors.success;
        label = 'Confirmado';
        break;
      case 'canceled':
        color = AppColors.danger;
        label = 'Cancelado';
        break;
      default:
        color = Colors.orange;
        label = 'Pendente';
    }

    return _StatusChip(label: label, color: color);
  }

  Widget _paymentChip(String status) {
    return _StatusChip(
      label: _paymentLabel(status),
      color: _paymentColor(status),
    );
  }

  String _paymentLabel(String status) {
    switch (status) {
      case 'paid':
        return 'Pagamento aprovado';
      case 'failed':
        return 'Pagamento falhou';
      case 'refunded':
        return 'Pagamento estornado';
      default:
        return 'Pagamento pendente';
    }
  }

  Color _paymentColor(String status) {
    switch (status) {
      case 'paid':
        return AppColors.success;
      case 'failed':
        return AppColors.danger;
      case 'refunded':
        return Colors.blueGrey;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textLight,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String message;

  const _EmptyPanel({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 44, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
