part of '../admin_page.dart';

abstract class _AdminListPage extends StatefulWidget {
  final int? pharmacyId;

  const _AdminListPage({this.pharmacyId});
}

abstract class _AdminListPageState<T extends _AdminListPage> extends State<T> {
  final AdminService service = AdminService();
  final TextEditingController search = TextEditingController();
  bool loading = true;
  String? error;
  List<dynamic> items = [];
  int page = 0;
  int _loadGeneration = 0;
  static const pageSize = 20;

  String get title;
  String get subtitle;
  String get createLabel => 'Novo';
  bool get canCreate => true;

  Future<List<dynamic>> fetch();
  Widget buildMobileItem(Map<String, dynamic> item);
  DataRow buildRow(Map<String, dynamic> item);
  List<DataColumn> get columns;
  bool matches(Map<String, dynamic> item, String query);
  Future<void> onCreate();

  @override
  void initState() {
    super.initState();
    search.addListener(() => setState(() => page = 0));
    reload();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> reload() async {
    final generation = ++_loadGeneration;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final loadedItems = await fetch();
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        items = loadedItems;
        loading = false;
      });
    } catch (e) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<bool> handle(Future<void> Function() action) async {
    try {
      await action();
      await reload();
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alteracao salva com sucesso.')),
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_cleanError(e))));
      return false;
    }
  }

  Future<void> confirmDelete({
    required String itemLabel,
    required Future<void> Function() action,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar exclusao'),
        content: Text(
          'Deseja excluir $itemLabel? Esta acao nao pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await handle(action);
  }

  Future<List<dynamic>?> loadOptions(
    Future<List<dynamic>> request,
    String errorMessage,
  ) async {
    try {
      return await request;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$errorMessage ${_cleanError(error)}')),
        );
      }
      return null;
    }
  }

  List<Map<String, dynamic>> get filteredItems {
    final query = search.text.trim().toLowerCase();
    return items
        .whereType<Map<String, dynamic>>()
        .where((item) => query.isEmpty || matches(item, query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = filteredItems;
    final pageCount = (data.length / pageSize).ceil();
    final currentPage = pageCount == 0 ? 0 : page.clamp(0, pageCount - 1);
    final start = currentPage * pageSize;
    final visibleData = data.skip(start).take(pageSize).toList();

    return _AdminPageFrame(
      title: title,
      subtitle: subtitle,
      actions: [
        OutlinedButton.icon(
          onPressed: loading ? null : reload,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Atualizar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _AdminColors.text,
            side: const BorderSide(color: _AdminColors.line),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        if (canCreate)
          FilledButton.icon(
            onPressed: loading ? null : onCreate,
            icon: const Icon(Icons.add, size: 18),
            label: Text(createLabel),
          ),
      ],
      child: Column(
        children: [
          _ToolbarSearch(controller: search),
          const SizedBox(height: 12),
          if (error != null) _InlineError(message: _cleanError(error!)),
          if (error != null) const SizedBox(height: 12),
          Expanded(
            child: loading
                ? const _LoadingPanel()
                : data.isEmpty
                ? const _EmptyPanel()
                : Column(
                    children: [
                      Expanded(
                        child: _ResponsiveDataView(
                          items: visibleData,
                          columns: columns,
                          buildRow: (item, index) =>
                              decorateRow(buildRow(item), start + index),
                          buildMobileItem: buildMobileItem,
                        ),
                      ),
                      if (pageCount > 1)
                        _PaginationBar(
                          currentPage: currentPage,
                          pageCount: pageCount,
                          totalItems: data.length,
                          onPrevious: currentPage > 0
                              ? () => setState(() => page = currentPage - 1)
                              : null,
                          onNext: currentPage < pageCount - 1
                              ? () => setState(() => page = currentPage + 1)
                              : null,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  bool textMatch(Map<String, dynamic> item, String query) {
    return item.values.any(
      (value) => value?.toString().toLowerCase().contains(query) ?? false,
    );
  }

  DataRow decorateRow(DataRow row, int index) {
    return DataRow(
      key: row.key,
      selected: row.selected,
      onSelectChanged: row.onSelectChanged,
      onLongPress: row.onLongPress,
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return AppColors.primary.withValues(alpha: 0.06);
        }
        return index.isEven ? Colors.white : const Color(0xFFFAFBFC);
      }),
      cells: row.cells,
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final int totalItems;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _PaginationBar({
    required this.currentPage,
    required this.pageCount,
    required this.totalItems,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$totalItems registros - Pagina ${currentPage + 1} de $pageCount',
            style: const TextStyle(color: _AdminColors.muted, fontSize: 12),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onPrevious,
            tooltip: 'Pagina anterior',
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: onNext,
            tooltip: 'Proxima pagina',
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _AdminPageFrame extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget child;

  const _AdminPageFrame({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _AdminColors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _AdminColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ToolbarSearch extends StatelessWidget {
  final TextEditingController controller;

  const _ToolbarSearch({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, size: 18),
          hintText: 'Buscar nesta secao',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _AdminColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _AdminColors.line),
          ),
        ),
      ),
    );
  }
}

class _ResponsiveDataView extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final List<DataColumn> columns;
  final DataRow Function(Map<String, dynamic>, int) buildRow;
  final Widget Function(Map<String, dynamic>) buildMobileItem;

  const _ResponsiveDataView({
    required this.items,
    required this.columns,
    required this.buildRow,
    required this.buildMobileItem,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => buildMobileItem(items[index]),
          );
        }

        return Container(
          width: double.infinity,
          decoration: _panelDecoration(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SingleChildScrollView(
              child: SizedBox(
                width: constraints.maxWidth,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      showCheckboxColumn: false,
                      showBottomBorder: true,
                      columnSpacing: 34,
                      horizontalMargin: 18,
                      dividerThickness: 0.8,
                      dataRowMinHeight: 58,
                      dataRowMaxHeight: 66,
                      headingRowHeight: 46,
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFF3F6F7),
                      ),
                      headingTextStyle: const TextStyle(
                        color: _AdminColors.muted,
                        fontSize: 12,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w900,
                      ),
                      dataTextStyle: const TextStyle(
                        color: _AdminColors.text,
                        fontSize: 13,
                      ),
                      columns: columns,
                      rows: [
                        for (var i = 0; i < items.length; i++)
                          buildRow(items[i], i),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
