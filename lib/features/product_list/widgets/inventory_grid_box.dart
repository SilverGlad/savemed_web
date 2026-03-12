import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/controllers/inventory_controller.dart';
import '../../../core/widgets/inventory_card.dart';

class InventoryGridBox extends StatelessWidget {
  const InventoryGridBox({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InventoryController>();
    final width = MediaQuery.of(context).size.width;

    int columns = 3;
    if (width > 1200) {
      columns = 4;
    }

    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.items.isEmpty) {
      return const Center(child: Text('Nenhum produto encontrado'));
    }

    return GridView.builder(
      itemCount: controller.items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (_, index) {
        return InventoryCard(item: controller.items[index]);
      },
    );
  }
}
