part of '../admin_page.dart';

class _MedicationsPage extends _AdminListPage {
  const _MedicationsPage({required super.pharmacyId, required super.service});

  @override
  State<_MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState
    extends _AdminListPageState<_MedicationsPage, Medication> {
  Map<int, String> _pharmacyNames = const {};
  Map<int, String> _categoryNames = const {};

  @override
  String get title => 'Produtos';

  @override
  String get subtitle => 'Cadastro dos medicamentos e itens comercializados.';

  @override
  String get createLabel => 'Novo produto';

  @override
  Future<List<Medication>> fetch() async {
    final medicationsFuture = service.listMedications(
      pharmacyId: widget.pharmacyId,
    );
    if (widget.pharmacyId != null) {
      final categories = await service
          .listCategories(pharmacyId: widget.pharmacyId)
          .catchError((_) => <Category>[]);
      _categoryNames = {for (final item in categories) item.id: item.name};
      return medicationsFuture;
    }
    final results = await Future.wait<Object>([
      medicationsFuture,
      service.listCategories().catchError((_) => <Category>[]),
      service.listPharmacies().catchError((_) => <Pharmacy>[]),
    ]);
    _categoryNames = {
      for (final category in results[1] as List<Category>)
        category.id: category.name,
    };
    _pharmacyNames = {
      for (final pharmacy in results[2] as List<Pharmacy>)
        pharmacy.id: pharmacy.name,
    };
    return results[0] as List<Medication>;
  }

  String _pharmacyLabel(int? id) => id == null
      ? 'Sem farmácia'
      : widget.pharmacyId == id
      ? 'Sua farmácia'
      : _pharmacyNames[id] ?? 'Farmácia #$id';

  String _categoryLabel(int id) => _categoryNames[id] ?? 'Categoria #$id';

  String _productSubtitle(Medication item) => [
    item.brand,
    item.unit,
  ].whereType<String>().where((value) => value.isNotEmpty).join(' · ');

  @override
  bool matches(Medication item, String query) =>
      item.id.toString().contains(query) ||
      item.name.toLowerCase().contains(query) ||
      item.description.toLowerCase().contains(query) ||
      (item.brand?.toLowerCase().contains(query) ?? false) ||
      (item.unit?.toLowerCase().contains(query) ?? false) ||
      (item.eanCode?.toLowerCase().contains(query) ?? false) ||
      _categoryLabel(item.categoryId).toLowerCase().contains(query) ||
      _pharmacyLabel(item.pharmacyId).toLowerCase().contains(query) ||
      item.activeIngredients.any(
        (ingredient) => ingredient.name.toLowerCase().contains(query),
      );

  @override
  List<DataColumn> get columns => const [
    DataColumn(label: Text('Produto')),
    DataColumn(label: Text('Farmácia')),
    DataColumn(label: Text('Categoria')),
    DataColumn(label: Text('Ações')),
  ];

  @override
  DataRow buildRow(Medication item) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AdminThumbnail(imageUrl: item.image),
              const SizedBox(width: 10),
              _PrimaryCell(
                title: item.name,
                subtitle: _productSubtitle(item).isEmpty
                    ? 'ID ${item.id}'
                    : _productSubtitle(item),
              ),
            ],
          ),
        ),
        DataCell(Text(_pharmacyLabel(item.pharmacyId))),
        DataCell(Text(_categoryLabel(item.categoryId))),
        DataCell(
          _RowActions(
            onEdit: () => _showDialog(item: item),
            onDelete: () => confirmDelete(
              itemLabel: 'o produto ${item.name}',
              action: () => service.deleteMedication(item.id),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildMobileItem(Medication item) {
    return _CompactTile(
      title: item.name,
      subtitle: _productSubtitle(item).isEmpty
          ? 'ID ${item.id}'
          : _productSubtitle(item),
      chips: [
        _SmallChip(_pharmacyLabel(item.pharmacyId)),
        _SmallChip(_categoryLabel(item.categoryId)),
        for (final ingredient in item.activeIngredients.take(2))
          _SmallChip(ingredient.name),
        if (item.activeIngredients.length > 2)
          _SmallChip('+${item.activeIngredients.length - 2} princípios'),
        if (item.requiresPrescription)
          const _SmallChip('Exige receita', color: AppColors.danger),
      ],
      leading: _AdminThumbnail(imageUrl: item.image, size: 72),
      onEdit: () => _showDialog(item: item),
      onDelete: () => confirmDelete(
        itemLabel: 'o produto ${item.name}',
        action: () => service.deleteMedication(item.id),
      ),
    );
  }

  @override
  Future<void> onCreate() => _showDialog();

  Future<void> _showDialog({Medication? item}) async {
    var requiresRx = item?.requiresPrescription ?? false;
    var pharmacyId = item?.pharmacyId ?? widget.pharmacyId;
    var categoryId = item?.categoryId;
    var subcategoryId = item?.subcategoryId;
    var persistedId = item?.id;
    _SelectedAdminImage? selectedImage;
    final selectedIngredientIds =
        item?.activeIngredients.map((ingredient) => ingredient.id).toSet() ??
        <int>{};
    final pharmacies = widget.pharmacyId == null
        ? await loadOptions(
            service.listPharmacies(),
            'Não foi possível carregar as farmácias.',
          )
        : <Pharmacy>[Pharmacy(id: widget.pharmacyId!, name: 'Minha farmácia')];
    final categories = await loadOptions(
      service.listCategories(pharmacyId: widget.pharmacyId),
      'Não foi possível carregar as categorias.',
    );
    final loadedIngredients = await loadOptions(
      service.listActiveIngredients(pharmacyId: widget.pharmacyId),
      'Não foi possível carregar os princípios ativos.',
    );
    if (pharmacies == null ||
        categories == null ||
        loadedIngredients == null ||
        !mounted) {
      return;
    }
    var activeIngredients = loadedIngredients;
    final name = TextEditingController(text: item?.name ?? '');
    final description = TextEditingController(text: item?.description ?? '');
    final brand = TextEditingController(text: item?.brand ?? '');
    final unit = TextEditingController(text: item?.unit ?? '');
    final ean = TextEditingController(text: item?.eanCode ?? '');
    final subcategories = categories
        .expand((category) => category.subcategories)
        .toList();
    final savedSubcategoryId = item?.subcategoryId;
    final savedCategoryId = item?.categoryId;
    final hasInvalidSavedSubcategory =
        savedSubcategoryId != null &&
        !subcategories.any(
          (subcategory) =>
              subcategory.id == savedSubcategoryId &&
              (subcategory.categoryId == 0 ||
                  subcategory.categoryId == savedCategoryId),
        );
    if (hasInvalidSavedSubcategory) subcategoryId = null;

    await _showAdminDialog(
      context: context,
      title: item == null ? 'Novo produto' : 'Editar produto',
      controllers: [name, description, brand, unit, ean],
      child: StatefulBuilder(
        builder: (context, setDialogState) => _FormGrid(
          children: [
            _input(
              name,
              'Nome',
              validator: (value) => _requiredTextValidator(value, 'o nome'),
            ),
            _input(description, 'Descrição'),
            _input(brand, 'Marca'),
            _input(unit, 'Unidade (ex.: caixa, frasco)'),
            _input(
              ean,
              'Código de barras (EAN)',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                final eanValue = (value ?? '').trim();
                if (eanValue.isNotEmpty &&
                    (eanValue.length < 8 || eanValue.length > 14)) {
                  return 'Use entre 8 e 14 dígitos.';
                }
                return null;
              },
            ),
            _entityDropdown(
              label: 'Farmácia',
              value: pharmacyId,
              items: pharmacies,
              enabled: widget.pharmacyId == null,
              validator: (value) =>
                  _requiredEntityValidator(value, 'a farmácia'),
              onChanged: (value) => setDialogState(() {
                pharmacyId = value;
                categoryId = null;
                subcategoryId = null;
                selectedIngredientIds.clear();
              }),
            ),
            _entityDropdown(
              label: 'Categoria',
              value: categoryId,
              items: categories
                  .where(
                    (category) =>
                        pharmacyId != null &&
                        (category.pharmacyId == null ||
                            category.pharmacyId == pharmacyId),
                  )
                  .toList(),
              enabled: pharmacyId != null,
              validator: (value) =>
                  _requiredEntityValidator(value, 'a categoria'),
              onChanged: (value) => setDialogState(() {
                categoryId = value;
                subcategoryId = null;
              }),
            ),
            _entityDropdown(
              label: 'Subcategoria',
              value: subcategoryId,
              items: categories
                  .where((category) => category.id == categoryId)
                  .expand((category) => category.subcategories)
                  .toList(),
              enabled: categoryId != null,
              optional: true,
              onChanged: (value) => subcategoryId = value,
            ),
            if (hasInvalidSavedSubcategory)
              const _InfoPanel(
                icon: Icons.warning_amber_outlined,
                title: 'Subcategoria incompatível',
                body:
                    'O vínculo salvo não pertence à categoria deste produto. '
                    'Escolha uma subcategoria válida ou mantenha “Nenhuma” '
                    'para corrigir ao salvar.',
              ),
            _FullWidthFormField(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: _FormSectionHeading(
                          title: 'Princípios ativos',
                          description:
                              'Selecione os componentes deste produto ou cadastre um novo.',
                          icon: Icons.science_outlined,
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Cadastrar princípio ativo',
                        onPressed: pharmacyId == null
                            ? null
                            : () async {
                                final name = await _newActiveIngredientName();
                                if (name == null || !hasCurrentAdminSession) {
                                  return;
                                }
                                try {
                                  await service.saveActiveIngredient({
                                    'NAME': name,
                                    'PHARMACY_ID': pharmacyId,
                                  });
                                  if (!hasCurrentAdminSession) return;
                                  final refreshed = await service
                                      .listActiveIngredients(
                                        pharmacyId:
                                            widget.pharmacyId ?? pharmacyId,
                                      );
                                  if (!context.mounted ||
                                      !hasCurrentAdminSession) {
                                    return;
                                  }
                                  setDialogState(() {
                                    activeIngredients = refreshed;
                                    final added = refreshed.where(
                                      (ingredient) =>
                                          ingredient.name.toLowerCase() ==
                                              name.toLowerCase() &&
                                          ingredient.pharmacyId == pharmacyId,
                                    );
                                    if (added.isNotEmpty) {
                                      selectedIngredientIds.add(added.first.id);
                                    }
                                  });
                                } catch (error) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(_cleanError(error))),
                                  );
                                }
                              },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Selecione um ou mais',
                      border: OutlineInputBorder(),
                    ),
                    child:
                        activeIngredients
                            .where(
                              (ingredient) =>
                                  pharmacyId != null &&
                                  ingredient.pharmacyId == pharmacyId,
                            )
                            .isEmpty
                        ? const Text(
                            'Nenhum princípio ativo cadastrado. Use + para adicionar.',
                          )
                        : ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 160),
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: activeIngredients
                                    .where(
                                      (ingredient) =>
                                          pharmacyId != null &&
                                          ingredient.pharmacyId == pharmacyId,
                                    )
                                    .map((ingredient) {
                                      final id = ingredient.id;
                                      return FilterChip(
                                        label: Text(ingredient.name),
                                        selected: selectedIngredientIds
                                            .contains(id),
                                        onSelected: (selected) {
                                          setDialogState(() {
                                            if (selected) {
                                              selectedIngredientIds.add(id);
                                            } else {
                                              selectedIngredientIds.remove(id);
                                            }
                                          });
                                        },
                                      );
                                    })
                                    .toList(),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            _FullWidthFormField(
              child: _AdminImagePicker(
                label: 'Imagem do produto (PNG, JPEG ou WebP)',
                selectedFilename: selectedImage?.name,
                hasExistingImage: item?.image != null,
                existingImageUrl: item?.image,
                selectedBytes: selectedImage?.bytes,
                onSelected: (file) =>
                    setDialogState(() => selectedImage = file),
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Exige receita médica'),
              subtitle: const Text(
                'Ative quando a venda depender de prescrição.',
              ),
              value: requiresRx,
              onChanged: (value) => setDialogState(() => requiresRx = value),
            ),
          ],
        ),
      ),
      onSave: () => handle(() async {
        final categoryMatches = categories.any(
          (category) =>
              category.id == categoryId &&
              (category.pharmacyId == null ||
                  category.pharmacyId == pharmacyId),
        );
        final subcategoryMatches =
            subcategoryId == null ||
            subcategories.any(
              (subcategory) =>
                  subcategory.id == subcategoryId &&
                  (subcategory.categoryId == 0 ||
                      subcategory.categoryId == categoryId),
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
            'Informe nome, categoria e um EAN entre 8 e 14 dígitos, quando preenchido.',
          );
        }
        persistedId = await service.saveMedication({
          'NAME': name.text.trim(),
          'DESCRIPTION': description.text.trim(),
          'BRAND': brand.text.trim(),
          'UNIT': unit.text.trim(),
          'EAN_CODE': eanValue.isEmpty ? null : eanValue,
          'REQUIRES_RX': requiresRx,
          'PHARMACY_ID': pharmacyId,
          'CATEGORY_ID': categoryId,
          'SUBCATEGORY_ID': subcategoryId,
          'activeIngredientIds': selectedIngredientIds.toList()..sort(),
        }, id: persistedId);
        final image = selectedImage;
        if (image != null) {
          if (!hasCurrentAdminSession) return;
          await service.uploadMedicationImage(
            persistedId!,
            bytes: image.bytes,
            filename: image.name,
          );
        }
      }),
    );
  }

  Future<String?> _newActiveIngredientName() async {
    final formKey = GlobalKey<FormState>();
    var name = '';
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cadastrar princípio ativo'),
        content: Form(
          key: formKey,
          child: TextFormField(
            onChanged: (value) => name = value,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: (value) {
              final normalized = value?.trim() ?? '';
              return normalized.length < 2
                  ? 'Informe ao menos 2 caracteres.'
                  : null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, name.trim());
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    return result;
  }
}
