import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/controllers/inventory_controller.dart';
import '../../../core/widgets/inventory_card.dart';
import '../../../core/widgets/catalog_layout.dart';

class InventoryGrid extends StatelessWidget {
  final double horizontalPadding;

  const InventoryGrid({super.key, this.horizontalPadding = 16});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InventoryController>();
    final width = MediaQuery.of(context).size.width;

    final columns = CatalogLayout.columns(
      context,
      width - horizontalPadding * 2,
    );

    if (controller.loading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (controller.error != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
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
        ),
      );
    }

    if (controller.items.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('Nenhum produto encontrado')),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          return InventoryCard(item: controller.items[index]);
        }, childCount: controller.items.length),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: CatalogLayout.cardHeight(context),
        ),
      ),
    );
  }
}
