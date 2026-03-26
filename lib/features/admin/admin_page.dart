import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SaveMed/core/controllers/auth_controller.dart';
import 'package:SaveMed/core/services/admin_service.dart';
import 'package:SaveMed/core/theme/app_colors.dart';
import 'package:SaveMed/core/widgets/savemed_footer.dart';
import 'package:SaveMed/core/widgets/savemed_header.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user ?? {};
    final role = user['USER_ROLE']?.toString() ?? '';
    final pharmacyId = user['PHARMACY_ID'] as int?;
    final isAppAdmin = role == 'app_admin';

    final tabs = <Tab>[
      if (isAppAdmin) const Tab(text: 'Farmacias'),
      const Tab(text: 'Solicitacoes'),
      const Tab(text: 'Categorias'),
      const Tab(text: 'Medicamentos'),
      const Tab(text: 'Inventario'),
      const Tab(text: 'Pedidos'),
    ];

    final views = <Widget>[
      if (isAppAdmin) const _PharmaciesTab(),
      _AccessRequestsTab(pharmacyId: isAppAdmin ? null : pharmacyId),
      _CategoriesTab(pharmacyId: isAppAdmin ? null : pharmacyId),
      _MedicationsTab(pharmacyId: isAppAdmin ? null : pharmacyId),
      _InventoryTab(pharmacyId: isAppAdmin ? null : pharmacyId),
      _OrdersTab(pharmacyId: isAppAdmin ? null : pharmacyId),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            SaveMedHeader(),
            Expanded(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _AdminHero(),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TabBar(
                      isScrollable: true,
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textLight,
                      tabs: tabs,
                    ),
                  ),
                  Expanded(child: TabBarView(children: views)),
                ],
              ),
            ),
            const SaveMedFooter(),
          ],
        ),
      ),
    );
  }
}

class _AdminHero extends StatelessWidget {
  const _AdminHero();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user ?? {};
    final role = user['USER_ROLE']?.toString() ?? '';
    final isAppAdmin = role == 'app_admin';
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF132F2A), Color(0xFF165F4F), Color(0xFF1D9B7D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Wrap(
        runSpacing: 16,
        spacing: 16,
        alignment: WrapAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isAppAdmin ? 'Painel geral SaveMed' : 'Painel da farmacia',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Gerencie catalogo, estoque e pedidos com foco operacional.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAppAdmin
                      ? 'Acompanhe toda a rede, edite entidades centrais e trate pedidos com estorno.'
                      : 'Atualize dados da sua farmacia, ajuste produtos e acompanhe pedidos em andamento.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeroBadge(
                icon: Icons.storefront_outlined,
                label: 'Escopo',
                value: isAppAdmin ? 'Plataforma' : 'Farmacia',
              ),
              const _HeroBadge(
                icon: Icons.tune_outlined,
                label: 'Acoes',
                value: 'CRUD + pedidos',
              ),
              const _HeroBadge(
                icon: Icons.sync_alt_outlined,
                label: 'Fluxo',
                value: 'Operacao diaria',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeroBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

abstract class _AdminListState<T extends StatefulWidget> extends State<T> {
  final AdminService service = AdminService();
  bool loading = true;
  String? error;
  List<dynamic> items = [];

  Future<void> reload();

  Future<void> handle(Future<void> Function() action) async {
    setState(() => error = null);
    try {
      await action();
      await reload();
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget buildScaffold({
    required String title,
    required String description,
    required VoidCallback onCreate,
    required Widget child,
    String createLabel = 'Novo',
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            runSpacing: 14,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
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
                      description,
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: onCreate,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                ),
                icon: const Icon(Icons.add),
                label: Text(createLabel),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                error!,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : child,
          ),
        ],
      ),
    );
  }
}

class _PharmaciesTab extends StatefulWidget {
  const _PharmaciesTab();

  @override
  State<_PharmaciesTab> createState() => _PharmaciesTabState();
}

