import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:SaveMed/features/product_list/product_list_page.dart';

import '../controllers/category_controller.dart';
import '../theme/app_colors.dart';
import '../utils/category_assets.dart';

class CategorySection extends StatefulWidget {
  const CategorySection({super.key});

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CategoryController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CategoryController>();

    if (controller.loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 140, // ⬅️ mais alto para imagem + texto
      child: ScrollConfiguration(
        behavior: _MouseDragScrollBehavior(),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 24),
          itemBuilder: (_, index) {
            final category = controller.categories[index];
            return _CategoryHoverItem(
              categoryName: category.name,
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
    );
  }
}

class _CategoryHoverItem extends StatefulWidget {
  final String categoryName;
  final VoidCallback onTap;

  const _CategoryHoverItem({required this.categoryName, required this.onTap});

  @override
  State<_CategoryHoverItem> createState() => _CategoryHoverItemState();
}

class _CategoryHoverItemState extends State<_CategoryHoverItem> {
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
        transform: _hovered
            ? (Matrix4.identity()..translate(0.0, -4.0))
            : Matrix4.identity(),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onTap,
          child: Container(
            width: 120,
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  categoryAssetByName(widget.categoryName),
                  fit: BoxFit.contain,
                  height: 120,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 👇 Habilita arrastar com mouse no Flutter Web
class _MouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.mouse,
    PointerDeviceKind.touch,
    PointerDeviceKind.trackpad,
  };
}
