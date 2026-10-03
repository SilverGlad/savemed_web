part of '../admin_page.dart';

class _PharmacyUserTile extends StatelessWidget {
  final AppUser user;
  final VoidCallback onReset;
  final VoidCallback onResendInvitation;
  final VoidCallback onToggleStatus;

  const _PharmacyUserTile({
    required this.user,
    required this.onReset,
    required this.onResendInvitation,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = user.isActive;
    final invitationPending = user.mustChangePassword;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AdminColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: _AdminColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${user.email} - ${user.role.apiValue}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _AdminColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _SmallChip(
            invitationPending
                ? 'Convite pendente'
                : isActive
                ? 'Ativo'
                : 'Inativo',
            color: invitationPending
                ? const Color(0xFFB45309)
                : isActive
                ? AppColors.success
                : _AdminColors.muted,
          ),
          if (invitationPending)
            IconButton(
              tooltip: 'Reenviar convite',
              onPressed: onResendInvitation,
              icon: const Icon(Icons.forward_to_inbox_outlined),
            )
          else
            IconButton(
              tooltip: 'Redefinir senha',
              onPressed: onReset,
              icon: const Icon(Icons.lock_reset),
            ),
          IconButton(
            tooltip: isActive ? 'Inativar usuário' : 'Ativar usuário',
            onPressed: onToggleStatus,
            icon: Icon(
              isActive
                  ? Icons.person_off_outlined
                  : Icons.person_add_alt_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryCell extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PrimaryCell({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 260),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _AdminColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _AdminColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CompactTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> chips;
  final VoidCallback? onEdit;
  final String editLabel;
  final IconData editIcon;
  final VoidCallback? onDelete;
  final String deleteLabel;
  final IconData deleteIcon;
  final Widget? extra;
  final Widget? leading;

  const _CompactTile({
    required this.title,
    required this.subtitle,
    this.chips = const [],
    this.onEdit,
    this.editLabel = 'Editar',
    this.editIcon = Icons.edit_outlined,
    this.onDelete,
    this.deleteLabel = 'Excluir',
    this.deleteIcon = Icons.delete_outline,
    this.extra,
    this.leading,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: _panelDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _AdminColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _AdminColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: _RowActions(
            onEdit: onEdit,
            editLabel: editLabel,
            editIcon: editIcon,
            onDelete: onDelete,
            deleteLabel: deleteLabel,
            deleteIcon: deleteIcon,
            extra: extra,
          ),
        ),
      ],
    ),
  );
}

class _RowActions extends StatelessWidget {
  final VoidCallback? onEdit;
  final String editLabel;
  final IconData editIcon;
  final VoidCallback? onDelete;
  final String deleteLabel;
  final IconData deleteIcon;
  final Widget? extra;

  const _RowActions({
    this.onEdit,
    this.editLabel = 'Editar',
    this.editIcon = Icons.edit_outlined,
    this.onDelete,
    this.deleteLabel = 'Excluir',
    this.deleteIcon = Icons.delete_outline,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (onEdit != null)
          _AdminIconButton(
            icon: editIcon,
            tooltip: editLabel,
            onPressed: onEdit!,
          ),
        if (onDelete != null && deleteLabel == 'Inativar')
          OutlinedButton.icon(
            onPressed: onDelete!,
            icon: Icon(deleteIcon, size: 16),
            label: Text(deleteLabel),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: BorderSide(color: AppColors.danger.withValues(alpha: 0.35)),
              backgroundColor: const Color(0xFFFBECEE),
              minimumSize: const Size(48, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        if (onDelete != null && deleteLabel != 'Inativar')
          _AdminIconButton(
            icon: deleteIcon,
            tooltip: deleteLabel,
            onPressed: onDelete!,
            danger: true,
          ),
        if (extra != null) extra!,
      ],
    );
  }
}

class _AdminIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool danger;

  const _AdminIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    onPressed: onPressed,
    tooltip: tooltip,
    style: IconButton.styleFrom(
      fixedSize: const Size(48, 48),
      foregroundColor: danger ? AppColors.danger : _AdminColors.text,
      backgroundColor: danger
          ? const Color(0xFFFBECEE)
          : const Color(0xFFEAF1F0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    icon: Icon(icon, size: 18),
  );
}

class _BoolChip extends StatelessWidget {
  final bool value;
  final String? label;

  const _BoolChip({required this.value, this.label});

  @override
  Widget build(BuildContext context) {
    return _SmallChip(
      label == null
          ? (value ? 'Sim' : 'Não')
          : '$label: ${value ? 'Sim' : 'Não'}',
      color: value ? AppColors.success : _AdminColors.muted,
    );
  }
}

class _StockChip extends StatelessWidget {
  final int value;

  const _StockChip({required this.value});

  @override
  Widget build(BuildContext context) {
    return _SmallChip(
      '$value un.',
      color: value <= 5 ? AppColors.danger : AppColors.success,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String? prefix;

  const _StatusChip({required this.label, this.prefix});

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    final color =
        lower.contains('paid') ||
            lower.contains('complete') ||
            lower.contains('approved')
        ? AppColors.success
        : lower.contains('cancel') ||
              lower.contains('failed') ||
              lower.contains('refund')
        ? AppColors.danger
        : AppColors.primary;
    final status = label.isEmpty ? '-' : _statusLabel(label);
    return _SmallChip(
      prefix == null ? status : '$prefix: $status',
      color: color,
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallChip(this.label, {this.color = _AdminColors.muted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FormGrid extends StatelessWidget {
  final List<Widget> children;

  const _FormGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 560;
        final itemWidth = twoColumns
            ? (constraints.maxWidth - 10) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: children
              .map(
                (child) => SizedBox(
                  width: child is _FullWidthFormField
                      ? constraints.maxWidth
                      : itemWidth,
                  child: child is _FullWidthFormField ? child.child : child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _FullWidthFormField extends StatelessWidget {
  final Widget child;

  const _FullWidthFormField({required this.child});

  @override
  Widget build(BuildContext context) => child;
}

class _FormSectionHeading extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _FormSectionHeading({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _AdminColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminImagePicker extends StatelessWidget {
  final String label;
  final String? selectedFilename;
  final bool hasExistingImage;
  final String? existingImageUrl;
  final Uint8List? selectedBytes;
  final ValueChanged<_SelectedAdminImage> onSelected;

  const _AdminImagePicker({
    required this.label,
    required this.selectedFilename,
    required this.hasExistingImage,
    this.existingImageUrl,
    this.selectedBytes,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final status =
        selectedFilename ??
        (hasExistingImage
            ? 'Imagem atual cadastrada'
            : 'Nenhuma imagem selecionada');
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedBytes != null || existingImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: selectedBytes != null
                    ? Image.memory(
                        selectedBytes!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_outlined, size: 32),
                        ),
                      )
                    : Image.network(
                        existingImageUrl!,
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_outlined, size: 32),
                        ),
                      ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.image_outlined),
              const SizedBox(width: 10),
              Expanded(child: Text(status)),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: () => _pick(context),
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(
                hasExistingImage || selectedFilename != null
                    ? 'Trocar'
                    : 'Selecionar',
              ),
            ),
          ),
          if (selectedBytes != null || existingImageUrl != null)
            TextButton.icon(
              onPressed: () => _showImagePreview(
                context,
                url: existingImageUrl,
                bytes: selectedBytes,
              ),
              icon: const Icon(Icons.zoom_in),
              label: const Text('Ampliar imagem'),
            ),
        ],
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
        allowMultiple: false,
        withData: false,
        withReadStream: true,
      );
      if (result == null || result.files.isEmpty || !context.mounted) return;
      final file = result.files.single;
      const maxImageBytes = 5 * 1024 * 1024;
      void showSizeLimitError() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A imagem deve ter no máximo 5 MB.')),
        );
      }

      if (file.size > maxImageBytes) {
        showSizeLimitError();
        return;
      }
      final stream = file.readStream;
      if (stream == null) {
        throw Exception('Conteúdo da imagem indisponível.');
      }

      final buffer = BytesBuilder(copy: false);
      var bytesRead = 0;
      await for (final chunk in stream) {
        if (!context.mounted) return;
        bytesRead += chunk.length;
        if (bytesRead > maxImageBytes) {
          if (context.mounted) showSizeLimitError();
          return;
        }
        buffer.add(chunk);
      }

      if (!context.mounted) return;
      final bytes = buffer.takeBytes();
      if (bytes.isEmpty) {
        throw Exception('Conteúdo da imagem indisponível.');
      }
      onSelected(_SelectedAdminImage(name: file.name, bytes: bytes));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_cleanError(error))));
    }
  }
}

class _AdminThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const _AdminThumbnail({required this.imageUrl, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Ampliar imagem',
      child: InkWell(
        onTap: imageUrl == null
            ? null
            : () => _showImagePreview(context, url: imageUrl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: size,
            height: size,
            color: const Color(0xFFF1F5F5),
            child: imageUrl == null
                ? const Icon(Icons.image_not_supported_outlined, size: 20)
                : Image.network(
                    imageUrl!,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image_outlined, size: 20),
                  ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showImagePreview(
  BuildContext context, {
  String? url,
  Uint8List? bytes,
}) => showDialog<void>(
  context: context,
  builder: (context) => Dialog(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 800,
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Fechar imagem',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ),
          Flexible(
            child: InteractiveViewer(
              child: bytes != null
                  ? Image.memory(
                      bytes,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Não foi possível carregar a imagem.'),
                      ),
                    )
                  : Image.network(
                      url!,
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                      errorBuilder: (_, __, ___) => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Não foi possível carregar a imagem.'),
                      ),
                    ),
            ),
          ),
        ],
      ),
    ),
  ),
);

class _SelectedAdminImage {
  final String name;
  final Uint8List bytes;

