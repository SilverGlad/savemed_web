part of '../admin_page.dart';

class _PharmacyUserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onReset;

  const _PharmacyUserTile({required this.user, required this.onReset});

  @override
  Widget build(BuildContext context) {
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
                  _str(user['NAME'], fallback: 'Usuario'),
                  style: const TextStyle(
                    color: _AdminColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${_str(user['EMAIL'], fallback: '-')} - ${_str(user['USER_ROLE'], fallback: '-')}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _AdminColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.lock_reset, size: 18),
            label: const Text('Resetar senha'),
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
  final VoidCallback? onDelete;
  final Widget? extra;

  const _CompactTile({
    required this.title,
    required this.subtitle,
    this.chips = const [],
    this.onEdit,
    this.onDelete,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: _panelDecoration(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _AdminColors.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _AdminColors.muted,
                      fontSize: 12,
                      height: 1.25,
                    ),
                  ),
                  if (chips.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(spacing: 6, runSpacing: 6, children: chips),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _RowActions(onEdit: onEdit, onDelete: onDelete, extra: extra),
          ],
        ),
      ),
    );
  }
}

class _RowActions extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget? extra;

  const _RowActions({this.onEdit, this.onDelete, this.extra});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            tooltip: 'Editar',
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3F6F7),
              foregroundColor: _AdminColors.text,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
        if (onDelete != null)
          OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Excluir'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: BorderSide(color: AppColors.danger.withValues(alpha: 0.35)),
              backgroundColor: AppColors.danger.withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        if (extra != null) extra!,
      ],
    );
  }
}

class _BoolChip extends StatelessWidget {
  final bool value;
  final String? label;

  const _BoolChip({required this.value, this.label});

  @override
  Widget build(BuildContext context) {
    return _SmallChip(
      label == null
          ? (value ? 'Sim' : 'Nao')
          : '$label: ${value ? 'Sim' : 'Nao'}',
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

  const _StatusChip({required this.label});

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
    return _SmallChip(label.isEmpty ? '-' : _statusLabel(label), color: color);
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
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
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

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      child: const Center(
        child: Text(
          'Nenhum registro encontrado.',
          style: TextStyle(color: _AdminColors.muted),
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

Widget _input(
  TextEditingController controller,
  String label, {
  bool obscureText = false,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
}) {
  return SizedBox(
    height: 48,
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
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
}) {
  final options = items
      .whereType<Map<String, dynamic>>()
      .where((item) => _asInt(item['ID']) != null)
      .toList();
  final ids = options
      .map((item) => _asInt(item['ID']))
      .whereType<int>()
      .toSet();
  final initialValue = ids.contains(value) ? value : null;

  return DropdownMenu<int>(
    initialSelection: initialValue,
    enabled: enabled,
    enableFilter: true,
    enableSearch: true,
    expandedInsets: EdgeInsets.zero,
    label: Text(label),
    dropdownMenuEntries: [
      if (optional) const DropdownMenuEntry<int>(value: -1, label: 'Nenhuma'),
      ...options.map((item) {
        final id = _asInt(item['ID'])!;
        return DropdownMenuEntry<int>(
          value: id,
          label: _str(item[nameKey], fallback: 'Registro #$id'),
        );
      }),
    ],
    onSelected: enabled
        ? (selected) => onChanged(selected == -1 ? null : selected)
        : null,
  );
}

Widget _stringDropdown({
  required String label,
  required String value,
  required List<String> values,
  required ValueChanged<String> onChanged,
}) {
  return DropdownButtonFormField<String>(
    initialValue: values.contains(value) ? value : null,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: label,
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
    items: values
        .map(
          (item) => DropdownMenuItem<String>(
            value: item,
            child: Text(_statusLabel(item)),
          ),
        )
        .toList(),
    onChanged: (selected) {
      if (selected != null) onChanged(selected);
    },
  );
}

Future<void> _showAdminDialog({
  required BuildContext context,
  required String title,
  required Widget child,
  required Future<bool> Function() onSave,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      var saving = false;
      return StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(title),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(child: child),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      setDialogState(() => saving = true);
                      final saved = await onSave();
                      if (!dialogContext.mounted) return;
                      if (saved) {
                        Navigator.pop(dialogContext);
                      } else {
                        setDialogState(() => saving = false);
                      }
                    },
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
    },
  );
}

String _str(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty || text == 'null' ? fallback : text;
}

String _id(Map<String, dynamic> item) =>
    'ID ${_str(item['ID'], fallback: '-')}';

String _addressLine(Map<String, dynamic> item) {
  final parts = [
    _str(item['CITY']),
    _str(item['STATE']),
    _str(item['ZIPCODE']),
  ].where((part) => part.isNotEmpty).toList();
  return parts.isEmpty ? '-' : parts.join(' - ');
}

double? _toDouble(String value) {
  return double.tryParse(value.trim().replaceAll(',', '.'));
}

int? _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

String _cleanError(Object error) {
  return error.toString().replaceFirst('Exception: ', '');
}

String _statusLabel(String value) {
  return OrderStatusRules.label(value);
}
