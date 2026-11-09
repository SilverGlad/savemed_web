import 'package:flutter/material.dart';
import 'package:savemed/core/controllers/home_inventory_controller.dart';

import '../../../core/theme/app_colors.dart';

class HomeCatalogStatus extends StatelessWidget {
  final HomeInventoryController controller;

  const HomeCatalogStatus({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.loading && controller.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.error != null) {
      final hasPartialCatalog = !controller.isEmpty;
      return _CatalogMessage(
        icon: hasPartialCatalog
            ? Icons.warning_amber_outlined
            : Icons.cloud_off_outlined,
        title: hasPartialCatalog
            ? 'Catálogo parcialmente carregado'
            : 'Não foi possível carregar os produtos',
        message: hasPartialCatalog
            ? 'Algumas listas podem estar incompletas. Verifique sua conexão e tente novamente.'
            : 'Verifique sua conexão e tente novamente.',
        action: controller.loading ? null : controller.load,
      );
    }
    if (!controller.loading && controller.isEmpty) {
      return const _CatalogMessage(
        icon: Icons.inventory_2_outlined,
        title: 'Nenhum produto disponível no momento',
        message: 'O catálogo será exibido assim que houver estoque ativo.',
      );
    }
    return const SizedBox.shrink();
  }
}

class _CatalogMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? action;

  const _CatalogMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width <= 600;
    return Padding(
      padding: EdgeInsets.fromLTRB(mobile ? 12 : 64, 8, mobile ? 12 : 64, 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.textLight),
            const SizedBox(height: 10),
            Semantics(
              liveRegion: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textLight),
            ),
            if (action != null) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: action,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