  const _SelectedAdminImage({required this.name, required this.bytes});
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _AdminColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: _AdminColors.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.danger,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _LoadErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                color: AppColors.danger,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _AdminColors.text),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyPanel({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inbox_outlined,
                color: _AdminColors.muted,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _AdminColors.muted),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: _AdminColors.line),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.025),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

String? _requiredTextValidator(String? value, String label) {
  if (!isValidRequiredText(value ?? '')) return 'Informe $label.';
  return null;
}

String? _emailValidator(String? value) {
  if (!isValidEmail(value ?? '')) return 'Informe um e-mail válido.';
  return null;
}

String? _phoneValidator(String? value, {bool optional = false}) {
  final text = value ?? '';
  if (optional && text.trim().isEmpty) return null;
  if (!isValidPhone(text)) return 'Informe um telefone válido com DDD.';
  return null;
}

String? _cnpjValidator(String? value) {
  if (!isValidCNPJ(value ?? '')) return 'Informe um CNPJ válido.';
  return null;
}

String? _cepValidator(String? value) {
  if (digitsOnly(value ?? '').length != 8) return 'Informe um CEP válido.';
  return null;
}

String? _ufValidator(String? value) {
  if ((value ?? '').trim().length != 2) return 'Informe uma UF válida.';
  return null;
}

