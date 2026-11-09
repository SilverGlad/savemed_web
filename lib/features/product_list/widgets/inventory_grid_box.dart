import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/controllers/inventory_controller.dart';
import '../../../core/widgets/inventory_card.dart';
import '../../../core/widgets/catalog_layout.dart';

class InventoryGridBox extends StatelessWidget {
  const InventoryGridBox({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InventoryController>();

    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Não foi possível carregar os produtos.'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: controller.load,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (controller.items.isEmpty) {
      return const Center(child: Text('Nenhum produto encontrado'));
    }

    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        itemCount: controller.items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: CatalogLayout.columns(context, constraints.maxWidth),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: CatalogLayout.cardHeight(context),
        ),
        itemBuilder: (_, index) {
          return InventoryCard(item: controller.items[index]);
        },
      ),
    );
  }
}
