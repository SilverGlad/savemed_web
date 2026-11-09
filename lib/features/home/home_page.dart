import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/controllers/home_inventory_controller.dart';
import 'package:savemed/core/widgets/savemed_footer.dart';
import 'package:savemed/features/home/widgets/catalog_status.dart';

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
  final _categoriesKey = GlobalKey();
  final _productsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeInventoryController>().load();
    });
  }

  void _handleBannerCta(String url) {
    final key = url.contains('categorias') ? _categoriesKey : _productsKey;
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 600;
    final adminPreview = context.watch<AuthController>().isAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1248),
          child: Column(
            children: [
              const SaveMedHeader(),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    if (adminPreview)
                      SliverToBoxAdapter(
                        child: _AdminPreviewBanner(isMobile: isMobile),
                      ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: BannerCarousel(onCta: _handleBannerCta),
                      ),
                    ),

                    SliverToBoxAdapter(
                      key: _categoriesKey,
                      child: const CategorySection(),
                    ),

                    SliverToBoxAdapter(
                      child: Consumer<HomeInventoryController>(
                        builder: (_, controller, __) =>
                            HomeCatalogStatus(controller: controller),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Consumer<HomeInventoryController>(
                        builder: (_, ctrl, __) => InventorySection(
                          title: 'Ofertas em destaque',
                          items: ctrl.highlights
                              .where((item) => item.discount > 0)
                              .toList(),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Consumer<HomeInventoryController>(
                        builder: (_, ctrl, __) => InventorySection(
                          key: _productsKey,
                          title: 'Todos os produtos',
                          items: ctrl.products,
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Consumer<HomeInventoryController>(
                        builder: (_, ctrl, __) => InventorySection(
                          title: 'Menores preços',
                          items: [...ctrl.products]
                            ..sort((a, b) => a.price.compareTo(b.price)),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminPreviewBanner extends StatelessWidget {
  final bool isMobile;

  const _AdminPreviewBanner({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(isMobile ? 12 : 64, 8, isMobile ? 12 : 64, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_outlined, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Modo de visualização administrativa',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Voltar ao painel'),
          ),
        ],
      ),
    );
  }
}