String? _requiredEntityValidator(int? value, String label) {
  if (value == null) return 'Selecione $label.';
  return null;
}

String? _nonNegativeNumberValidator(String? value, String label) {
  final number = _toDouble(value ?? '');
  if (number == null || number < 0) return 'Informe $label válido.';
  return null;
}

String? _positiveNumberValidator(String? value, String label) {
  final number = _toDouble(value ?? '');
  if (number == null || number <= 0) return 'Informe $label maior que zero.';
  return null;
}

Widget _input(
  TextEditingController controller,
  String label, {
  bool obscureText = false,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  String? Function(String?)? validator,
  Widget? suffixIcon,
  bool enabled = true,
  String? helperText,
  int? maxLines,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    validator: validator,
    enabled: enabled,
    maxLines: maxLines ?? 1,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      helperText: helperText,
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

Widget _entityDropdown({
  required String label,
  required int? value,
  required List<dynamic> items,
  required ValueChanged<int?> onChanged,
  String nameKey = 'NAME',
  bool enabled = true,
  bool optional = false,
  String? Function(int?)? validator,
}) {
  final options = items
      .map((item) {
        if (item is Pharmacy) return (id: item.id, label: item.name);
        if (item is Category) return (id: item.id, label: item.name);
        if (item is Subcategory) return (id: item.id, label: item.name);
        if (item is Medication) return (id: item.id, label: item.name);
        if (item is Map<String, dynamic>) {
          final id = _asInt(item['ID']);
          if (id != null) {
            return (
              id: id,
              label: _str(item[nameKey], fallback: 'Registro #$id'),
            );
          }
        }
        return null;
      })
      .whereType<({int id, String label})>()
      .toList();
  final ids = options.map((item) => item.id).toSet();
  final initialValue = ids.contains(value) ? value : null;

  return FormField<int>(
    key: ValueKey((label, initialValue, Object.hashAll(ids))),
    initialValue: initialValue,
    validator: validator,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    builder: (field) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownMenu<int>(
          initialSelection: initialValue,
          enabled: enabled,
          enableFilter: true,
          enableSearch: true,
          expandedInsets: EdgeInsets.zero,
          label: Text(label),
          errorText: field.errorText,
          dropdownMenuEntries: [
            if (optional)
              const DropdownMenuEntry<int>(value: -1, label: 'Nenhuma'),
            ...options.map((item) {
              return DropdownMenuEntry<int>(value: item.id, label: item.label);
            }),
          ],
          onSelected: enabled
              ? (selected) {
                  final value = selected == -1 ? null : selected;
                  field.didChange(value);
                  onChanged(value);
                }
              : null,
        ),
      ],
    ),
  );
}

