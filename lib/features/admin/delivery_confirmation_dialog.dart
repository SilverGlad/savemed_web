import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savemed/core/api/api_error_message.dart';
import 'package:savemed/core/services/admin_service.dart';
import 'package:savemed/models/order_fulfillment.dart';

class DeliveryConfirmationDialog extends StatefulWidget {
  final OrderFulfillment order;
  final AdminService service;
  const DeliveryConfirmationDialog({
    super.key,
    required this.order,
    required this.service,
  });

  @override
  State<DeliveryConfirmationDialog> createState() =>
      _DeliveryConfirmationDialogState();
}

class _DeliveryConfirmationDialogState
    extends State<DeliveryConfirmationDialog> {
  final _form = GlobalKey<FormState>();
  String _code = '';
  String? _error;
  bool _busy = false;
  late int _version = widget.order.version;

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await widget.service.actOnOrder(
        widget.order.id,
        _version,
        widget.order.pickup ? 'picked_up' : 'delivered',
        {'deliveryCode': _code},
      );
      if (mounted) Navigator.pop(context, result);
    } catch (error) {
      final message = ApiErrorMessage.forUser(
        error,
        fallback:
            'Não foi possível confirmar. Atualize o pedido e tente novamente.',
        statusMessages: {
          429:
              'Muitas tentativas. Aguarde 15 minutos antes de tentar novamente.',
        },
      );
      try {
        final current = await widget.service.orderFulfillment(widget.order.id);
        _version = current.version;
      } catch (_) {
        /* A stale version cannot complete the order on the server. */
      }
      if (mounted) setState(() => _error = message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: Text(
        widget.order.pickup ? 'Confirmar retirada' : 'Confirmar entrega',
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Peça o código ao cliente somente ao entregar os produtos.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  autofocus: true,
                  enabled: !_busy,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Código de entrega',
                    hintText: '4 dígitos',
                  ),
                  validator: (value) =>
                      !RegExp(r'^\d{4}$').hasMatch(value ?? '')
                      ? 'Informe os 4 dígitos.'
                      : null,
                  onChanged: (value) => setState(() {
                    _code = value;
                    _error = null;
                  }),
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (_error != null)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (_busy) const LinearProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Voltar'),
        ),
        FilledButton.icon(
          onPressed: _busy ? null : _submit,
          icon: const Icon(Icons.verified_outlined),
          label: const Text('Validar e concluir'),
        ),
      ],
    ),
  );
}
