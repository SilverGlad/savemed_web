import 'package:flutter/material.dart';
import 'package:savemed/core/api/api_error_message.dart';
import 'package:savemed/core/services/order_service.dart';

class DeliveryCodePanel extends StatefulWidget {
  final int orderId;
  final OrderService? service;
  const DeliveryCodePanel({super.key, required this.orderId, this.service});

  @override
  State<DeliveryCodePanel> createState() => _DeliveryCodePanelState();
}

class _DeliveryCodePanelState extends State<DeliveryCodePanel> {
  String? _code;
  String? _error;
  bool _loading = false;

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _code = null;
    });
    try {
      final code = await (widget.service ?? OrderService()).deliveryCode(
        widget.orderId,
      );
      if (mounted) setState(() => _code = code);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = ApiErrorMessage.forUser(
            error,
            fallback: 'Não foi possível consultar o código. Tente novamente.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Código de entrega',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text('Informe ao entregador somente quando receber os produtos.'),
        const SizedBox(height: 12),
        if (_code != null)
          Semantics(
            liveRegion: true,
            label: 'Código de entrega: ${_code!.split('').join(' ')}',
            child: ExcludeSemantics(
              child: Text(
                _code!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        if (_error != null)
          Semantics(
            liveRegion: true,
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _loading ? null : _load,
          icon: const Icon(Icons.pin_outlined),
          label: Text(
            _loading
                ? 'Consultando...'
                : _code == null
                ? 'Ver código'
                : 'Atualizar código',
          ),
        ),
      ],
    ),
  );
}
