part of '../admin_page.dart';

class _InventoryPage extends _AdminListPage {
  const _InventoryPage({required super.pharmacyId, required super.service});

  @override
  State<_InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState
    extends _AdminListPageState<_InventoryPage, AdminInventoryItem> {
  Map<int, String> _pharmacyNames = const {};

  @override
  String get title => widget.pharmacyId == null ? 'Inventário' : 'Estoque';

  @override
  String get subtitle => 'Preço, disponibilidade e estoque por farmácia.';

  @override
  String get createLabel => 'Novo item';

  @override
  Future<List<AdminInventoryItem>> fetch() async {
    final inventoryFuture = service.listInventory(
      pharmacyId: widget.pharmacyId,
    );
    if (widget.pharmacyId != null) return inventoryFuture;
    final results = await Future.wait<Object>([
      inventoryFuture,
      service.listPharmacies().catchError((_) => <Pharmacy>[]),
    ]);
    _pharmacyNames = {
      for (final pharmacy in results[1] as List<Pharmacy>)
        pharmacy.id: pharmacy.name,
    };
    return results[0] as List<AdminInventoryItem>;
  }

  String _pharmacyLabel(int id) => widget.pharmacyId == id
      ? 'Sua farmácia'
      : _pharmacyNames[id] ?? 'Farmácia #$id';

  @override
  bool matches(AdminInventoryItem item, String query) =>
      item.medicationName.toLowerCase().contains(query) ||
      item.medicationId.toString().contains(query) ||
      item.pharmacyId.toString().contains(query);

  @override
  List<DataColumn> get columns => const [
    DataColumn(label: Text('Item')),
    DataColumn(label: Text('Farmácia')),
    DataColumn(label: Text('Preço')),
    DataColumn(label: Text('Unidade')),
    DataColumn(label: Text('Estoque')),
    DataColumn(label: Text('Atualizado')),
    DataColumn(label: Text('Ações')),
  ];

  @override
  DataRow buildRow(AdminInventoryItem item) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AdminThumbnail(imageUrl: item.image),
              const SizedBox(width: 10),
              _PrimaryCell(
                title: item.medicationName,
                subtitle: 'Med ${item.medicationId}',
              ),
            ],
          ),
        ),
        DataCell(Text(_pharmacyLabel(item.pharmacyId))),
        DataCell(Text(formatBrl(item.price))),
        DataCell(Text(item.unit ?? '-')),
        DataCell(_StockChip(value: item.stock)),
        DataCell(Text(_lastUpdated(item))),
        DataCell(
          _RowActions(
            onEdit: () => _showDialog(item: item),
            onDelete: () => confirmDelete(
              itemLabel: 'este item do estoque',
              action: () => service.deleteInventory(item.id),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildMobileItem(AdminInventoryItem item) {
    return _CompactTile(
      title: item.medicationName,
      subtitle: formatBrl(item.price),
      leading: _AdminThumbnail(imageUrl: item.image, size: 72),
      chips: [
        _StockChip(value: item.stock),
        _SmallChip(item.unit ?? 'Unidade não informada'),
        _SmallChip('Atualizado ${_lastUpdated(item)}'),
        _SmallChip(_pharmacyLabel(item.pharmacyId)),
      ],
      onEdit: () => _showDialog(item: item),
      onDelete: () => confirmDelete(
        itemLabel: 'este item do estoque',
        action: () => service.deleteInventory(item.id),
      ),
    );
  }

  @override
  Future<void> onCreate() => _showDialog();

  String _lastUpdated(AdminInventoryItem item) {
    final value = item.updatedAt?.toLocal();
    if (value == null) return '-';
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }

  Future<void> _showDialog({AdminInventoryItem? item}) async {
    var pharmacyId = item?.pharmacyId ?? widget.pharmacyId;
    var medicationId = item?.medicationId;
    final pharmacies = widget.pharmacyId == null
        ? await loadOptions(
            service.listPharmacies(),
            'Não foi possível carregar as farmácias.',
          )
        : <Pharmacy>[Pharmacy(id: widget.pharmacyId!, name: 'Minha farmácia')];
    final medications = await loadOptions(
      service.listMedications(pharmacyId: widget.pharmacyId),
      'Não foi possível carregar os produtos.',
    );
    if (pharmacies == null || medications == null || !mounted) return;
    final price = TextEditingController(text: item?.price.toString() ?? '');
    final originalPrice = TextEditingController(
      text: item?.originalPrice.toString() ?? '',
    );
    final stock = TextEditingController(text: item?.stock.toString() ?? '');

    await _showAdminDialog(
      context: context,
      title: item == null ? 'Novo item' : 'Editar item',
      controllers: [price, originalPrice, stock],
      child: StatefulBuilder(
        builder: (context, setDialogState) => _FormGrid(
          children: [
            _entityDropdown(
              label: 'Farmácia',
              value: pharmacyId,
              items: pharmacies,
              enabled: widget.pharmacyId == null,
              validator: (value) =>
                  _requiredEntityValidator(value, 'a farmácia'),
              onChanged: (value) => setDialogState(() {
                pharmacyId = value;
                medicationId = null;
              }),
            ),
            _entityDropdown(
              label: 'Produto',
              value: medicationId,
              items: medications
                  .where(
                    (medication) =>
                        pharmacyId != null &&
                        (medication.pharmacyId == null ||
                            medication.pharmacyId == pharmacyId),
                  )
                  .toList(),
              enabled: pharmacyId != null,
              validator: (value) =>
                  _requiredEntityValidator(value, 'o produto'),
              onChanged: (value) => medicationId = value,
            ),
            _input(
              price,
              'Preço',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
              validator: (value) =>
                  _nonNegativeNumberValidator(value, 'um preço'),
            ),
            _input(
              originalPrice,
              'Preço original',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
              validator: (value) {
                final original = _toDouble(value ?? '');
                final current = _toDouble(price.text);
                if (original == null || original < 0) {
                  return 'Informe um preço original válido.';
                }
                if (current != null && original < current) {
                  return 'Deve ser igual ou maior que o preço atual.';
                }
                return null;
              },
            ),
            _input(
              stock,
              'Estoque',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                final parsed = int.tryParse(value ?? '');
                if (parsed == null || parsed < 0) {
                  return 'Informe um estoque válido.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      onSave: () => handle(() async {
        final parsedPrice = _toDouble(price.text);
        final parsedOriginalPrice = _toDouble(originalPrice.text);
        final parsedStock = int.tryParse(stock.text);
        final medicationMatches = medications.any(
          (medication) =>
              medication.id == medicationId &&
              (medication.pharmacyId == null ||
                  medication.pharmacyId == pharmacyId),
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
            'Selecione farmácia e produto e informe preço e estoque válidos.',
          );
        }
        await service.saveInventory({
          'PHARMACY_ID': pharmacyId,
          'MEDICATION_ID': medicationId,
          'PRICE': parsedPrice,
          'ORIGINAL_PRICE': parsedOriginalPrice,
          'STOCK': parsedStock,
        }, id: item?.id);
      }),
    );
  }
}
