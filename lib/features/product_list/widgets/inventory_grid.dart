import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/controllers/inventory_controller.dart';
import '../../../core/widgets/inventory_card.dart';

class InventoryGrid extends StatelessWidget {
  const InventoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InventoryController>();
    final width = MediaQuery.of(context).size.width;

    int columns = 2;
    if (width > 1200) {
      columns = 4;
    } else if (width > 900) {
      columns = 3;
    }

    if (controller.loading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          return InventoryCard(item: controller.items[index]);
        }, childCount: controller.items.length),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 0.65,
        ),
      ),
    );
  }
}
