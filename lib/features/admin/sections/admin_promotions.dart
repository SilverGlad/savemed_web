part of '../admin_page.dart';

class _PromotionsPage extends _AdminListPage {
  const _PromotionsPage({required super.pharmacyId, required super.service});

  @override
  State<_PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState
    extends _AdminListPageState<_PromotionsPage, Promotion> {
  @override
  String get title => 'Promoções';

  @override
  String get subtitle =>
      'Descontos com período definido por produto e farmácia.';

  @override
  String get createLabel => 'Nova promoção';

  @override
  Future<List<Promotion>> fetch() =>
      service.listHighlights(pharmacyId: widget.pharmacyId);

  String _productName(Promotion item) => item.productName;

  String _pharmacyName(Promotion item) => item.pharmacyName;

  @override
  bool matches(Promotion item, String query) =>
      _productName(item).toLowerCase().contains(query) ||
      _pharmacyName(item).toLowerCase().contains(query) ||
      item.id.toString().contains(query);

  @override
  List<DataColumn> get columns => const [
    DataColumn(label: Text('Produto')),
    DataColumn(label: Text('Farmácia')),
    DataColumn(label: Text('Desconto')),
    DataColumn(label: Text('Período')),
    DataColumn(label: Text('Status')),
    DataColumn(label: Text('Ações')),
  ];

  @override
  DataRow buildRow(Promotion item) => DataRow(
    cells: [
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AdminThumbnail(imageUrl: item.image),
            const SizedBox(width: 10),
            _PrimaryCell(title: _productName(item), subtitle: 'ID ${item.id}'),
          ],
        ),
      ),
      DataCell(Text(_pharmacyName(item))),
      DataCell(Text('${item.discountPercentage}%')),
      DataCell(Text(_period(item))),
      DataCell(_SmallChip(_status(item))),
      DataCell(
        _RowActions(
          onEdit: () => _showDialog(item: item),
          onDelete: () => confirmDelete(
            itemLabel: 'a promoção de ${_productName(item)}',
            action: () => service.deleteHighlight(item.id),
          ),
        ),
      ),
    ],
  );

  @override
  Widget buildMobileItem(Promotion item) => _CompactTile(
    title: _productName(item),
    leading: _AdminThumbnail(imageUrl: item.image, size: 72),
    subtitle: '${item.discountPercentage}% - ${_period(item)}',
    chips: [_SmallChip(_status(item)), _SmallChip(_pharmacyName(item))],
    onEdit: () => _showDialog(item: item),
    onDelete: () => confirmDelete(
      itemLabel: 'a promoção de ${_productName(item)}',
      action: () => service.deleteHighlight(item.id),
    ),
  );

  String _formatDate(DateTime? value) => value == null
      ? '-'
      : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  String _period(Promotion item) =>
      '${_formatDate(item.startDate)} a ${_formatDate(item.endDate)}';

  String _status(Promotion item) {
    if (item.isScheduled) return 'Agendada';
    if (item.isEnded) return 'Encerrada';
    return 'Ativa';
  }

  @override
  Future<void> onCreate() => _showDialog();

  Future<void> _showDialog({Promotion? item}) async {
    var pharmacyId = item?.pharmacyId ?? widget.pharmacyId;
    var medicationId = item?.medicationId;
    var persistedId = item?.id;
    _SelectedAdminImage? selectedImage;
    var startDate = item?.startDate ?? DateTime.now();
    var endDate = item?.endDate ?? DateTime.now().add(const Duration(days: 7));
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
    final discount = TextEditingController(
      text: item?.discountPercentage.toString() ?? '',
    );

    await _showAdminDialog(
      context: context,
      title: item == null ? 'Nova promoção' : 'Editar promoção',
      controllers: [discount],
      child: StatefulBuilder(
        builder: (context, setDialogState) => _FormGrid(
          children: [
            _entityDropdown(
              label: 'Farmácia',
              value: pharmacyId,
              items: pharmacies,
              enabled: item == null && widget.pharmacyId == null,
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
              enabled: item == null && pharmacyId != null,
              validator: (value) =>
                  _requiredEntityValidator(value, 'o produto'),
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
              validator: (value) {
                final percentage = _toDouble(value ?? '');
                if (percentage == null || percentage <= 0 || percentage > 100) {
                  return 'Informe um desconto entre 0 e 100.';
                }
                return null;
              },
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text('Início: ${_formatDate(startDate)}'),
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
            _FullWidthFormField(
              child: _AdminImagePicker(
                label: 'Imagem da promoção (PNG, JPEG ou WebP)',
                selectedFilename: selectedImage?.name,
                hasExistingImage: item?.hasImage ?? false,
                existingImageUrl: item?.image,
                selectedBytes: selectedImage?.bytes,
                onSelected: (file) =>
                    setDialogState(() => selectedImage = file),
              ),
            ),
          ],
        ),
      ),
      onSave: () => handle(() async {
        final percentage = _toDouble(discount.text);
        final productMatches = medications.any(
          (product) =>
              product.id == medicationId &&
              (product.pharmacyId == null || product.pharmacyId == pharmacyId),
        );
        if (pharmacyId == null ||
            medicationId == null ||
            !productMatches ||
            percentage == null ||
            percentage <= 0 ||
            percentage > 100 ||
            endDate.isBefore(startDate)) {
          throw Exception(
            'Selecione um produto da farmácia, informe desconto entre 0 e 100 e um período válido.',
          );
        }
        persistedId = await service.saveHighlight({
          'PHARMACY_ID': pharmacyId,
          'MEDICATION_ID': medicationId,
          'DISCOUNT_PERCENTAGE': percentage,
          'START_DATE': startDate.toIso8601String(),
          'END_DATE': endDate.toIso8601String(),
        }, id: persistedId);
        final image = selectedImage;
        if (image != null) {
          if (!hasCurrentAdminSession) return;
          await service.uploadHighlightImage(
            persistedId!,
            bytes: image.bytes,
            filename: image.name,
          );
        }
      }),
    );
  }
}
