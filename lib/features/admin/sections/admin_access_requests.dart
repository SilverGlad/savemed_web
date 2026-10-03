part of '../admin_page.dart';

class _AccessRequestsPage extends StatefulWidget {
  final AdminService service;

  const _AccessRequestsPage({required this.service});

  @override
  State<_AccessRequestsPage> createState() => _AccessRequestsPageState();
}

class _AccessRequestsPageState extends State<_AccessRequestsPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _horizontalScrollController = ScrollController();
  late Future<List<PharmacyAccessRequestSummary>> _requests;
  late Future<List<Pharmacy>> _pharmacies;
  PharmacyAccessRequestStatus? _status = PharmacyAccessRequestStatus.pending;
  int? _pharmacyId;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _requests = _load();
    _pharmacies = widget.service.listPharmacies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<List<PharmacyAccessRequestSummary>> _load() {
    final endOfDay = _to == null
        ? null
        : DateTime(_to!.year, _to!.month, _to!.day, 23, 59, 59, 999);
    return widget.service.listAccessRequests(
      query: _searchController.text,
      status: _status,
      pharmacyId: _pharmacyId,
      from: _from,
      to: endOfDay,
    );
  }

  void _reload() => setState(() => _requests = _load());

  @override
  Widget build(BuildContext context) {
    return _AdminPageFrame(
      title: 'Solicitações de acesso',
      subtitle:
          'Confira o responsável antes de liberar acesso administrativo a uma farmácia.',
      actions: [
        IconButton(
          onPressed: _reload,
          tooltip: 'Atualizar solicitações',
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: Column(
        children: [
          _filters(),
          const SizedBox(height: 14),
          Expanded(
            child: FutureBuilder<List<PharmacyAccessRequestSummary>>(
              future: _requests,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: _LoadErrorPanel(
                      message: _cleanError(snapshot.error!),
                      onRetry: _reload,
                    ),
                  );
                }
                final requests = snapshot.data ?? const [];
                if (requests.isEmpty) {
                  return const Center(
                    child: _InfoPanel(
                      icon: Icons.inbox_outlined,
                      title: 'Nenhuma solicitação encontrada',
                      body:
                          'Ajuste os filtros ou aguarde uma nova solicitação.',
                    ),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) => constraints.maxWidth >= 900
                      ? _desktopList(requests)
                      : _mobileList(requests),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _panelDecoration(),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 280,
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _reload(),
              decoration: const InputDecoration(
                labelText: 'Nome ou e-mail',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<PharmacyAccessRequestStatus?>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todos')),
                ...PharmacyAccessRequestStatus.values.map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.label),
                  ),
                ),
              ],
              onChanged: (value) {
                _status = value;
                _reload();
              },
            ),
          ),
          SizedBox(
            width: 230,
            child: FutureBuilder<List<Pharmacy>>(
              future: _pharmacies,
              builder: (context, snapshot) {
                final pharmacies = snapshot.data ?? const [];
                return DropdownButtonFormField<int?>(
                  initialValue: _pharmacyId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Farmácia'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas')),
                    ...pharmacies.map(
                      (pharmacy) => DropdownMenuItem(
                        value: pharmacy.id,
                        child: Text(
                          pharmacy.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: snapshot.hasData
                      ? (value) {
                          _pharmacyId = value;
                          _reload();
                        }
                      : null,
                );
              },
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _pickDate(isFrom: true),
            icon: const Icon(Icons.date_range_outlined),
            label: Text(_from == null ? 'Data inicial' : _date(_from)),
          ),
          OutlinedButton.icon(
            onPressed: () => _pickDate(isFrom: false),
            icon: const Icon(Icons.event_outlined),
            label: Text(_to == null ? 'Data final' : _date(_to)),
          ),
          IconButton(
            onPressed: _clearFilters,
            tooltip: 'Limpar filtros',
            icon: const Icon(Icons.filter_alt_off_outlined),
          ),
        ],
      ),
    );
  }

  Widget _desktopList(List<PharmacyAccessRequestSummary> requests) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Responsável')),
                DataColumn(label: Text('Farmácia')),
                DataColumn(label: Text('Documento')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Solicitada em')),
                DataColumn(label: Text('Ações')),
              ],
              rows: requests.map((request) {
                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(request.responsibleName),
                          Text(request.email),
                        ],
                      ),
                    ),
                    DataCell(Text(request.pharmacyName)),
                    DataCell(Text(request.maskedDocument)),
                    DataCell(_requestStatus(request.status)),
                    DataCell(Text(_dateTime(request.createdAt))),
                    DataCell(_actions(request)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mobileList(List<PharmacyAccessRequestSummary> requests) {
    return ListView.separated(
      controller: _scrollController,
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final request = requests[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: _panelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.responsibleName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  _requestStatus(request.status),
                ],
              ),
              const SizedBox(height: 5),
              Text(request.email),
              Text('${request.pharmacyName} | ${request.maskedDocument}'),
              Text(_dateTime(request.createdAt)),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: _actions(request)),
            ],
          ),
        );
      },
    );
  }

  Widget _actions(PharmacyAccessRequestSummary request) {
    return Wrap(
      spacing: 4,
      children: [
        IconButton(
          onPressed: () => _showDetails(request),
          tooltip: 'Ver detalhes',
          icon: const Icon(Icons.visibility_outlined),
        ),
        if (request.status == PharmacyAccessRequestStatus.pending) ...[
          IconButton(
            onPressed: () => _decide(request, approve: true),
            tooltip: 'Aprovar solicitação',
            icon: const Icon(Icons.check_circle_outline),
          ),
          IconButton(
            onPressed: () => _decide(request, approve: false),
            tooltip: 'Rejeitar solicitação',
            icon: const Icon(Icons.cancel_outlined),
          ),
        ],
      ],
    );
  }

  Widget _requestStatus(PharmacyAccessRequestStatus status) {
    final color = switch (status) {
      PharmacyAccessRequestStatus.pending => Colors.amber.shade800,
      PharmacyAccessRequestStatus.approved => AppColors.success,
      PharmacyAccessRequestStatus.rejected => AppColors.danger,
      PharmacyAccessRequestStatus.cancelled => _AdminColors.muted,
      PharmacyAccessRequestStatus.expired => _AdminColors.muted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _from : _to) ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _from = selected;
      } else {
        _to = selected;
      }
      _requests = _load();
    });
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _status = PharmacyAccessRequestStatus.pending;
      _pharmacyId = null;
      _from = null;
      _to = null;
      _requests = _load();
    });
  }

  Future<void> _showDetails(PharmacyAccessRequestSummary request) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Detalhes da solicitação'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detail('Responsável', request.responsibleName),
              _detail('E-mail', request.email),
              _detail('Telefone', request.phone),
              _detail('Documento', request.maskedDocument),
              _detail(
                'Farmácia',
                '${request.pharmacyName} (ID ${request.pharmacyId})',
              ),
              _detail('Status', request.status.label),
              _detail('Solicitada em', _dateTime(request.createdAt)),
              _detail('Expira em', _dateTime(request.expiresAt)),
              if (request.reviewedAt != null)
                _detail(
                  'Decisao',
                  '${_dateTime(request.reviewedAt)} por admin ID ${request.reviewedBy ?? '-'}',
                ),
              if (request.decisionReason != null)
                _detail('Justificativa', request.decisionReason!),
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
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: _AdminColors.muted),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _decide(
    PharmacyAccessRequestSummary request, {
    required bool approve,
  }) async {
    try {
      final reason = await showDialog<String>(
        context: context,
        builder: (_) =>
            _AccessDecisionDialog(request: request, approve: approve),
      );
      if (reason == null || !mounted) return;

      final message = approve
          ? await widget.service.approveAccessRequest(
              request.id,
              reason: reason,
            )
          : await widget.service.rejectAccessRequest(
              request.id,
              reason: reason,
            );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_cleanError(error))));
    }
  }

  String _date(DateTime? value) => value == null
      ? '-'
      : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  String _dateTime(DateTime? value) {
    if (value == null) return '-';
    return '${_date(value)} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}

class _AccessDecisionDialog extends StatefulWidget {
  final PharmacyAccessRequestSummary request;
  final bool approve;

  const _AccessDecisionDialog({required this.request, required this.approve});

  @override
  State<_AccessDecisionDialog> createState() => _AccessDecisionDialogState();
}

class _AccessDecisionDialogState extends State<_AccessDecisionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.approve ? 'Aprovar acesso?' : 'Rejeitar acesso?'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.approve
                    ? '${widget.request.responsibleName} receberá um convite para administrar ${widget.request.pharmacyName}.'
                    : 'Informe por que o acesso de ${widget.request.responsibleName} não será liberado.',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reason,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: widget.approve
                      ? 'Observação (opcional)'
                      : 'Justificativa',
                ),
                validator: widget.approve
                    ? null
                    : (value) => (value ?? '').trim().length >= 3
                          ? null
                          : 'Informe a justificativa.',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(context, _reason.text.trim());
            }
          },
          child: Text(widget.approve ? 'Aprovar' : 'Rejeitar'),
        ),
      ],
    );
  }
}
