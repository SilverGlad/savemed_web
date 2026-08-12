part of '../admin_page.dart';

class _MedicationsPage extends _AdminListPage {
  const _MedicationsPage({required super.pharmacyId});

  @override
  State<_MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends _AdminListPageState<_MedicationsPage> {
  @override
  String get title => 'Produtos';

  @override
  String get subtitle => 'Cadastro dos medicamentos e itens comercializados.';

  @override
  String get createLabel => 'Novo produto';

  @override
  Future<List<dynamic>> fetch() =>
      service.listMedications(pharmacyId: widget.pharmacyId);

  @override
  bool matches(Map<String, dynamic> item, String query) =>
      textMatch(item, query);

  @override
  List<DataColumn> get columns => const [
    DataColumn(label: Text('Produto')),
    DataColumn(label: Text('Farmacia')),
    DataColumn(label: Text('Categoria')),
    DataColumn(label: Text('Acoes')),
  ];

  @override
  DataRow buildRow(Map<String, dynamic> item) {
    return DataRow(
      cells: [
        DataCell(_PrimaryCell(title: _str(item['NAME']), subtitle: _id(item))),
        DataCell(Text(_str(item['PHARMACY_ID'], fallback: '-'))),
        DataCell(Text(_str(item['CATEGORY_ID'], fallback: '-'))),
        DataCell(
          _RowActions(
            onEdit: () => _showDialog(item: item),
            onDelete: () => confirmDelete(
              itemLabel: 'o produto ${_str(item['NAME'])}',
              action: () => service.deleteMedication(item['ID']),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildMobileItem(Map<String, dynamic> item) {
    return _CompactTile(
      title: _str(item['NAME'], fallback: 'Produto'),
      subtitle: 'Farmacia ${_str(item['PHARMACY_ID'], fallback: '-')}',
      chips: [
        _SmallChip('Categoria ${_str(item['CATEGORY_ID'], fallback: '-')}'),
      ],
      onEdit: () => _showDialog(item: item),
      onDelete: () => confirmDelete(
        itemLabel: 'o produto ${_str(item['NAME'])}',
        action: () => service.deleteMedication(item['ID']),
      ),
    );
  }

  @override
  Future<void> onCreate() => _showDialog();

  Future<void> _showDialog({Map<String, dynamic>? item}) async {
    final name = TextEditingController(text: _str(item?['NAME']));
    final description = TextEditingController(text: _str(item?['DESCRIPTION']));
    final brand = TextEditingController(text: _str(item?['BRAND']));
    final unit = TextEditingController(text: _str(item?['UNIT']));
    final ean = TextEditingController(text: _str(item?['EAN_CODE']));
    var requiresRx = item?['REQUIRES_RX'] == true;
    var pharmacyId = _asInt(item?['PHARMACY_ID']) ?? widget.pharmacyId;
    var categoryId = _asInt(item?['CATEGORY_ID']);
    var subcategoryId = _asInt(item?['SUBCATEGORY_ID']);
    final pharmacies = widget.pharmacyId == null
        ? await loadOptions(
            service.listPharmacies(),
            'Nao foi possivel carregar as farmacias.',
          )
        : <dynamic>[
            {'ID': widget.pharmacyId, 'NAME': 'Minha farmacia'},
          ];
    final categories = await loadOptions(
      service.listCategories(pharmacyId: widget.pharmacyId),
      'Nao foi possivel carregar as categorias.',
    );
    if (pharmacies == null || categories == null || !mounted) return;
    final subcategories = categories
        .whereType<Map<String, dynamic>>()
        .expand(
          (category) =>
              (category['subcategories'] ?? category['Subcategories'])
                  as List? ??
              const [],
        )
        .whereType<Map<String, dynamic>>()
        .toList();

    await _showAdminDialog(
      context: context,
      title: item == null ? 'Novo produto' : 'Editar produto',
      child: StatefulBuilder(
        builder: (context, setDialogState) => _FormGrid(
          children: [
            _input(name, 'Nome'),
            _input(description, 'Descricao'),
            _input(brand, 'Marca'),
            _input(unit, 'Unidade (ex.: caixa, frasco)'),
            _input(
              ean,
              'Codigo de barras (EAN)',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            _entityDropdown(
              label: 'Farmacia',
              value: pharmacyId,
              items: pharmacies,
              enabled: widget.pharmacyId == null,
              onChanged: (value) => pharmacyId = value,
            ),
            _entityDropdown(
              label: 'Categoria',
              value: categoryId,
              items: categories,
              onChanged: (value) => categoryId = value,
            ),
            _entityDropdown(
              label: 'Subcategoria',
              value: subcategoryId,
              items: subcategories,
              optional: true,
              onChanged: (value) => subcategoryId = value,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Exige receita medica'),
              subtitle: const Text(
                'Ative quando a venda depender de prescricao.',
              ),
              value: requiresRx,
              onChanged: (value) => setDialogState(() => requiresRx = value),
            ),
          ],
        ),
      ),
      onSave: () => handle(() async {
        final categoryMatches = categories
            .whereType<Map<String, dynamic>>()
            .any(
              (category) =>
                  _asInt(category['ID']) == categoryId &&
                  (_asInt(category['PHARMACY_ID']) == null ||
                      _asInt(category['PHARMACY_ID']) == pharmacyId),
            );
        final subcategoryMatches =
            subcategoryId == null ||
            subcategories.any(
              (subcategory) =>
                  _asInt(subcategory['ID']) == subcategoryId &&
                  (_asInt(subcategory['CATEGORY_ID']) == null ||
                      _asInt(subcategory['CATEGORY_ID']) == categoryId),
            );
        final eanValue = ean.text.trim();
        final validEan =
            eanValue.isEmpty || (eanValue.length >= 8 && eanValue.length <= 14);
        if (!isValidRequiredText(name.text) ||
            pharmacyId == null ||
            categoryId == null ||
            !categoryMatches ||
            !subcategoryMatches ||
            !validEan) {
          throw Exception(
            'Informe nome, categoria e um EAN entre 8 e 14 digitos, quando preenchido.',
          );
        }
        await service.saveMedication({
          'NAME': name.text.trim(),
          'DESCRIPTION': description.text.trim(),
          'BRAND': brand.text.trim(),
          'UNIT': unit.text.trim(),
          'EAN_CODE': eanValue.isEmpty ? null : eanValue,
          'REQUIRES_RX': requiresRx,
          'PHARMACY_ID': pharmacyId,
          'CATEGORY_ID': categoryId,
          'SUBCATEGORY_ID': subcategoryId,
        }, id: item?['ID'] as int?);
      }),
    );
  }
}
