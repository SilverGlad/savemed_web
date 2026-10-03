import 'package:flutter/material.dart';
import 'package:savemed/core/api/api_error_message.dart';
import 'package:savemed/core/services/admin_service.dart';
import 'package:savemed/models/pharmacy_operation.dart';

class PharmacyOperationPanel extends StatefulWidget {
  final int pharmacyId;
  final AdminService service;
  const PharmacyOperationPanel({
    super.key,
    required this.pharmacyId,
    required this.service,
  });
  @override
  State<PharmacyOperationPanel> createState() => _PharmacyOperationPanelState();
}

class _PharmacyOperationPanelState extends State<PharmacyOperationPanel> {
  PharmacyOperation? _operation;
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final value = await widget.service.pharmacyOperation(widget.pharmacyId);
      if (mounted) setState(() => _operation = value);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = ApiErrorMessage.forUser(
            error,
            fallback: 'Não foi possível consultar a loja.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save(Map<String, dynamic> values) async {
    if (_busy || _operation == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final value = await widget.service.updatePharmacyOperation(
        widget.pharmacyId,
        _operation!.version,
        values,
      );
      if (mounted) setState(() => _operation = value);
    } catch (error) {
      try {
        final value = await widget.service.pharmacyOperation(widget.pharmacyId);
        if (mounted) setState(() => _operation = value);
      } catch (_) {
        /* Keep the last confirmed state until an explicit refresh. */
      }
      if (mounted) {
        setState(
          () => _error = ApiErrorMessage.forUser(
            error,
            fallback: 'Não foi possível atualizar a loja.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggle(bool open) async {
    if (!open) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pausar novos pedidos?'),
          content: const Text(
            'Novas compras serão bloqueadas. Os pedidos já recebidos continuam e precisam ser atendidos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Pausar loja'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    await _save({'isOpen': open});
  }

  @override
  Widget build(BuildContext context) {
    final operation = _operation;
    final minutes = <int>{
      5,
      10,
      15,
      20,
      30,
      45,
      60,
      90,
      120,
      180,
      if (operation?.preparationMinutes != null) operation!.preparationMinutes!,
    }.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          Semantics(
            liveRegion: true,
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (operation == null)
          OutlinedButton.icon(
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Consultar situação da loja'),
          )
        else ...[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              !operation.active
                  ? 'Loja inativa'
                  : operation.isOpen
                  ? 'Loja aberta'
                  : 'Loja pausada',
            ),
            subtitle: const Text('Receber novos pedidos'),
            value: operation.active && operation.isOpen,
            onChanged: _busy || !operation.active ? null : _toggle,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            key: ValueKey('preparation-${operation.version}'),
            initialValue: operation.preparationMinutes,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Preparo estimado',
              border: OutlineInputBorder(),
            ),
            hint: const Text('Não definido'),
            items: [
              for (final value in minutes)
                DropdownMenuItem(value: value, child: Text('$value minutos')),
            ],
            onChanged: _busy || !operation.active
                ? null
                : (value) {
                    if (value != null) _save({'preparationMinutes': value});
                  },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Atualizar situação da loja',
              onPressed: _busy ? null : _load,
              icon: const Icon(Icons.refresh),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Condições comerciais',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const Text(
            'Comissão SaveMed: 20% sobre os produtos, sem incluir o frete. A SaveMed absorve a taxa de pagamento na sua comissão. Frete pago pelo cliente e destinado à PedMoto nas entregas pelo parceiro.',
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: ValueKey('payout-${operation.version}'),
            initialValue: operation.payoutTermDays,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Prazo de repasse',
              border: OutlineInputBorder(),
            ),
            hint: const Text('Selecionar prazo'),
            items: const [
              DropdownMenuItem(value: 15, child: Text('15 dias')),
              DropdownMenuItem(value: 30, child: Text('30 dias')),
            ],
            onChanged: _busy || !operation.active
                ? null
                : (value) {
                    if (value != null) _save({'payoutTermDays': value});
                  },
          ),
          const SizedBox(height: 8),
          const Text(
            'Prazo contado após a confirmação da entrega ou retirada. A escolha do prazo não efetua transferências. Os repasses dependem da configuração financeira e da liquidação no provedor.',
          ),
        ],
      ],
    );
  }
}
