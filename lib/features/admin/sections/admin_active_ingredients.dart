part of '../admin_page.dart';

class _ActiveIngredientsPage extends _AdminListPage {
  const _ActiveIngredientsPage({required super.service})
    : super(pharmacyId: null);

  @override
  State<_ActiveIngredientsPage> createState() => _ActiveIngredientsPageState();
}

class _ActiveIngredientsPageState
    extends _AdminListPageState<_ActiveIngredientsPage, ActiveIngredient> {
  Map<int, String> _pharmacyNames = const {};

  @override
  String get title => 'Princípios ativos';

  @override
  String get subtitle =>
      'Princípios ativos separados por farmácia para classificar os produtos.';

  @override
  String get createLabel => 'Novo princípio ativo';

  @override
  Future<List<ActiveIngredient>> fetch() async {
    final results = await Future.wait<Object>([
      service.listActiveIngredients(),
      service.listPharmacies().catchError((_) => <Pharmacy>[]),
    ]);
    _pharmacyNames = {
      for (final pharmacy in results[1] as List<Pharmacy>)
        pharmacy.id: pharmacy.name,
    };
    return results[0] as List<ActiveIngredient>;
  }

  String _pharmacyLabel(int? id) =>
      id == null ? 'Catálogo legado' : _pharmacyNames[id] ?? 'Farmácia #$id';

  @override
  bool matches(ActiveIngredient item, String query) =>
      item.name.toLowerCase().contains(query);

  @override
  List<DataColumn> get columns => const [
    DataColumn(label: Text('Nome')),
    DataColumn(label: Text('Farmácia')),
    DataColumn(label: Text('Ações')),
  ];

  @override
  DataRow buildRow(ActiveIngredient item) => DataRow(
    cells: [
      DataCell(Text(item.name)),
      DataCell(Text(_pharmacyLabel(item.pharmacyId))),
      DataCell(
        _RowActions(
          onEdit: () => _showDialog(item: item),
          onDelete: () => confirmDelete(
            itemLabel: 'o princípio ativo ${item.name}',
            action: () => service.deleteActiveIngredient(item.id),
          ),
        ),
      ),
    ],
  );

  @override
  Widget buildMobileItem(ActiveIngredient item) => _CompactTile(
    title: item.name,
    subtitle: _pharmacyLabel(item.pharmacyId),
    chips: const [],
    onEdit: () => _showDialog(item: item),
    onDelete: () => confirmDelete(
      itemLabel: 'o princípio ativo ${item.name}',
      action: () => service.deleteActiveIngredient(item.id),
    ),
  );

  @override
  Future<void> onCreate() => _showDialog();

  Future<void> _showDialog({ActiveIngredient? item}) async {
    final pharmacies = await loadOptions(
      service.listPharmacies(),
      'Não foi possível carregar as farmácias.',
    );
    if (pharmacies == null || !mounted) return;
    final name = TextEditingController(text: item?.name ?? '');
    var pharmacyId = item?.pharmacyId;
    await _showAdminDialog(
      context: context,
      title: item == null ? 'Novo princípio ativo' : 'Editar princípio ativo',
      controllers: [name],
      child: StatefulBuilder(
        builder: (context, setDialogState) => _FormGrid(
          children: [
            _input(
              name,
              'Nome',
              validator: (value) => _requiredTextValidator(value, 'o nome'),
            ),
            if (item == null)
              _entityDropdown(
                label: 'Farmácia',
                value: pharmacyId,
                items: pharmacies,
                validator: (value) =>
                    _requiredEntityValidator(value, 'a farmácia'),
                onChanged: (value) => setDialogState(() => pharmacyId = value),
              )
            else
              _FullWidthFormField(
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Farmácia'),
                  child: Text(
                    pharmacies
                            .where((pharmacy) => pharmacy.id == item.pharmacyId)
                            .firstOrNull
                            ?.name ??
                        'Registro legado sem farmácia vinculada',
                  ),
                ),
              ),
          ],
        ),
      ),
      onSave: () => handle(() async {
        if (!isValidRequiredText(name.text) ||
            (item == null && pharmacyId == null)) {
          throw Exception('Informe o nome e selecione a farmácia.');
        }
        await service.saveActiveIngredient({
          'NAME': name.text.trim(),
          'PHARMACY_ID': pharmacyId,
        }, id: item?.id);
      }),
    );
  }
}
