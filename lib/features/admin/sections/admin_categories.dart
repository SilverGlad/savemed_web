part of '../admin_page.dart';

class _CategoriesPage extends _AdminListPage {
  const _CategoriesPage({required super.pharmacyId, required super.service});

  @override
  State<_CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState
    extends _AdminListPageState<_CategoriesPage, Category> {
  Map<int, String> _pharmacyNames = const {};

  @override
  String get title => 'Categorias';

  @override
  String get subtitle => 'Organização do catálogo exibido pela farmácia.';

  @override
  String get createLabel => 'Nova categoria';

  @override
  Future<List<Category>> fetch() async {
    final categoriesFuture = service.listCategories(
      pharmacyId: widget.pharmacyId,
    );
    if (widget.pharmacyId != null) return categoriesFuture;
    final results = await Future.wait<Object>([
      categoriesFuture,
      service.listPharmacies().catchError((_) => <Pharmacy>[]),
    ]);
    _pharmacyNames = {
      for (final pharmacy in results[1] as List<Pharmacy>)
        pharmacy.id: pharmacy.name,
    };
    return results[0] as List<Category>;
  }

  String _pharmacyLabel(int? id) => id == null
      ? 'Todas as farmácias'
      : widget.pharmacyId == id
      ? 'Sua farmácia'
      : _pharmacyNames[id] ?? 'Farmácia #$id';

  @override
  bool matches(Category item, String query) =>
      item.name.toLowerCase().contains(query) ||
      (item.description?.toLowerCase().contains(query) ?? false);

  @override
  List<DataColumn> get columns => const [
    DataColumn(label: Text('Nome')),
    DataColumn(label: Text('Farmácia')),
    DataColumn(label: Text('Subcategorias')),
    DataColumn(label: Text('Ações')),
  ];

  @override
  DataRow buildRow(Category item) {
    final subs = item.subcategories;
    return DataRow(
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AdminThumbnail(imageUrl: item.image),
              const SizedBox(width: 10),
              _PrimaryCell(title: item.name, subtitle: 'ID ${item.id}'),
            ],
          ),
        ),
        DataCell(Text(_pharmacyLabel(item.pharmacyId))),
        DataCell(Text(subs.length.toString())),
        DataCell(
          _RowActions(
            onEdit: () => _showDialog(item: item),
            extra: IconButton(
              tooltip: 'Gerenciar subcategorias',
              onPressed: () => _manageSubcategories(item),
              icon: const Icon(Icons.account_tree_outlined),
            ),
            onDelete: () => confirmDelete(
              itemLabel: 'a categoria ${item.name}',
              action: () => service.deleteCategory(item.id),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildMobileItem(Category item) {
    final subs = item.subcategories;
    return _CompactTile(
      title: item.name,
      subtitle: _pharmacyLabel(item.pharmacyId),
      chips: [_SmallChip('${subs.length} subcategorias')],
      leading: _AdminThumbnail(imageUrl: item.image, size: 72),
      onEdit: () => _showDialog(item: item),
      extra: _AdminIconButton(
        tooltip: 'Gerenciar subcategorias',
        icon: Icons.account_tree_outlined,
        onPressed: () => _manageSubcategories(item),
      ),
      onDelete: () => confirmDelete(
        itemLabel: 'a categoria ${item.name}',
        action: () => service.deleteCategory(item.id),
      ),
    );
  }

  @override
  Future<void> onCreate() => _showDialog();

  Future<void> _manageSubcategories(Category category) async {
    final loaded = await loadOptions(
      service.listSubcategories(category.id),
      'Não foi possível carregar as subcategorias.',
    );
    if (loaded == null || !mounted) return;
    var subcategories = loaded;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Subcategorias de ${category.name}'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    onPressed: () async {
                      final name = await _editSubcategoryName();
                      if (name == null || !hasCurrentAdminSession) return;
                      try {
                        await service.saveSubcategory({
                          'CATEGORY_ID': category.id,
                          'NAME': name,
                        });
                        if (!hasCurrentAdminSession) return;
                        final refreshed = await service.listSubcategories(
                          category.id,
                        );
                        if (!context.mounted || !hasCurrentAdminSession) return;
                        setDialogState(() => subcategories = refreshed);
                      } catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_cleanError(error))),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar subcategoria'),
                  ),
                ),
                const SizedBox(height: 8),
                if (subcategories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('Ainda não há subcategorias nesta categoria.'),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: subcategories.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final subcategory = subcategories[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(subcategory.name),
                          trailing: Wrap(
                            children: [
                              IconButton(
                                tooltip: 'Editar subcategoria',
                                onPressed: () async {
                                  final name = await _editSubcategoryName(
                                    initialValue: subcategory.name,
                                  );
                                  if (name == null || !hasCurrentAdminSession) {
                                    return;
                                  }
                                  try {
                                    await service.saveSubcategory({
                                      'CATEGORY_ID': category.id,
                                      'NAME': name,
                                    }, id: subcategory.id);
                                    if (!hasCurrentAdminSession) return;
                                    final refreshed = await service
                                        .listSubcategories(category.id);
                                    if (!context.mounted ||
                                        !hasCurrentAdminSession) {
                                      return;
                                    }
                                    setDialogState(
                                      () => subcategories = refreshed,
                                    );
                                  } catch (error) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(_cleanError(error)),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Excluir subcategoria',
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (confirmContext) => AlertDialog(
                                      title: const Text(
                                        'Excluir subcategoria?',
                                      ),
                                      content: Text(
                                        'A subcategoria ${subcategory.name} será removida.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            confirmContext,
                                            false,
                                          ),
                                          child: const Text('Cancelar'),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.pop(
                                            confirmContext,
                                            true,
                                          ),
                                          child: const Text('Excluir'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed != true ||
                                      !hasCurrentAdminSession) {
                                    return;
                                  }
                                  try {
                                    await service.deleteSubcategory(
                                      subcategory.id,
                                    );
                                    if (!hasCurrentAdminSession) return;
                                    final refreshed = await service
                                        .listSubcategories(category.id);
                                    if (!context.mounted ||
                                        !hasCurrentAdminSession) {
                                      return;
                                    }
                                    setDialogState(
                                      () => subcategories = refreshed,
                                    );
                                  } catch (error) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(_cleanError(error)),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
    if (mounted) await reload();
  }

  Future<String?> _editSubcategoryName({String initialValue = ''}) async {
    final formKey = GlobalKey<FormState>();
    var name = initialValue;
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          initialValue.isEmpty ? 'Nova subcategoria' : 'Editar subcategoria',
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: initialValue,
            onChanged: (value) => name = value,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: (value) => _requiredTextValidator(value, 'o nome'),
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
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _showDialog({Category? item}) async {
    var pharmacyId = item?.pharmacyId ?? widget.pharmacyId;
    final pharmacies = widget.pharmacyId == null
        ? await loadOptions(
            service.listPharmacies(),
            'Não foi possível carregar as farmácias.',
          )
        : <Pharmacy>[Pharmacy(id: widget.pharmacyId!, name: 'Minha farmácia')];
    if (pharmacies == null || !mounted) return;
    final name = TextEditingController(text: item?.name ?? '');
    IconData? selectedIcon;
    var savedCategoryId = item?.id;
    await _showAdminDialog(
      context: context,
      title: item == null ? 'Nova categoria' : 'Editar categoria',
      controllers: [name],
      child: StatefulBuilder(
        builder: (context, setDialogState) => _FormGrid(
          children: [
            _input(
              name,
              'Nome',
              validator: (value) => _requiredTextValidator(value, 'o nome'),
            ),
            _entityDropdown(
              label: 'Farmácia',
              value: pharmacyId,
              items: pharmacies,
              enabled: widget.pharmacyId == null,
              validator: (value) =>
                  _requiredEntityValidator(value, 'a farmácia'),
              onChanged: (value) => pharmacyId = value,
            ),
            if (item?.image != null)
              _FullWidthFormField(
                child: Row(
                  children: [
                    _AdminThumbnail(imageUrl: item!.image, size: 72),
                    const SizedBox(width: 12),
                    const Text('Ícone atual'),
                  ],
                ),
              ),
            _FullWidthFormField(
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Ícone da categoria',
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categoryIcons.entries.map((entry) {
                    return Tooltip(
                      message: entry.key,
                      child: ChoiceChip(
                        selected: selectedIcon == entry.value,
                        label: SizedBox(
                          width: 54,
                          height: 54,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              entry.value,
                              size: 36,
                              semanticLabel: entry.key,
                            ),
                          ),
                        ),
                        onSelected: (_) =>
                            setDialogState(() => selectedIcon = entry.value),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      onSave: () => handle(() async {
        if (!isValidRequiredText(name.text) || pharmacyId == null) {
          throw Exception('Informe o nome e selecione a farmácia.');
        }
        savedCategoryId = await service.saveCategory({
          'NAME': name.text.trim(),
          'PHARMACY_ID': pharmacyId,
        }, id: savedCategoryId);
        if (!hasCurrentAdminSession) return;
        if (selectedIcon != null) {
          final bytes = await categoryIconPng(selectedIcon!);
          if (!hasCurrentAdminSession) return;
          await service.uploadCategoryImage(
            savedCategoryId!,
            bytes: bytes,
            filename: 'category-icon.png',
          );
        }
      }),
    );
  }
}
