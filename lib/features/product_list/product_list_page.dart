import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SaveMed/core/widgets/savemed_footer.dart';
import 'package:SaveMed/features/product_list/widgets/breadcrumbs.dart';
import 'package:SaveMed/features/product_list/widgets/inventory_grid_box.dart';
import 'package:SaveMed/models/category.dart';

import '../../core/controllers/inventory_controller.dart';
import '../../core/widgets/savemed_header.dart';
import 'widgets/filter_sidebar.dart';
import 'widgets/inventory_grid.dart'; // SLIVER (mobile)
import 'widgets/order_bar.dart';

class ProductListPage extends StatefulWidget {
  final Category category;

  const ProductListPage({super.key, required this.category});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = context.read<InventoryController>();
      controller.categoryId = widget.category.id;
      controller.subcategoryId = null;
      controller.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: Column(
        children: [
          SaveMedHeader(),

          Expanded(
            child: CustomScrollView(
              slivers: [
                // =====================
                // TOPO
                // =====================
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Breadcrumbs(),
                        SizedBox(height: 12),
                        OrderBar(),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // =====================
                // DESKTOP: SIDEBAR + GRID
                // =====================
                if (isDesktop)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(width: 260, child: FilterSidebar()),
                          SizedBox(width: 24),
                          Expanded(child: InventoryGridBox()),
                        ],
                      ),
                    ),
                  ),

                // =====================
                // MOBILE: GRID SLIVER
                // =====================
                if (!isDesktop) InventoryGrid(),

                const SliverToBoxAdapter(child: SizedBox(height: 48)),
                const SliverToBoxAdapter(child: SaveMedFooter()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
