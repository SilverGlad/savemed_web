import 'package:flutter/material.dart';
import '../../models/inventory_item.dart';
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
    if (widget.loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 360,
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
                separatorBuilder: (_, __) => const SizedBox(width: 16),
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
