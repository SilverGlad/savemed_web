import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savemed/features/product_list/product_list_page.dart';

import '../controllers/category_controller.dart';
import '../theme/app_colors.dart';
import '../utils/category_icons.dart';

class CategorySection extends StatefulWidget {
  const CategorySection({super.key});

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CategoryController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CategoryController>();
    final isMobile = MediaQuery.of(context).size.width <= 700;

    if (controller.loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 12 : 24,
        0,
        isMobile ? 12 : 24,
        18,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore por categoria',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 148 + (MediaQuery.textScalerOf(context).scale(1) - 1) * 76,
            child: ScrollConfiguration(
              behavior: _MouseDragScrollBehavior(),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                separatorBuilder: (_, __) =>
                    SizedBox(width: isMobile ? 12 : 16),
                itemBuilder: (_, index) {
                  final category = controller.categories[index];
                  return _CategoryCard(
                    categoryName: category.name,
                    imageUrl: category.image,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductListPage(category: category),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String categoryName;
  final VoidCallback onTap;
  final String? imageUrl;

  const _CategoryCard({
    required this.categoryName,
    required this.onTap,
    this.imageUrl,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.onTap,
          child: Container(
            width:
                156 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 1.5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hovered ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: widget.imageUrl == null
                      ? Icon(
                          categoryIconByName(widget.categoryName),
                          size: 40,
                          color: AppColors.primary,
                        )
                      : Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                              ? child
                              : Icon(
                                  categoryIconByName(widget.categoryName),
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                          errorBuilder: (_, __, ___) => Icon(
                            categoryIconByName(widget.categoryName),
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.categoryName,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.mouse,
    PointerDeviceKind.touch,
    PointerDeviceKind.trackpad,
  };
}
