part of '../admin_page.dart';

class _ContentPage extends _AdminListPage {
  const _ContentPage({required super.service});

  @override
  State<_ContentPage> createState() => _ContentPageState();
}

class _ContentPageState
    extends _AdminListPageState<_ContentPage, ContentBlock> {
  @override
  String get title => 'Conteúdo do app';

  @override
  String get subtitle =>
      'Edite banners, propagandas e chamadas exibidas para os clientes.';

  @override
  String get createLabel => 'Novo conteúdo';

  @override
  Future<List<ContentBlock>> fetch() => service.listContentBlocks();

  @override
  bool matches(ContentBlock item, String query) =>
      item.title.toLowerCase().contains(query) ||
      item.slug.toLowerCase().contains(query) ||
      item.subtitle.toLowerCase().contains(query);

  @override
  List<DataColumn> get columns => const [
    DataColumn(label: Text('Conteúdo')),
    DataColumn(label: Text('Posição')),
    DataColumn(label: Text('Imagem')),
    DataColumn(label: Text('Status')),
    DataColumn(label: Text('Ações')),
  ];

  @override
  DataRow buildRow(ContentBlock item) => DataRow(
    cells: [
      DataCell(_PrimaryCell(title: item.title, subtitle: item.slug)),
      DataCell(Text('${item.sortOrder}')),
      DataCell(_ContentThumbnail(imageUrl: item.image)),
      DataCell(_SmallChip(item.isActive ? 'Ativo' : 'Oculto')),
      DataCell(
        _RowActions(
          onEdit: () => _showDialog(item: item),
          onDelete: () => confirmDelete(
            itemLabel: 'o conteúdo ${item.title}',
            action: () => service.deleteContentBlock(item.id),
          ),
        ),
      ),
    ],
  );

  @override
  Widget buildMobileItem(ContentBlock item) => _CompactTile(
    title: item.title,
    leading: _ContentThumbnail(imageUrl: item.image),
    subtitle: '${item.slug} · posição ${item.sortOrder}',
    chips: [_SmallChip(item.isActive ? 'Ativo' : 'Oculto')],
    onEdit: () => _showDialog(item: item),
    onDelete: () => confirmDelete(
      itemLabel: 'o conteúdo ${item.title}',
      action: () => service.deleteContentBlock(item.id),
    ),
  );

  @override
  Future<void> onCreate() => _showDialog();

  Future<void> _showDialog({ContentBlock? item}) async {
    final slug = TextEditingController(text: item?.slug ?? 'home-destaque');
    final eyebrow = TextEditingController(text: item?.eyebrow ?? '');
    final title = TextEditingController(text: item?.title ?? '');
    final subtitle = TextEditingController(text: item?.subtitle ?? '');
    final body = TextEditingController(text: item?.body ?? '');
    final ctaLabel = TextEditingController(text: item?.ctaLabel ?? '');
    final ctaUrl = TextEditingController(text: item?.ctaUrl ?? '');
    final sortOrder = TextEditingController(text: '${item?.sortOrder ?? 0}');
    _SelectedAdminImage? selectedImage;
    var active = item?.isActive ?? true;
    var persistedId = item?.id;

    await _showAdminDialog(
      context: context,
      title: item == null ? 'Novo conteúdo' : 'Editar conteúdo',
      controllers: [
        slug,
        eyebrow,
        title,
        subtitle,
        body,
        ctaLabel,
        ctaUrl,
        sortOrder,
      ],
      child: StatefulBuilder(
        builder: (context, setDialogState) => _FormGrid(
          children: [
            _input(
              slug,
              'Identificador',
              helperText:
                  'Ex.: home-destaque-1. Use letras minúsculas e hifens.',
              validator: (value) {
                final normalized = value?.trim() ?? '';
                if (!RegExp(
                  r'^[a-z0-9][a-z0-9-]{1,119}$',
                ).hasMatch(normalized)) {
                  return 'Use letras minúsculas, números e hifens.';
                }
                return null;
              },
            ),
            _input(
              sortOrder,
              'Ordem de exibição',
              keyboardType: TextInputType.number,
              validator: (value) => int.tryParse(value ?? '') == null
                  ? 'Informe um número.'
                  : null,
            ),
            _input(eyebrow, 'Texto superior'),
            _input(
              title,
              'Título',
              validator: (value) =>
                  (value?.trim().isEmpty ?? true) ? 'Informe o título.' : null,
            ),
            _input(subtitle, 'Subtítulo'),
            _FullWidthFormField(
              child: _input(body, 'Texto de apoio', maxLines: 4),
            ),
            _input(ctaLabel, 'Texto do botão'),
            _input(ctaUrl, 'Link do botão'),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Publicar para clientes'),
              subtitle: const Text(
                'Conteúdos ocultos continuam disponíveis para edição.',
              ),
              value: active,
              onChanged: (value) => setDialogState(() => active = value),
            ),
            _FullWidthFormField(
              child: _AdminImagePicker(
                label: 'Imagem (PNG, JPEG ou WebP)',
                selectedFilename: selectedImage?.name,
                hasExistingImage: item?.image != null,
                existingImageUrl: item?.image,
                selectedBytes: selectedImage?.bytes,
                onSelected: (file) =>
                    setDialogState(() => selectedImage = file),
              ),
            ),
            if (selectedImage != null || item?.image != null)
              _FullWidthFormField(
                child: _EditorialCropPreview(
                  bytes: selectedImage?.bytes,
                  url: item?.image,
                ),
              ),
          ],
        ),
      ),
      onSave: () => handle(() async {
        persistedId = await service.saveContentBlock({
          'SLUG': slug.text.trim(),
          'EYEBROW': eyebrow.text.trim(),
          'TITLE': title.text.trim(),
          'SUBTITLE': subtitle.text.trim(),
          'BODY': body.text.trim(),
          'CTA_LABEL': ctaLabel.text.trim(),
          'CTA_URL': ctaUrl.text.trim(),
          'SORT_ORDER': int.tryParse(sortOrder.text.trim()) ?? 0,
          'IS_ACTIVE': active,
        }, id: persistedId);
        if (selectedImage != null && persistedId != null) {
          if (!hasCurrentAdminSession) return;
          await service.uploadContentImage(
            persistedId!,
            bytes: selectedImage!.bytes,
            filename: selectedImage!.name,
          );
        }
      }),
    );
  }
}

