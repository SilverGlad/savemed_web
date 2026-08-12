part of '../admin_page.dart';

class _PromotionsPage extends _AdminListPage {
  const _PromotionsPage({required super.pharmacyId});

  @override
  State<_PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends _AdminListPageState<_PromotionsPage> {
  @override
  String get title => 'Promocoes';

  @override
  String get subtitle =>
      'Descontos com periodo definido por produto e farmacia.';

  @override
  String get createLabel => 'Nova promocao';

  @override
  Future<List<dynamic>> fetch() =>
      service.listHighlights(pharmacyId: widget.pharmacyId);

  String _productName(Map<String, dynamic> item) {
    final product = (item['Medication'] ?? item['medication']) as Map?;
    return _str(
      product?['NAME'],
      fallback: 'Produto #${_str(item['MEDICATION_ID'])}',
    );
  }

  String _pharmacyName(Map<String, dynamic> item) {
    final pharmacy = (item['Pharmacy'] ?? item['pharmacy']) as Map?;
    return _str(
      pharmacy?['NAME'],
      fallback: 'Farmacia #${_str(item['PHARMACY_ID'])}',
    );
  }

  @override
  bool matches(Map<String, dynamic> item, String query) =>
      textMatch(item, query) ||
      _productName(item).toLowerCase().contains(query) ||
      _pharmacyName(item).toLowerCase().contains(query);

  @override
  List<DataColumn> get columns => const [
    DataColumn(label: Text('Produto')),
    DataColumn(label: Text('Farmacia')),
    DataColumn(label: Text('Desconto')),
    DataColumn(label: Text('Periodo')),
    DataColumn(label: Text('Status')),
    DataColumn(label: Text('Acoes')),
  ];

  @override
  DataRow buildRow(Map<String, dynamic> item) => DataRow(
    cells: [
      DataCell(_PrimaryCell(title: _productName(item), subtitle: _id(item))),
      DataCell(Text(_pharmacyName(item))),
      DataCell(Text('${_str(item['DISCOUNT_PERCENTAGE'], fallback: '0')}%')),
      DataCell(Text(_period(item))),
      DataCell(_SmallChip(_status(item))),
      DataCell(
        _RowActions(
          onEdit: () => _showDialog(item: item),
          onDelete: () => confirmDelete(
            itemLabel: 'a promocao de ${_productName(item)}',
            action: () => service.deleteHighlight(item['ID'] as int),
          ),
        ),
      ),
    ],
  );

  @override
  Widget buildMobileItem(Map<String, dynamic> item) => _CompactTile(
    title: _productName(item),
    subtitle:
        '${_str(item['DISCOUNT_PERCENTAGE'], fallback: '0')}% - ${_period(item)}',
    chips: [_SmallChip(_status(item)), _SmallChip(_pharmacyName(item))],
    onEdit: () => _showDialog(item: item),
    onDelete: () => confirmDelete(
      itemLabel: 'a promocao de ${_productName(item)}',
      action: () => service.deleteHighlight(item['ID'] as int),
    ),
  );

  DateTime? _date(Object? value) => DateTime.tryParse(value?.toString() ?? '');

  String _formatDate(DateTime? value) => value == null
      ? '-'
      : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  String _period(Map<String, dynamic> item) =>
      '${_formatDate(_date(item['START_DATE']))} a ${_formatDate(_date(item['END_DATE']))}';

  String _status(Map<String, dynamic> item) {
    final now = DateTime.now();
    final start = _date(item['START_DATE']);
    final end = _date(item['END_DATE']);
    if (start != null && now.isBefore(start)) return 'Agendada';
    if (end != null && now.isAfter(end.add(const Duration(days: 1)))) {
      return 'Encerrada';
    }
    return 'Ativa';
  }

  @override
  Future<void> onCreate() => _showDialog();

  Future<void> _showDialog({Map<String, dynamic>? item}) async {
    var pharmacyId = _asInt(item?['PHARMACY_ID']) ?? widget.pharmacyId;
    var medicationId = _asInt(item?['MEDICATION_ID']);
    var startDate = _date(item?['START_DATE']) ?? DateTime.now();
    var endDate =
        _date(item?['END_DATE']) ?? DateTime.now().add(const Duration(days: 7));
    final discount = TextEditingController(
      text: _str(item?['DISCOUNT_PERCENTAGE']),
    );
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
      title: item == null ? 'Nova promocao' : 'Editar promocao',
      child: StatefulBuilder(
        builder: (context, setDialogState) => _FormGrid(
          children: [
            _entityDropdown(
              label: 'Farmacia',
              value: pharmacyId,
              items: pharmacies,
              enabled: item == null && widget.pharmacyId == null,
              onChanged: (value) => pharmacyId = value,
            ),
            _entityDropdown(
              label: 'Produto',
              value: medicationId,
              items: medications,
              enabled: item == null,
              onChanged: (value) => medicationId = value,
            ),
            _input(
              discount,
              'Desconto (%)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text('Inicio: ${_formatDate(startDate)}'),
              onPressed: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (selected != null) {
                  setDialogState(() => startDate = selected);
                }
              },
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.event_outlined),
              label: Text('Fim: ${_formatDate(endDate)}'),
              onPressed: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: endDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (selected != null) setDialogState(() => endDate = selected);
              },
            ),
          ],
        ),
      ),
      onSave: () => handle(() async {
        final percentage = _toDouble(discount.text);
        final productMatches = medications
            .whereType<Map<String, dynamic>>()
            .any(
              (product) =>
                  _asInt(product['ID']) == medicationId &&
                  (_asInt(product['PHARMACY_ID']) == null ||
                      _asInt(product['PHARMACY_ID']) == pharmacyId),
            );
        if (pharmacyId == null ||
            medicationId == null ||
            !productMatches ||
            percentage == null ||
            percentage <= 0 ||
            percentage > 100 ||
            endDate.isBefore(startDate)) {
          throw Exception(
            'Selecione um produto da farmacia, informe desconto entre 0 e 100 e um periodo valido.',
          );
        }
        await service.saveHighlight({
          'PHARMACY_ID': pharmacyId,
          'MEDICATION_ID': medicationId,
          'DISCOUNT_PERCENTAGE': percentage,
          'START_DATE': startDate.toIso8601String(),
          'END_DATE': endDate.toIso8601String(),
        }, id: item?['ID'] as int?);
      }),
    );
  }
}
