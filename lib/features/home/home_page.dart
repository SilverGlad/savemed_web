import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SaveMed/core/controllers/home_inventory_controller.dart';
import 'package:SaveMed/core/widgets/savemed_footer.dart';

import '../../core/widgets/banner_carousel.dart';
import '../../core/widgets/category_section.dart';
import '../../core/widgets/savemed_header.dart';
import '../../core/widgets/inventory_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 600;

    return ChangeNotifierProvider(
      create: (_) => HomeInventoryController()..load(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        body: CustomScrollView(
          slivers: [
            // =====================
            // HEADER
            // =====================
            SliverToBoxAdapter(child: SaveMedHeader()),

            // =====================
            // BANNER
            // =====================
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 0,
                  vertical: isMobile ? 8 : 0,
                ),
                child: const BannerCarousel(),
              ),
            ),

            // =====================
            // CATEGORIAS
            // =====================
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 0),
                child: const CategorySection(),
              ),
            ),

            // =====================
            // OFERTAS
            // =====================
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 0),
                child: Consumer<HomeInventoryController>(
                  builder: (_, ctrl, __) => InventorySection(
                    title: 'Ofertas em destaque',
                    items: ctrl.highlights,
                  ),
                ),
              ),
            ),

            // =====================
            // MEDICAMENTOS
            // =====================
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 0),
                child: Consumer<HomeInventoryController>(
                  builder: (_, ctrl, __) => InventorySection(
                    title: 'Medicamentos',
                    items: ctrl.products,
                  ),
                ),
              ),
            ),

            // =====================
            // MAIS VENDIDOS
            // =====================
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 0),
                child: Consumer<HomeInventoryController>(
                  builder: (_, ctrl, __) => InventorySection(
                    title: 'Mais vendidos',
                    items: ctrl.bestSellers,
                  ),
                ),
              ),
            ),

            // =====================
            // FOOTER
            // =====================
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: isMobile ? 24 : 40),
                child: const SaveMedFooter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