class _PharmaciesTabState extends _AdminListState<_PharmaciesTab> {
  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  Future<void> reload() async {
    setState(() => loading = true);
    try {
      items = await service.listPharmacies();
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold(
      title: 'Farmacias',
      description:
          'Visualize unidades cadastradas e mantenha os dados operacionais atualizados.',
      onCreate: () => _showPharmacyDialog(),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final pharmacy = items[index] as Map<String, dynamic>;
          return Card(
            child: ListTile(
              title: Text(pharmacy['NAME']?.toString() ?? 'Farmacia'),
              subtitle: Text(
                [
                  pharmacy['CITY'],
                  pharmacy['STATE'],
                  pharmacy['ZIPCODE'],
                ].whereType<String>().where((e) => e.isNotEmpty).join(' • '),
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    onPressed: () => _showPharmacyDialog(pharmacy: pharmacy),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => handle(
                      () => service.deletePharmacy(pharmacy['ID'] as int),
                    ),
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showPharmacyDialog({Map<String, dynamic>? pharmacy}) async {
    final name = TextEditingController(
      text: pharmacy?['NAME']?.toString() ?? '',
    );
    final phone = TextEditingController(
      text: pharmacy?['PHONE']?.toString() ?? '',
    );
    final city = TextEditingController(
      text: pharmacy?['CITY']?.toString() ?? '',
    );
    final stateCtrl = TextEditingController(
      text: pharmacy?['STATE']?.toString() ?? '',
    );
    final zip = TextEditingController(
      text: pharmacy?['ZIPCODE']?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(pharmacy == null ? 'Nova farmacia' : 'Editar farmacia'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _input(name, 'Nome'),
              _input(phone, 'Telefone'),
              _input(city, 'Cidade'),
              _input(stateCtrl, 'Estado'),
              _input(zip, 'CEP'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await handle(
                () => service.savePharmacy({
                  'NAME': name.text,
                  'PHONE': phone.text,
                  'CITY': city.text,
                  'STATE': stateCtrl.text,
                  'ZIPCODE': zip.text,
                }, id: pharmacy?['ID'] as int?),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _CategoriesTab extends StatefulWidget {
  final int? pharmacyId;

  const _CategoriesTab({required this.pharmacyId});

  @override
  State<_CategoriesTab> createState() => _CategoriesTabState();
}

class _AccessRequestsTab extends StatefulWidget {
  final int? pharmacyId;

  const _AccessRequestsTab({required this.pharmacyId});

  @override
  State<_AccessRequestsTab> createState() => _AccessRequestsTabState();
}

class _AccessRequestsTabState extends _AdminListState<_AccessRequestsTab> {
  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  Future<void> reload() async {
    setState(() => loading = true);
    try {
      items = await service.listAccessRequests(pharmacyId: widget.pharmacyId);
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold(
      title: 'Solicitacoes de acesso',
      description:
          'Aprove ou rejeite pessoas que pediram acesso a uma farmacia ja cadastrada.',
      onCreate: () => reload(),
      createLabel: 'Atualizar',
      child: items.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma solicitacao encontrada.',
                style: TextStyle(color: AppColors.textLight),
              ),
            )
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final request = items[index] as Map<String, dynamic>;
                final pharmacy = request['pharmacy'] as Map<String, dynamic>?;
                final status = request['STATUS']?.toString() ?? 'pending';
                final pending = status == 'pending';
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request['NAME']?.toString() ?? 'Solicitante',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${request['EMAIL']} • ${pharmacy?['NAME'] ?? 'Farmacia'}',
                          style: const TextStyle(color: AppColors.textLight),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Status: $status',
                          style: TextStyle(
                            color: pending
                                ? AppColors.primaryDark
                                : AppColors.textLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if ((request['REQUEST_MESSAGE'] ?? '')
                            .toString()
                            .isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            request['REQUEST_MESSAGE'].toString(),
                            style: const TextStyle(color: AppColors.textDark),
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (pending)
                          Wrap(
                            spacing: 10,
                            children: [
                              FilledButton(
                                onPressed: () => handle(
                                  () => service.approveAccessRequest(
                                    request['ID'] as int,
                                  ),
                                ),
                                child: const Text('Aprovar'),
                              ),
                              OutlinedButton(
                                onPressed: () => handle(
                                  () => service.rejectAccessRequest(
                                    request['ID'] as int,
                                  ),
                                ),
                                child: const Text('Rejeitar'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _CategoriesTabState extends _AdminListState<_CategoriesTab> {
  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  Future<void> reload() async {
    setState(() => loading = true);
    try {
      items = await service.listCategories(pharmacyId: widget.pharmacyId);
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold(
      title: 'Categorias',
      description:
          'Organize o catalogo por grupos e mantenha a navegacao mais limpa.',
      onCreate: () => _showCategoryDialog(),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final category = items[index] as Map<String, dynamic>;
          final subcategories = category['subcategories'] as List? ?? [];
          return Card(
            child: ListTile(
              title: Text(category['NAME']?.toString() ?? 'Categoria'),
              subtitle: Text('${subcategories.length} subcategorias'),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    onPressed: () => _showCategoryDialog(category: category),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => handle(
                      () => service.deleteCategory(category['ID'] as int),
                    ),
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCategoryDialog({Map<String, dynamic>? category}) async {
    final name = TextEditingController(
      text: category?['NAME']?.toString() ?? '',
    );
    final pharmacyId = TextEditingController(
      text: (category?['PHARMACY_ID'] ?? widget.pharmacyId)?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(category == null ? 'Nova categoria' : 'Editar categoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _input(name, 'Nome'),
            _input(pharmacyId, 'ID da farmacia'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await handle(
                () => service.saveCategory({
                  'NAME': name.text,
                  'PHARMACY_ID': int.tryParse(pharmacyId.text),
                }, id: category?['ID'] as int?),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _MedicationsTab extends StatefulWidget {
  final int? pharmacyId;

  const _MedicationsTab({required this.pharmacyId});

  @override
  State<_MedicationsTab> createState() => _MedicationsTabState();
}

class _MedicationsTabState extends _AdminListState<_MedicationsTab> {
  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  Future<void> reload() async {
    setState(() => loading = true);
    try {
      items = await service.listMedications(pharmacyId: widget.pharmacyId);
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold(
      title: 'Medicamentos',
      description: 'Atualize o cadastro base dos itens exibidos na plataforma.',
      onCreate: () => _showMedicationDialog(),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final medication = items[index] as Map<String, dynamic>;
          return Card(
            child: ListTile(
              title: Text(medication['NAME']?.toString() ?? 'Medicamento'),
              subtitle: Text(
                'Farmacia ${medication['PHARMACY_ID']} • Categoria ${medication['CATEGORY_ID']}',
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    onPressed: () =>
                        _showMedicationDialog(medication: medication),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => handle(
                      () => service.deleteMedication(medication['ID'] as int),
                    ),
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showMedicationDialog({Map<String, dynamic>? medication}) async {
    final name = TextEditingController(
      text: medication?['NAME']?.toString() ?? '',
    );
    final description = TextEditingController(
      text: medication?['DESCRIPTION']?.toString() ?? '',
    );
    final pharmacyId = TextEditingController(
      text: (medication?['PHARMACY_ID'] ?? widget.pharmacyId)?.toString() ?? '',
    );
    final categoryId = TextEditingController(
      text: medication?['CATEGORY_ID']?.toString() ?? '',
    );
    final subcategoryId = TextEditingController(
      text: medication?['SUBCATEGORY_ID']?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          medication == null ? 'Novo medicamento' : 'Editar medicamento',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _input(name, 'Nome'),
              _input(description, 'Descricao'),
              _input(pharmacyId, 'ID da farmacia'),
              _input(categoryId, 'ID da categoria'),
              _input(subcategoryId, 'ID da subcategoria'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await handle(
                () => service.saveMedication({
                  'NAME': name.text,
                  'DESCRIPTION': description.text,
                  'PHARMACY_ID': int.tryParse(pharmacyId.text),
                  'CATEGORY_ID': int.tryParse(categoryId.text),
                  'SUBCATEGORY_ID': int.tryParse(subcategoryId.text),
                }, id: medication?['ID'] as int?),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _InventoryTab extends StatefulWidget {
  final int? pharmacyId;

  const _InventoryTab({required this.pharmacyId});

  @override
  State<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends _AdminListState<_InventoryTab> {
  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  Future<void> reload() async {
    setState(() => loading = true);
    try {
      items = await service.listInventory(pharmacyId: widget.pharmacyId);
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold(
      title: 'Inventario',
      description:
          'Controle preco, estoque e associacao entre farmacia e medicamento.',
      onCreate: () => _showInventoryDialog(),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final inventory = items[index] as Map<String, dynamic>;
          final med =
              (inventory['Medication'] ?? inventory['medication'])
                  as Map<String, dynamic>?;
          return Card(
            child: ListTile(
              title: Text(med?['NAME']?.toString() ?? 'Item'),
              subtitle: Text(
                'Farmacia ${inventory['PHARMACY_ID']} • Estoque ${inventory['STOCK']} • R\$ ${inventory['PRICE']}',
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    onPressed: () => _showInventoryDialog(inventory: inventory),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => handle(
                      () => service.deleteInventory(inventory['ID'] as int),
                    ),
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showInventoryDialog({Map<String, dynamic>? inventory}) async {
    final pharmacyId = TextEditingController(
      text: (inventory?['PHARMACY_ID'] ?? widget.pharmacyId)?.toString() ?? '',
    );
    final medicationId = TextEditingController(
      text: inventory?['MEDICATION_ID']?.toString() ?? '',
    );
    final price = TextEditingController(
      text: inventory?['PRICE']?.toString() ?? '',
    );
    final originalPrice = TextEditingController(
      text: inventory?['ORIGINAL_PRICE']?.toString() ?? '',
    );
    final stock = TextEditingController(
      text: inventory?['STOCK']?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(inventory == null ? 'Novo item' : 'Editar item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _input(pharmacyId, 'ID da farmacia'),
              _input(medicationId, 'ID do medicamento'),
              _input(price, 'Preco'),
              _input(originalPrice, 'Preco original'),
              _input(stock, 'Estoque'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await handle(
                () => service.saveInventory({
                  'PHARMACY_ID': int.tryParse(pharmacyId.text),
                  'MEDICATION_ID': int.tryParse(medicationId.text),
                  'PRICE': double.tryParse(price.text),
                  'ORIGINAL_PRICE': double.tryParse(originalPrice.text),
                  'STOCK': int.tryParse(stock.text),
                }, id: inventory?['ID'] as int?),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatefulWidget {
  final int? pharmacyId;

  const _OrdersTab({required this.pharmacyId});

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends _AdminListState<_OrdersTab> {
  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  Future<void> reload() async {
    setState(() => loading = true);
    try {
      items = await service.listOrders(pharmacyId: widget.pharmacyId);
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold(
      title: 'Pedidos',
      description:
          'Monitore status, pagamento e acione estorno quando necessario.',
      onCreate: () => reload(),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final order = items[index] as Map<String, dynamic>;
          final pharmacyName = order['pharmacy']?['NAME'] ?? 'Farmacia';
          return Card(
            child: ListTile(
              title: Text('Pedido #${order['ID']} • $pharmacyName'),
              subtitle: Text(
                'Status ${order['STATUS']} • Pagamento ${order['PAYMENT_STATUS']} • Total R\$ ${order['TOTAL_AMOUNT']}',
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    onPressed: () => _showOrderDialog(order),
                    icon: const Icon(Icons.edit),
                  ),
                  TextButton(
                    onPressed: () =>
                        handle(() => service.refundOrder(order['ID'] as int)),
                    child: const Text('Estornar'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showOrderDialog(Map<String, dynamic> order) async {
    final status = TextEditingController(
      text: order['STATUS']?.toString() ?? '',
    );
    final paymentStatus = TextEditingController(
      text: order['PAYMENT_STATUS']?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Editar pedido #${order['ID']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _input(status, 'STATUS'),
            _input(paymentStatus, 'PAYMENT_STATUS'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await handle(
                () => service.updateOrder(order['ID'] as int, {
                  'STATUS': status.text,
                  'PAYMENT_STATUS': paymentStatus.text,
                }),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

Widget _input(TextEditingController controller, String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