class _ContentThumbnail extends StatelessWidget {
  final String? imageUrl;

  const _ContentThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) return const _SmallChip('Sem imagem');
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        imageUrl!,
        width: 104,
        height: 60,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const SizedBox(
                width: 104,
                height: 60,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
        errorBuilder: (_, __, ___) => const _SmallChip('Erro'),
      ),
    );
  }
}

class _EditorialCropPreview extends StatefulWidget {
  final Uint8List? bytes;
  final String? url;
  const _EditorialCropPreview({this.bytes, this.url});

  @override
  State<_EditorialCropPreview> createState() => _EditorialCropPreviewState();
}

class _EditorialCropPreviewState extends State<_EditorialCropPreview> {
  bool mobile = true;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Recorte da imagem',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      SegmentedButton<bool>(
        segments: const [
          ButtonSegment(
            value: true,
            label: Text('Celular'),
            icon: Icon(Icons.smartphone),
          ),
          ButtonSegment(
            value: false,
            label: Text('Computador'),
            icon: Icon(Icons.desktop_windows_outlined),
          ),
        ],
        selected: {mobile},
        onSelectionChanged: (values) => setState(() => mobile = values.first),
      ),
      const SizedBox(height: 12),
      Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: mobile ? 320 : 640),
          child: AspectRatio(
            aspectRatio: mobile ? 1.35 : 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: widget.bytes != null
                  ? Image.memory(widget.bytes!, fit: BoxFit.cover)
                  : Image.network(
                      widget.url!,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
            ),
          ),
        ),
      ),
    ],
  );
}