Future<void> _showAdminDialog({
  required BuildContext context,
  required String title,
  required Widget child,
  required Future<bool> Function() onSave,
  List<TextEditingController> controllers = const [],
}) async {
  final sessionScope = _adminScope(context.read<AuthController>().user);
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _AdminFormDialog(
      sessionScope: sessionScope,
      title: title,
      onSave: onSave,
      controllers: controllers,
      child: child,
    ),
  );
}

class _AdminFormDialog extends StatefulWidget {
  final Object sessionScope;
  final String title;
  final Widget child;
  final Future<bool> Function() onSave;
  final List<TextEditingController> controllers;

  const _AdminFormDialog({
    required this.sessionScope,
    required this.title,
    required this.child,
    required this.onSave,
    required this.controllers,
  });

  @override
  State<_AdminFormDialog> createState() => _AdminFormDialogState();
}

class _AdminFormDialogState extends State<_AdminFormDialog> {
  final formKey = GlobalKey<FormState>();
  bool saving = false;
  String? saveError;

  @override
  void dispose() {
    for (final controller in widget.controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (saving) return;
    if (_adminScope(context.read<AuthController>().user) !=
        widget.sessionScope) {
      return;
    }
    if (!(formKey.currentState?.validate() ?? true)) return;
    setState(() {
      saving = true;
      saveError = null;
    });
    bool saved;
    try {
      saved = await widget.onSave();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        saving = false;
        saveError = _cleanError(error);
      });
      return;
    }
    if (!mounted) return;
    if (_adminScope(context.read<AuthController>().user) !=
        widget.sessionScope) {
      setState(() => saving = false);
      return;
    }
    if (saved) {
      Navigator.pop(context);
    } else {
      setState(() {
        saving = false;
        saveError =
            'Não foi possível concluir o salvamento. Seus dados foram mantidos. Confira os dados e tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentScope = _adminScope(context.watch<AuthController>().user);
    if (currentScope != widget.sessionScope) {
      return PopScope(
        canPop: !saving,
        child: AlertDialog(
          title: const Text('Sessão alterada'),
          content: Text(
            saving
                ? 'A sessão mudou durante o salvamento. Aguarde a conclusão e consulte o registro na conta original.'
                : 'Este formulário pertence à sessão anterior. Feche e abra o cadastro novamente na conta atual.',
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    }
    final dialogWidth = (MediaQuery.sizeOf(context).width - 64)
        .clamp(0.0, 640.0)
        .toDouble();
    return PopScope(
      canPop: !saving,
      child: AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: const Color(0xFFFDFEFE),
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        content: SizedBox(
          width: dialogWidth,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  (MediaQuery.sizeOf(context).height -
                          MediaQuery.viewInsetsOf(context).bottom -
                          200)
                      .clamp(100, 700),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Form(key: formKey, child: widget.child),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
        actions: [
          if (saveError != null)
            SizedBox(
              width: double.infinity,
              child: Semantics(
                liveRegion: true,
                child: Text(
                  saveError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          TextButton(
            onPressed: saving ? null : () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: saving ? null : save,
            child: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

String _str(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty || text == 'null' ? fallback : text;
}

double? _toDouble(String value) {
  return parseLocalizedNumber(value);
}

int? _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

String _cleanError(Object error) {
  return ApiErrorMessage.forUser(
    error,
    fallback: 'Não foi possível concluir a operação. Tente novamente.',
  );
}

String _statusLabel(String value) {
  return OrderStatusRules.label(value);
}
