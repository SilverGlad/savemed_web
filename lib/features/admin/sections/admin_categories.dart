part of '../admin_page.dart';

class _CategoriesPage extends _AdminListPage {
  const _CategoriesPage({required super.pharmacyId});

  @override
  State<_CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends _AdminListPageState<_CategoriesPage> {
  @override
  String get title => 'Categorias';

  @override
  String get subtitle => 'Organizacao do catalogo exibido na loja.';

  @override
  String get createLabel => 'Nova categoria';

  @override
  Future<List<dynamic>> fetch() =>
      service.listCategories(pharmacyId: widget.pharmacyId);

  @override
  bool matches(Map<String, dynamic> item, String query) =>
      textMatch(item, query);

  @override
  List<DataColumn> get columns => const [
    DataColumn(label: Text('Nome')),
    DataColumn(label: Text('Farmacia')),
    DataColumn(label: Text('Subcategorias')),
    DataColumn(label: Text('Acoes')),
  ];

  @override
  DataRow buildRow(Map<String, dynamic> item) {
    final subs = item['subcategories'] as List? ?? const [];
    return DataRow(
      cells: [
        DataCell(_PrimaryCell(title: _str(item['NAME']), subtitle: _id(item))),
        DataCell(Text(_str(item['PHARMACY_ID'], fallback: '-'))),
        DataCell(Text(subs.length.toString())),
        DataCell(
          _RowActions(
            onEdit: () => _showDialog(item: item),
            onDelete: () => confirmDelete(
              itemLabel: 'a categoria ${_str(item['NAME'])}',
              action: () => service.deleteCategory(item['ID']),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildMobileItem(Map<String, dynamic> item) {
    final subs = item['subcategories'] as List? ?? const [];
    return _CompactTile(
      title: _str(item['NAME'], fallback: 'Categoria'),
      subtitle: 'Farmacia ${_str(item['PHARMACY_ID'], fallback: '-')}',
      chips: [_SmallChip('${subs.length} subcategorias')],
      onEdit: () => _showDialog(item: item),
      onDelete: () => confirmDelete(
        itemLabel: 'a categoria ${_str(item['NAME'])}',
        action: () => service.deleteCategory(item['ID']),
      ),
    );
  }

  @override
  Future<void> onCreate() => _showDialog();

  Future<void> _showDialog({Map<String, dynamic>? item}) async {
    final name = TextEditingController(text: _str(item?['NAME']));
    var pharmacyId = _asInt(item?['PHARMACY_ID']) ?? widget.pharmacyId;
    final pharmacies = widget.pharmacyId == null
        ? await loadOptions(
            service.listPharmacies(),
            'Nao foi possivel carregar as farmacias.',
          )
        : <dynamic>[
            {'ID': widget.pharmacyId, 'NAME': 'Minha farmacia'},
          ];
    if (pharmacies == null || !mounted) return;
    await _showAdminDialog(
      context: context,
      title: item == null ? 'Nova categoria' : 'Editar categoria',
      child: _FormGrid(
        children: [
          _input(name, 'Nome'),
          _entityDropdown(
            label: 'Farmacia',
            value: pharmacyId,
            items: pharmacies,
            enabled: widget.pharmacyId == null,
            onChanged: (value) => pharmacyId = value,
          ),
        ],
      ),
      onSave: () => handle(() async {
        if (!isValidRequiredText(name.text) || pharmacyId == null) {
          throw Exception('Informe o nome e selecione a farmacia.');
        }
        await service.saveCategory({
          'NAME': name.text.trim(),
          'PHARMACY_ID': pharmacyId,
        }, id: item?['ID'] as int?);
      }),
    );
  }
}
