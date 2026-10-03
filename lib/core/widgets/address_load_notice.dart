import 'package:flutter/material.dart';

class AddressLoadNotice extends StatelessWidget {
  final VoidCallback? onRetry;

  const AddressLoadNotice({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Semantics(
        liveRegion: true,
        child: const Text('Não foi possível carregar seus endereços.'),
      ),
      TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Tentar carregar endereços novamente'),
      ),
    ],
  );
}
