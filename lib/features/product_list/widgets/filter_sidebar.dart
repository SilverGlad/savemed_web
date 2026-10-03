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
        borderRadius: BorderRadius.circular(8),
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

            RadioGroup<int>(
              groupValue: inventoryController.categoryId,
              onChanged: (value) {
                if (value != null) inventoryController.setCategory(value);
              },
              child: Column(
                children: categoryController.categories
                    .map(
                      (category) => RadioListTile<int>(
                        dense: true,
                        value: category.id,
                        title: Text(category.name),
                      ),
                    )
                    .toList(),
              ),
            ),

            // =====================
            // SUBCATEGORIAS
            // =====================
            if (selectedCategory != null &&
                selectedCategory.subcategories.isNotEmpty) ...[
              const Divider(),
              const Text('Subcategorias'),
              const SizedBox(height: 8),

              RadioGroup<int>(
                groupValue: inventoryController.subcategoryId,
                onChanged: (value) {
                  if (value != null) inventoryController.setSubcategory(value);
                },
                child: Column(
                  children: selectedCategory.subcategories
                      .map(
                        (sub) => RadioListTile<int>(
                          dense: true,
                          value: sub.id,
                          title: Text(sub.name),
                        ),
                      )
                      .toList(),
                ),
              ),
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
