import 'package:flutter/material.dart';

/// Abre o diálogo de confirmação para limpar o carrinho
Future<bool> showConfirmClearCartDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => const ConfirmClearCartDialog(),
      ) ??
      false;
}

/// Widget do diálogo (separado, reutilizável)
class ConfirmClearCartDialog extends StatelessWidget {
  const ConfirmClearCartDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Limpar carrinho?'),
      content: const Text(
        'Seu carrinho possui itens de outra farmácia.\n\n'
        'Deseja limpar o carrinho e adicionar este produto?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Limpar e adicionar'),
        ),
      ],
    );
  }
}
