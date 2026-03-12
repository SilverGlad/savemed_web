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
  late TabController _tabController;

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

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario nao autenticado')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: Column(
        children: [
          SaveMedHeader(),
          Expanded(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.black54,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Meus dados'),
                      Tab(text: 'Enderecos'),
                      Tab(text: 'Pedidos'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      _ProfileForm(),
                      _AddressSection(),
                      _OrdersSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SaveMedFooter(),
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
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;

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
    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 600;
    final user = context.read<AuthController>().user!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _readonly('Email', user['EMAIL']),
              _readonly('CPF', user['CPF'] ?? '-'),
              _input('Nome', nameCtrl),
              _input('Telefone', phoneCtrl),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: SaveMedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dados atualizados')),
                    );
                  },
                  label: 'Salvar alteracoes',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readonly(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8F9FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
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
    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 600;

    if (ctrl.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Adicionar novo endereco'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _openAddressModal(context, address: null);
              },
            ),
          ),
          const SizedBox(height: 16),
          if (ctrl.addresses.isEmpty) const Text('Nenhum endereco cadastrado'),
          ...ctrl.addresses.map((addr) => _addressCard(context, addr, userId)),
        ],
      ),
    );
  }

  Widget _addressCard(BuildContext context, Map addr, int userId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text('${addr['STREET']}, ${addr['NUMBER'] ?? ''}'),
        subtitle: Text('${addr['CITY']} - ${addr['STATE']} • ${addr['CEP']}'),
        trailing: Wrap(
          spacing: 4,
          children: [
            if (addr['IS_DEFAULT'] == true)
              const Icon(Icons.check_circle, color: Colors.green),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _openAddressModal(context, address: addr);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await context.read<AddressController>().remove(
                  addr['ID'],
                  userId,
                );
              },
            ),
          ],
        ),
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
    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 600;

    if (ctrl.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ctrl.orders.isEmpty) {
      return const Center(child: Text('Voce ainda nao possui pedidos'));
    }

    return ListView.separated(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      itemCount: ctrl.orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final order = ctrl.orders[index] as Map<String, dynamic>;
        return _orderCard(order);
      },
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final orderStatus = (order['STATUS'] ?? 'pending').toString();
    final paymentStatus = (order['PAYMENT_STATUS'] ?? 'pending').toString();
    final total = order['TOTAL_AMOUNT'];
    final createdAt = DateTime.parse(order['CREATED_AT']);
    final pharmacyName = order['pharmacy']?['NAME'] ?? 'Farmacia';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          'Pedido #${order['ID']}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '$pharmacyName • Total: R\$ $total • ${_formatDate(createdAt)}',
        ),
        trailing: _statusSummary(orderStatus, paymentStatus),
        children: [const Divider(), ..._orderItems(order)],
      ),
    );
  }

  List<Widget> _orderItems(Map<String, dynamic> order) {
    final items = order['items'] as List? ?? [];

    if (items.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(16),
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

      return ListTile(
        title: Text(medName),
        subtitle: Text('Quantidade: $qty'),
        trailing: Text('R\$ $total'),
      );
    }).toList();
  }

  Widget _statusSummary(String orderStatus, String paymentStatus) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _orderStatusChip(orderStatus),
        const SizedBox(height: 4),
        Text(
          _paymentLabel(paymentStatus),
          style: TextStyle(
            fontSize: 12,
            color: _paymentColor(paymentStatus),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _orderStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'confirmed':
        color = Colors.green;
        label = 'Confirmado';
        break;
      case 'canceled':
        color = Colors.red;
        label = 'Cancelado';
        break;
      default:
        color = Colors.orange;
        label = 'Pendente';
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color),
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
        return Colors.green;
      case 'failed':
        return Colors.red;
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
