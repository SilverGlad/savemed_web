import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savemed/core/controllers/address_controller.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/controllers/order_controller.dart';
import 'package:savemed/core/services/support_contact_service.dart';
import 'package:savemed/core/theme/app_colors.dart';
import 'package:savemed/core/widgets/address_modal.dart';
import 'package:savemed/core/widgets/address_load_notice.dart';
import 'package:savemed/core/widgets/savemed_button.dart';
import 'package:savemed/core/widgets/savemed_header.dart';
import 'package:savemed/core/utils/money_formatter.dart';
import 'package:savemed/core/utils/document_formatter.dart';
import 'package:savemed/models/customer_order.dart';
import 'package:savemed/models/postal_address.dart';
import 'package:savemed/models/order_fulfillment.dart';
import 'delivery_code_panel.dart';
import 'order_progress.dart';
import 'package:savemed/core/api/api_error_message.dart';

class ProfilePage extends StatefulWidget {
  final int initialTab;
  final SupportContactService supportContactService;

  const ProfilePage({
    super.key,
    this.initialTab = 0,
    this.supportContactService = const SupportContactService(),
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _activeTab = widget.initialTab;
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    final activeTab = _tabController.index;
    if (activeTab == _activeTab) return;
    setState(() => _activeTab = activeTab);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
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
                      Tab(text: 'Endereços'),
                      Tab(text: 'Pedidos'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      const _ProfileForm(),
                      const _AddressSection(),
                      _OrdersSection(
                        active: _activeTab == 2,
                        supportContactService: widget.supportContactService,
                      ),
                    ],
                  ),
                ),
              ],
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
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    final phone = phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (nameCtrl.text.trim().length < 2 ||
        (phone.isNotEmpty && !RegExp(r'^\d{10,11}$').hasMatch(phone))) {
      setState(() => _error = 'Informe seu nome e um telefone com DDD válido.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await context.read<AuthController>().updateProfile(
        name: nameCtrl.text,
        phone: phone,
      );
      if (!mounted) return;
      if (!saved) {
        setState(
          () => _error =
              'A sessão foi encerrada antes de confirmar as alterações. Entre novamente.',
        );
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dados atualizados')));
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _error = ApiErrorMessage.forUser(
          error,
          fallback: 'Não foi possível salvar seus dados.',
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().user!;
    nameCtrl = TextEditingController(text: user.name);
    phoneCtrl = TextEditingController(text: user.phoneNumber ?? '');
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
              _readonly('Email', user.email),
              _readonly('CPF', formatCpfForDisplay(user.cpf)),
              _input('Nome', nameCtrl),
              _input('Telefone', phoneCtrl),
              if (_error != null)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: SaveMedButton(
                  loading: _saving,
                  onPressed: _save,
                  label: 'Salvar alterações',
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
            enabled: !_saving,
            keyboardType: label == 'Telefone'
                ? TextInputType.phone
                : TextInputType.name,
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
    final userId = context.read<AuthController>().user!.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AddressController>().reloadForUi(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AddressController>();
    final userId = context.read<AuthController>().user!.id;
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
              label: const Text('Adicionar novo endereço'),
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
          if (ctrl.error != null)
            AddressLoadNotice(onRetry: () => ctrl.reloadForUi(userId))
          else if (ctrl.addresses.isEmpty)
            const Text('Nenhum endereço cadastrado'),
          ...ctrl.addresses.map((addr) => _addressCard(context, addr, userId)),
        ],
      ),
    );
  }

  Widget _addressCard(BuildContext context, PostalAddress addr, int userId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text('${addr.street}, ${addr.number ?? ''}'),
        subtitle: Text('${addr.city} - ${addr.state} • ${addr.cep}'),
        trailing: Wrap(
          spacing: 4,
          children: [
            if (addr.isDefault)
              Semantics(
                label: 'Endereço padrão',
                child: const Icon(Icons.check_circle, color: Colors.green),
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar endereço',
              onPressed: () => _openAddressModal(context, address: addr),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Excluir endereço',
              onPressed: addr.id == null
                  ? null
                  : () => context.read<AddressController>().remove(
                      addr.id!,
                      userId,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddressModal(BuildContext context, {PostalAddress? address}) {
    showDialog(
      context: context,
      builder: (_) => AddressModal(address: address),
    );
  }
}

class _OrdersSection extends StatefulWidget {
  final bool active;
  final SupportContactService supportContactService;

  const _OrdersSection({
    required this.active,
    required this.supportContactService,
  });

  @override
  State<_OrdersSection> createState() => _OrdersSectionState();
}

class _OrdersSectionState extends State<_OrdersSection>
    with WidgetsBindingObserver {
  static const _refreshInterval = Duration(seconds: 30);

  Timer? _refreshTimer;
  bool _appResumed = true;
  int? _supportingOrderId;
  String? _error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.active) _reload();
    });
    _syncRefreshTimer();
  }

  @override
  void didUpdateWidget(covariant _OrdersSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      _syncRefreshTimer();
      if (widget.active) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.active) _reload();
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appResumed = state == AppLifecycleState.resumed;
    _syncRefreshTimer();
    if (_appResumed && widget.active) _reload(background: true);
  }

  void _syncRefreshTimer() {
    _refreshTimer?.cancel();
    if (!widget.active || !_appResumed) return;
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (mounted) _reload(background: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _reload({bool background = false}) async {
    final user = context.read<AuthController>().user;
    final controller = context.read<OrderController>();
    if (user == null || controller.loading) return;
    if (!background) setState(() => _error = null);
    try {
      await controller.load(user.id);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = ApiErrorMessage.forUser(
            error,
            fallback: 'Não foi possível atualizar seus pedidos.',
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<OrderController>();
    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 600;

    if (ctrl.loading && ctrl.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            tooltip: 'Atualizar meus pedidos',
            onPressed: ctrl.loading ? null : _reload,
            icon: const Icon(Icons.refresh),
          ),
        ),
        if (_error != null && ctrl.orders.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        if (ctrl.loading) const LinearProgressIndicator(),
        Expanded(
          child: ctrl.orders.isEmpty
              ? _error == null
                    ? const Center(child: Text('Você ainda não possui pedidos'))
                    : _ordersLoadError(ctrl.loading)
              : RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    itemCount: ctrl.orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      return _orderCard(ctrl.orders[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _ordersLoadError(bool loading) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: loading ? null : _reload,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderCard(CustomerOrder order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: Text(
          'Pedido #${order.id}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${order.pharmacyName} • Total: ${formatBrl(order.totalAmount)} • ${order.createdAt == null ? '-' : _formatDate(order.createdAt!)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _statusSummary(
              order.fulfillmentStage == 'delivered'
                  ? 'delivered'
                  : order.status,
              order.paymentStatus,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OrderProgress(order: order),
          ),
          if (order.paymentStatus == 'paid' &&
              order.status != 'canceled' &&
              (order.fulfillmentStage == 'on_way' ||
                  (order.fulfillmentStage == 'ready' &&
                      order.deliveryMethod == 'pickup')))
            DeliveryCodePanel(
              key: ValueKey('delivery-code-${order.id}'),
              orderId: order.id,
            ),
          if (order.fulfillmentStage != 'new')
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(fulfillmentStageLabel(order.fulfillmentStage)),
            ),
          const Divider(),
          ..._orderItems(order),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _supportingOrderId == null
                    ? () => _contactSupport(order)
                    : null,
                icon: const Icon(Icons.chat_outlined),
                label: Text(
                  _supportingOrderId == order.id
                      ? 'Abrindo WhatsApp...'
                      : 'Falar com suporte da SaveMed',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _contactSupport(CustomerOrder order) async {
    setState(() => _supportingOrderId = order.id);
    var opened = false;
    try {
      opened = await widget.supportContactService.contactOrder(order.id);
    } catch (_) {
      opened = false;
    }
    if (!mounted) return;
    setState(() => _supportingOrderId = null);
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível abrir o WhatsApp. Contate o suporte pelo telefone (19) 99170-7830.',
          ),
        ),
      );
    }
  }

  List<Widget> _orderItems(CustomerOrder order) {
    if (order.items.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text('Nenhum item encontrado'),
        ),
      ];
    }

    return order.items.map<Widget>((item) {
      return ListTile(
        title: Text(item.productName),
        subtitle: Text('Quantidade: ${item.quantity}'),
        trailing: Text(formatBrl(item.totalPrice)),
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
      case 'delivered':
        color = Colors.green;
        label = 'Concluído';
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
