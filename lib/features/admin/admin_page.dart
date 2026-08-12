import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SaveMed/core/controllers/auth_controller.dart';
import 'package:SaveMed/core/services/admin_service.dart';
import 'package:SaveMed/core/theme/app_colors.dart';
import 'package:SaveMed/core/widgets/savemed_footer.dart';
import 'package:SaveMed/core/widgets/savemed_header.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  static const double _maxContentWidth = 1180;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user ?? {};
    final role = user['USER_ROLE']?.toString() ?? '';
    final pharmacyId = user['PHARMACY_ID'] as int?;
    final isAppAdmin = role == 'app_admin';

    final tabs = <Tab>[
      if (isAppAdmin) const Tab(text: 'Farmacias'),
      if (isAppAdmin) const Tab(text: 'Categorias'),
      const Tab(text: 'Medicamentos'),
      const Tab(text: 'Pedidos'),
    ];

    final views = <Widget>[
      if (isAppAdmin) const _PharmaciesTab(),
      if (isAppAdmin) _CategoriesTab(pharmacyId: null),
      _MedicationsTab(pharmacyId: isAppAdmin ? null : pharmacyId),
      _OrdersTab(pharmacyId: isAppAdmin ? null : pharmacyId),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final tabViewHeight = (constraints.maxHeight - 340).clamp(420.0, 900.0);

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: _maxContentWidth,
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      const SaveMedHeader(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                        child: Column(
                          children: [
                            const _AdminHero(),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
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
                              child: TabBar(
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                                indicator: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                dividerColor: Colors.transparent,
                                labelColor: Colors.white,
                                unselectedLabelColor: AppColors.textLight,
                                tabs: tabs,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: tabViewHeight,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: TabBarView(children: views),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const SaveMedFooter(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
      padding: const EdgeInsets.all(24),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      width: 164,
      padding: const EdgeInsets.all(16),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
          return _adminListCard(
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
          );
        },
      ),
    );
  }

  Future<void> _showPharmacyDialog({Map<String, dynamic>? pharmacy}) async {
    final name = TextEditingController(text: pharmacy?['NAME']?.toString() ?? '');
    final phone = TextEditingController(text: pharmacy?['PHONE']?.toString() ?? '');
    final city = TextEditingController(text: pharmacy?['CITY']?.toString() ?? '');
    final stateCtrl = TextEditingController(text: pharmacy?['STATE']?.toString() ?? '');
    final zip = TextEditingController(text: pharmacy?['ZIPCODE']?.toString() ?? '');

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
              final payload = <String, dynamic>{
                'NAME': name.text.trim(),
                'PHONE': phone.text.trim(),
                'CITY': city.text.trim(),
                'STATE': stateCtrl.text.trim(),
                'ZIPCODE': zip.text.trim(),
              };

              await handle(
                () => service.savePharmacy(
                  payload,
                  id: pharmacy?['ID'] as int?,
                ),
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
      description: 'Organize o catalogo por grupos e mantenha a navegacao mais limpa.',
      onCreate: () => _showCategoryDialog(),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final category = items[index] as Map<String, dynamic>;
          final subcategories = category['subcategories'] as List? ?? [];
          return _adminListCard(
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
          );
        },
      ),
    );
  }

  Future<void> _showCategoryDialog({Map<String, dynamic>? category}) async {
    final name = TextEditingController(text: category?['NAME']?.toString() ?? '');
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
                () => service.saveCategory(
                  {
                    'NAME': name.text,
                    'PHARMACY_ID': int.tryParse(pharmacyId.text),
                  },
                  id: category?['ID'] as int?,
                ),
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
  State<_MedicationsTab> createState() => _MedicationsManagementState();
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
          return _adminListCard(
            title: Text(medication['NAME']?.toString() ?? 'Medicamento'),
            subtitle: Text(
              'Farmacia ${medication['PHARMACY_ID']} • Categoria ${medication['CATEGORY_ID']}',
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  onPressed: () => _showMedicationDialog(medication: medication),
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
          );
        },
      ),
    );
  }

  Future<void> _showMedicationDialog({Map<String, dynamic>? medication}) async {
    final name = TextEditingController(text: medication?['NAME']?.toString() ?? '');
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
        title: Text(medication == null ? 'Novo medicamento' : 'Editar medicamento'),
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
                () => service.saveMedication(
                  {
                    'NAME': name.text,
                    'DESCRIPTION': description.text,
                    'PHARMACY_ID': int.tryParse(pharmacyId.text),
                    'CATEGORY_ID': int.tryParse(categoryId.text),
                    'SUBCATEGORY_ID': int.tryParse(subcategoryId.text),
                  },
                  id: medication?['ID'] as int?,
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _MedicationsManagementState extends _AdminListState<_MedicationsTab> {
  List<dynamic> _categories = [];
  List<dynamic> _subcategories = [];
  Map<int, Map<String, dynamic>> _inventoryByMedicationId = {};

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  Future<void> reload() async {
    setState(() => loading = true);
    try {
      final results = await Future.wait([
        service.listMedications(pharmacyId: widget.pharmacyId),
        service.listCategories(),
        service.listInventory(pharmacyId: widget.pharmacyId),
      ]);

      items = results[0] as List<dynamic>;
      _categories = results[1] as List<dynamic>;
      _subcategories = _categories
          .cast<Map<String, dynamic>>()
          .expand(
            (category) => ((category['subcategories'] as List?) ?? const [])
                .cast<Map<String, dynamic>>(),
          )
          .toList();

      final inventoryItems = results[2] as List<dynamic>;
      _inventoryByMedicationId = {
        for (final item in inventoryItems.cast<Map<String, dynamic>>())
          if (item['MEDICATION_ID'] is int) item['MEDICATION_ID'] as int: item,
      };
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
      description: 'Cadastre medicamento, categoria, estoque e preco promocional no mesmo fluxo.',
      onCreate: () => _showMedicationDialog(),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final medication = items[index] as Map<String, dynamic>;
          final inventory = _inventoryByMedicationId[medication['ID'] as int? ?? -1];
          final categoryName = _lookupName(_categories, medication['CATEGORY_ID']);
          final subcategoryName = _lookupName(_subcategories, medication['SUBCATEGORY_ID']);

          return _adminListCard(
            title: Text(medication['NAME']?.toString() ?? 'Medicamento'),
            subtitle: Text(
              [
                'Categoria $categoryName',
                if (subcategoryName != '-') 'Subcategoria $subcategoryName',
                if (inventory?['STOCK'] != null) 'Estoque ${inventory?['STOCK']}',
                if (inventory?['PRICE'] != null) 'Preco R\$ ${inventory?['PRICE']}',
                if (inventory?['ORIGINAL_PRICE'] != null &&
                    inventory?['PRICE'] != null &&
                    inventory!['ORIGINAL_PRICE'].toString() !=
                        inventory['PRICE'].toString())
                  'De R\$ ${inventory['ORIGINAL_PRICE']}',
              ].join(' • '),
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  onPressed: () => _showMedicationDialog(medication: medication),
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
          );
        },
      ),
    );
  }

  Future<void> _showMedicationDialog({Map<String, dynamic>? medication}) async {
    final existingInventory = medication == null
        ? null
        : _inventoryByMedicationId[medication['ID'] as int? ?? -1];
    final resolvedPharmacyId = widget.pharmacyId ?? medication?['PHARMACY_ID'] as int?;
    final isScopedToPharmacy = widget.pharmacyId != null;
    final name = TextEditingController(text: medication?['NAME']?.toString() ?? '');
    final description = TextEditingController(
      text: medication?['DESCRIPTION']?.toString() ?? '',
    );
    final pharmacyId = TextEditingController(
      text: (resolvedPharmacyId)?.toString() ?? '',
    );
    final price = TextEditingController(text: existingInventory?['PRICE']?.toString() ?? '');
    final originalPrice = TextEditingController(
      text: existingInventory?['ORIGINAL_PRICE']?.toString() ?? '',
    );
    final stock = TextEditingController(text: existingInventory?['STOCK']?.toString() ?? '');
    int? selectedCategoryId = medication?['CATEGORY_ID'] as int?;
    int? selectedSubcategoryId = medication?['SUBCATEGORY_ID'] as int?;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredSubcategories = _subcategories
                .cast<Map<String, dynamic>>()
                .where((item) => item['CATEGORY_ID'] == selectedCategoryId)
                .toList();

            if (!filteredSubcategories.any((item) => item['ID'] == selectedSubcategoryId)) {
              selectedSubcategoryId = null;
            }

            return AlertDialog(
              title: Text(medication == null ? 'Novo medicamento' : 'Editar medicamento'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _input(name, 'Nome'),
                      _input(description, 'Descricao'),
                      if (!isScopedToPharmacy) _input(pharmacyId, 'ID da farmacia'),
                      DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        decoration: _selectDecoration('Categoria'),
                        items: _categories
                            .cast<Map<String, dynamic>>()
                            .map(
                              (item) => DropdownMenuItem<int>(
                                value: item['ID'] as int,
                                child: Text(item['NAME']?.toString() ?? 'Categoria'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedCategoryId = value;
                            selectedSubcategoryId = null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: selectedSubcategoryId,
                        decoration: _selectDecoration('Subcategoria'),
                        items: filteredSubcategories
                            .map(
                              (item) => DropdownMenuItem<int>(
                                value: item['ID'] as int,
                                child: Text(item['NAME']?.toString() ?? 'Subcategoria'),
                              ),
                            )
                            .toList(),
                        onChanged: filteredSubcategories.isEmpty
                            ? null
                            : (value) => setDialogState(() {
                                  selectedSubcategoryId = value;
                                }),
                      ),
                      const SizedBox(height: 12),
                      _input(price, 'Preco atual'),
                      _input(originalPrice, 'Preco original'),
                      _input(stock, 'Estoque'),
                    ],
                  ),
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
                    await handle(() async {
                      final pharmacyIdValue = isScopedToPharmacy
                          ? resolvedPharmacyId
                          : int.tryParse(pharmacyId.text);

                      if (pharmacyIdValue == null) {
                        throw Exception('Selecione uma farmacia valida para o medicamento.');
                      }

                      final savedMedication = await service.saveMedication(
                        {
                          'NAME': name.text,
                          'DESCRIPTION': description.text,
                          'PHARMACY_ID': pharmacyIdValue,
                          'CATEGORY_ID': selectedCategoryId,
                          'SUBCATEGORY_ID': selectedSubcategoryId,
                        },
                        id: medication?['ID'] as int?,
                      );

                      await service.saveInventory(
                        {
                          'PHARMACY_ID': pharmacyIdValue,
                          'MEDICATION_ID': savedMedication['ID'],
                          'PRICE': double.tryParse(price.text) ?? 0,
                          'ORIGINAL_PRICE': double.tryParse(originalPrice.text) ??
                              double.tryParse(price.text) ??
                              0,
                          'STOCK': int.tryParse(stock.text) ?? 0,
                        },
                        id: existingInventory?['ID'] as int?,
                      );
                    });
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _lookupName(List<dynamic> source, dynamic id) {
    if (id == null) return '-';
    for (final item in source.cast<Map<String, dynamic>>()) {
      if (item['ID'] == id) {
        return item['NAME']?.toString() ?? '-';
      }
    }
    return '-';
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
      description: 'Controle preco, estoque e associacao entre farmacia e medicamento.',
      onCreate: () => _showInventoryDialog(),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final inventory = items[index] as Map<String, dynamic>;
          final med = (inventory['Medication'] ?? inventory['medication']) as Map<String, dynamic>?;
          return _adminListCard(
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
    final price = TextEditingController(text: inventory?['PRICE']?.toString() ?? '');
    final originalPrice = TextEditingController(
      text: inventory?['ORIGINAL_PRICE']?.toString() ?? '',
    );
    final stock = TextEditingController(text: inventory?['STOCK']?.toString() ?? '');

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
                () => service.saveInventory(
                  {
                    'PHARMACY_ID': int.tryParse(pharmacyId.text),
                    'MEDICATION_ID': int.tryParse(medicationId.text),
                    'PRICE': double.tryParse(price.text),
                    'ORIGINAL_PRICE': double.tryParse(originalPrice.text),
                    'STOCK': int.tryParse(stock.text),
                  },
                  id: inventory?['ID'] as int?,
                ),
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
      description: 'Monitore status, pagamento e acione estorno quando necessario.',
      onCreate: () => reload(),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final order = items[index] as Map<String, dynamic>;
          final pharmacyName = order['pharmacy']?['NAME'] ?? 'Farmacia';
          return _adminListCard(
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
                  onPressed: () => handle(
                    () => service.refundOrder(order['ID'] as int),
                  ),
                  child: const Text('Estornar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showOrderDialog(Map<String, dynamic> order) async {
    final status = TextEditingController(text: order['STATUS']?.toString() ?? '');
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
                () => service.updateOrder(
                  order['ID'] as int,
                  {
                    'STATUS': status.text,
                    'PAYMENT_STATUS': paymentStatus.text,
                  },
                ),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
  );
}

InputDecoration _selectDecoration(String label) {
  return InputDecoration(
    labelText: label,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
    ),
  );
}

Widget _adminListCard({
  required Widget title,
  Widget? subtitle,
  required Widget trailing,
}) {
  return Card(
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: const BorderSide(color: AppColors.border),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackActions = constraints.maxWidth < 760;

          if (stackActions) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  DefaultTextStyle.merge(
                    style: const TextStyle(
                      color: AppColors.textLight,
                      height: 1.4,
                    ),
                    child: subtitle,
                  ),
                ],
                const SizedBox(height: 14),
                Align(alignment: Alignment.centerLeft, child: trailing),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      DefaultTextStyle.merge(
                        style: const TextStyle(
                          color: AppColors.textLight,
                          height: 1.4,
                        ),
                        child: subtitle,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              trailing,
            ],
          );
        },
      ),
    ),
  );
}
