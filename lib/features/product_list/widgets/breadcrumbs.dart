import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../../../core/controllers/category_controller.dart';
import '../../../core/controllers/inventory_controller.dart';
import '../../../models/subcategory.dart';

class Breadcrumbs extends StatelessWidget {
  const Breadcrumbs({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryController>();
    final categories = context.watch<CategoryController>().categories;

    final category = inventory.categoryId == null
        ? null
        : categories.firstWhereOrNull((c) => c.id == inventory.categoryId);

    Subcategory? subcategory;

    if (category != null && inventory.subcategoryId != null) {
      subcategory = category.subcategories.firstWhereOrNull(
        (s) => s.id == inventory.subcategoryId,
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        _crumb(
          context,
          label: 'Home',
          onTap: () {
            inventory
              ..categoryId = null
              ..subcategoryId = null
              ..setOnlyAvailable(false)
              ..setOnlyHighlight(false)
              ..setOrder(InventoryOrder.relevance);
          },
        ),

        if (category != null) ...[
          const Icon(Icons.chevron_right, size: 16),
          _crumb(
            context,
            label: category.name,
            onTap: () {
              inventory.setCategory(category.id);
            },
          ),
        ],

        if (subcategory != null) ...[
          const Icon(Icons.chevron_right, size: 16),
          _crumb(
            context,
            label: subcategory.name,
            onTap: () {
              inventory.setSubcategory(subcategory!.id);
            },
          ),
        ],
      ],
    );
  }

  Widget _crumb(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
