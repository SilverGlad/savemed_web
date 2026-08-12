import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:SaveMed/core/controllers/home_inventory_controller.dart';
import 'package:SaveMed/core/widgets/banner_carousel.dart';
import 'package:SaveMed/core/widgets/category_section.dart';
import 'package:SaveMed/core/widgets/inventory_section.dart';
import 'package:SaveMed/core/widgets/savemed_footer.dart';
import 'package:SaveMed/core/widgets/savemed_header.dart';
import 'package:SaveMed/core/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _maxContentWidth = 1280;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeInventoryController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _pageContent(const SaveMedHeader())),
          SliverToBoxAdapter(
            child: _pageContent(
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 12 : 24,
                  0,
                  isMobile ? 12 : 24,
                  18,
                ),
                child: BannerCarousel(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _pageContent(const CategorySection()),
          ),
          SliverToBoxAdapter(
            child: _pageContent(
              Consumer<HomeInventoryController>(
                builder: (_, ctrl, __) => InventorySection(
                  title: 'Ofertas em destaque',
                  items: ctrl.highlights,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _pageContent(
              Consumer<HomeInventoryController>(
                builder: (_, ctrl, __) => InventorySection(
                  title: 'Medicamentos',
                  items: ctrl.products,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _pageContent(
              Consumer<HomeInventoryController>(
                builder: (_, ctrl, __) => InventorySection(
                  title: 'Mais vendidos',
                  items: ctrl.bestSellers,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _pageContent(
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 12 : 24,
                  10,
                  isMobile ? 12 : 24,
                  30,
                ),
                child: SaveMedFooter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageContent(Widget child) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContentWidth),
        child: child,
      ),
    );
  }
}
