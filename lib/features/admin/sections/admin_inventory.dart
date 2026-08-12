part of '../admin_page.dart';

class _InventoryPage extends _AdminListPage {
  const _InventoryPage({required super.pharmacyId});

  @override
  State<_InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends _AdminListPageState<_InventoryPage> {
  @override
  String get title => widget.pharmacyId == null ? 'Inventario' : 'Estoque';

  @override
  String get subtitle => 'Preco, disponibilidade e estoque por farmacia.';

  @override
  String get createLabel => 'Novo item';

  @override
  Future<List<dynamic>> fetch() =>
      service.listInventory(pharmacyId: widget.pharmacyId);

  @override
  bool matches(Map<String, dynamic> item, String query) {
    final med = (item['Medication'] ?? item['medication']) as Map?;
    return textMatch(item, query) ||
        (med?['NAME']?.toString().toLowerCase().contains(query) ?? false);
  }

  @override
  List<DataColumn> get columns => const [
    DataColumn(label: Text('Item')),
    DataColumn(label: Text('Farmacia')),
    DataColumn(label: Text('Preco')),
    DataColumn(label: Text('Estoque')),
    DataColumn(label: Text('Acoes')),
  ];

  @override
  DataRow buildRow(Map<String, dynamic> item) {
    final med = (item['Medication'] ?? item['medication']) as Map?;
    return DataRow(
      cells: [
        DataCell(
          _PrimaryCell(
            title: _str(med?['NAME'], fallback: 'Item'),
            subtitle: 'Med ${_str(item['MEDICATION_ID'], fallback: '-')}',
          ),
        ),
        DataCell(Text(_str(item['PHARMACY_ID'], fallback: '-'))),
        DataCell(Text('R\$ ${_str(item['PRICE'], fallback: '0')}')),
        DataCell(_StockChip(value: int.tryParse(_str(item['STOCK'])) ?? 0)),
        DataCell(
          _RowActions(
            onEdit: () => _showDialog(item: item),
            onDelete: () => confirmDelete(
              itemLabel: 'este item do estoque',
              action: () => service.deleteInventory(item['ID']),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildMobileItem(Map<String, dynamic> item) {
    final med = (item['Medication'] ?? item['medication']) as Map?;
    return _CompactTile(
      title: _str(med?['NAME'], fallback: 'Item'),
      subtitle: 'R\$ ${_str(item['PRICE'], fallback: '0')}',
      chips: [
        _StockChip(value: int.tryParse(_str(item['STOCK'])) ?? 0),
        _SmallChip('Farmacia ${_str(item['PHARMACY_ID'], fallback: '-')}'),
      ],
      onEdit: () => _showDialog(item: item),
      onDelete: () => confirmDelete(
        itemLabel: 'este item do estoque',
        action: () => service.deleteInventory(item['ID']),
      ),
    );
  }

  @override
  Future<void> onCreate() => _showDialog();

  Future<void> _showDialog({Map<String, dynamic>? item}) async {
    var pharmacyId = _asInt(item?['PHARMACY_ID']) ?? widget.pharmacyId;
    var medicationId = _asInt(item?['MEDICATION_ID']);
    final price = TextEditingController(text: _str(item?['PRICE']));
    final originalPrice = TextEditingController(
      text: _str(item?['ORIGINAL_PRICE']),
    );
    final stock = TextEditingController(text: _str(item?['STOCK']));
    final pharmacies = widget.pharmacyId == null
        ? await loadOptions(
            service.listPharmacies(),
            'Nao foi possivel carregar as farmacias.',
          )
        : <dynamic>[
            {'ID': widget.pharmacyId, 'NAME': 'Minha farmacia'},
          ];
    final medications = await loadOptions(
      service.listMedications(pharmacyId: widget.pharmacyId),
      'Nao foi possivel carregar os produtos.',
    );
    if (pharmacies == null || medications == null || !mounted) return;

    await _showAdminDialog(
      context: context,
      title: item == null ? 'Novo item' : 'Editar item',
      child: _FormGrid(
        children: [
          _entityDropdown(
            label: 'Farmacia',
            value: pharmacyId,
            items: pharmacies,
            enabled: widget.pharmacyId == null,
            onChanged: (value) => pharmacyId = value,
          ),
          _entityDropdown(
            label: 'Produto',
            value: medicationId,
            items: medications,
            onChanged: (value) => medicationId = value,
          ),
          _input(
            price,
            'Preco',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
          ),
          _input(
            originalPrice,
            'Preco original',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
          ),
          _input(
            stock,
            'Estoque',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
      onSave: () => handle(() async {
        final parsedPrice = _toDouble(price.text);
        final parsedOriginalPrice = _toDouble(originalPrice.text);
        final parsedStock = int.tryParse(stock.text);
        final medicationMatches = medications
            .whereType<Map<String, dynamic>>()
            .any(
              (medication) =>
                  _asInt(medication['ID']) == medicationId &&
                  (_asInt(medication['PHARMACY_ID']) == null ||
                      _asInt(medication['PHARMACY_ID']) == pharmacyId),
            );
        if (pharmacyId == null ||
            medicationId == null ||
            !medicationMatches ||
            parsedPrice == null ||
            parsedPrice < 0 ||
            parsedOriginalPrice == null ||
            parsedOriginalPrice < parsedPrice ||
            parsedStock == null ||
            parsedStock < 0) {
          throw Exception(
            'Selecione farmacia e produto e informe preco e estoque validos.',
          );
        }
        await service.saveInventory({
          'PHARMACY_ID': pharmacyId,
          'MEDICATION_ID': medicationId,
          'PRICE': parsedPrice,
          'ORIGINAL_PRICE': parsedOriginalPrice,
          'STOCK': parsedStock,
        }, id: item?['ID'] as int?);
      }),
    );
  }
}
