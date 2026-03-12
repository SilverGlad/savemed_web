import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/controllers/category_controller.dart';
import '../../../core/controllers/inventory_controller.dart';

class FilterSidebar extends StatelessWidget {
  const FilterSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryController = context.watch<CategoryController>();
    final inventoryController = context.watch<InventoryController>();

    final selectedCategory = inventoryController.categoryId == null
        ? null
        : categoryController.categories.firstWhere(
            (c) => c.id == inventoryController.categoryId,
          );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),

            // =====================
            // CATEGORIAS
            // =====================
            const Text('Categorias'),
            const SizedBox(height: 8),

            ...categoryController.categories.map((category) {
              return RadioListTile<int>(
                dense: true,
                value: category.id,
                groupValue: inventoryController.categoryId,
                title: Text(category.name),
                onChanged: (value) {
                  if (value != null) {
                    inventoryController.setCategory(value);
                  }
                },
              );
            }),

            // =====================
            // SUBCATEGORIAS
            // =====================
            if (selectedCategory != null &&
                selectedCategory.subcategories.isNotEmpty) ...[
              const Divider(),
              const Text('Subcategorias'),
              const SizedBox(height: 8),

              ...selectedCategory.subcategories.map((sub) {
                return RadioListTile<int>(
                  dense: true,
                  value: sub.id,
                  groupValue: inventoryController.subcategoryId,
                  title: Text(sub.name),
                  onChanged: (value) {
                    if (value != null) {
                      inventoryController.setSubcategory(value);
                    }
                  },
                );
              }),
            ],

            const Divider(),

            // =====================
            // DISPONIBILIDADE
            // =====================
            CheckboxListTile(
              value: inventoryController.onlyAvailable,
              onChanged: (v) {
                inventoryController.setOnlyAvailable(v ?? false);
              },
              title: const Text('Somente disponíveis'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }
}
