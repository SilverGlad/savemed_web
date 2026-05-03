import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SaveMed/core/controllers/home_inventory_controller.dart';
import 'package:SaveMed/core/widgets/savemed_footer.dart';

import '../../core/widgets/banner_carousel.dart';
import '../../core/widgets/category_section.dart';
import '../../core/widgets/savemed_header.dart';
import '../../core/widgets/inventory_section.dart';
import '../../core/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SaveMedHeader()),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 12 : 64,
                0,
                isMobile ? 12 : 64,
                18,
              ),
              child: Container(
                padding: EdgeInsets.all(isMobile ? 20 : 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'App com foco mobile',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Sua farmácia digital com navegação mais leve e direta.',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontSize: isMobile ? 28 : 34,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Busque, compare e finalize pedidos com uma interface pensada primeiro para o celular.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.4,
                        fontSize: isMobile ? 14 : 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 0 : 0,
                vertical: isMobile ? 12 : 12,
              ),
              child: const BannerCarousel(),
            ),
          ),

          const SliverToBoxAdapter(child: CategorySection()),

          SliverToBoxAdapter(
            child: Consumer<HomeInventoryController>(
              builder: (_, ctrl, __) => InventorySection(
                title: 'Ofertas em destaque',
                items: ctrl.highlights,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Consumer<HomeInventoryController>(
              builder: (_, ctrl, __) =>
                  InventorySection(title: 'Medicamentos', items: ctrl.products),
            ),
          ),

          SliverToBoxAdapter(
            child: Consumer<HomeInventoryController>(
              builder: (_, ctrl, __) => InventorySection(
                title: 'Mais vendidos',
                items: ctrl.bestSellers,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 12 : 40,
                10,
                isMobile ? 12 : 40,
                isMobile ? 20 : 30,
              ),
              child: const SaveMedFooter(),
            ),
          ),
        ],
      ),
    );
  }
}
