import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/controllers/inventory_controller.dart';

class OrderBar extends StatelessWidget {
  const OrderBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InventoryController>();

    return Row(
      children: [
        const Text(
          'Ordenar por:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 12),

        DropdownButton<InventoryOrder>(
          value: controller.order,
          onChanged: (value) {
            if (value != null) {
              controller.setOrder(value);
            }
          },
          items: [
            const DropdownMenuItem(
              value: InventoryOrder.relevance,
              child: Text('Relevância'),
            ),
            const DropdownMenuItem(
              value: InventoryOrder.priceAsc,
              child: Text('Menor preço'),
            ),
            const DropdownMenuItem(
              value: InventoryOrder.priceDesc,
              child: Text('Maior preço'),
            ),
            DropdownMenuItem(
              value: InventoryOrder.nameAsc,
              child: const Text('Nome (A–Z)'),
            ),
          ],
        ),
      ],
    );
  }
}
