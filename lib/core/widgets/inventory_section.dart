import 'package:flutter/material.dart';

import '../../models/inventory_item.dart';
import '../theme/app_colors.dart';
import 'inventory_card.dart';

class InventorySection extends StatefulWidget {
  final String title;
  final List<InventoryItem> items;
  final bool loading;

  const InventorySection({
    super.key,
    required this.title,
    required this.items,
    this.loading = false,
  });

  @override
  State<InventorySection> createState() => _InventorySectionState();
}

class _InventorySectionState extends State<InventorySection> {
  final ScrollController _scrollController = ScrollController();
  double _lastDragX = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 700;

    if (widget.loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 12 : 64,
        0,
        isMobile ? 12 : 64,
        18,
      ),
      padding: EdgeInsets.all(isMobile ? 18 : 64),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title.isNotEmpty) ...[
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Selecao pensada para compra rapida e leitura facil no celular.',
              style: TextStyle(color: AppColors.textLight),
            ),
            const SizedBox(height: 18),
          ],
          SizedBox(
            height: isMobile ? 356 : 390,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (details) {
                _lastDragX = details.globalPosition.dx;
              },
              onHorizontalDragUpdate: (details) {
                final dx = details.globalPosition.dx;
                final delta = _lastDragX - dx;

                _scrollController.jumpTo(
                  (_scrollController.offset + delta).clamp(
                    _scrollController.position.minScrollExtent,
                    _scrollController.position.maxScrollExtent,
                  ),
                );

                _lastDragX = dx;
              },
              child: ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                itemCount: widget.items.length,
                separatorBuilder: (_, __) =>
                    SizedBox(width: isMobile ? 12 : 16),
                itemBuilder: (_, index) {
                  return InventoryCard(item: widget.items[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
