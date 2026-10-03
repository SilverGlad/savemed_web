import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savemed/core/widgets/savemed_footer.dart';
import 'package:savemed/features/product_list/widgets/breadcrumbs.dart';
import 'package:savemed/features/product_list/widgets/inventory_grid_box.dart';
import 'package:savemed/models/category.dart';

import '../../core/controllers/inventory_controller.dart';
import '../../core/theme/app_colors.dart';
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
    final horizontalPadding = width < 640 ? 12.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1248),
          child: Column(
            children: [
              SaveMedHeader(),

              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // =====================
                    // TOPO
                    // =====================
                    SliverPadding(
                      padding: EdgeInsets.all(horizontalPadding),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
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
                    if (!isDesktop) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            0,
                            horizontalPadding,
                            12,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: () => showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                showDragHandle: true,
                                builder: (_) => SafeArea(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: FilterSidebar(),
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.tune_outlined, size: 18),
                              label: const Text('Filtrar categorias'),
                            ),
                          ),
                        ),
                      ),
                      InventoryGrid(horizontalPadding: horizontalPadding),
                    ],

                    const SliverToBoxAdapter(child: SizedBox(height: 48)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          24,
                        ),
                        child: const SaveMedFooter(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
