import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:SaveMed/core/controllers/cart_controller.dart';
import 'package:SaveMed/core/widgets/confirm_clear_cart_dialog.dart';
import 'package:SaveMed/features/product_detail/product_detail_page.dart';
import 'package:SaveMed/models/inventory_item.dart';

class InventoryCard extends StatefulWidget {
  final InventoryItem item;

  const InventoryCard({super.key, required this.item});

  @override
  State<InventoryCard> createState() => _InventoryCardState();
}

class _InventoryCardState extends State<InventoryCard> {
  bool _hovered = false;

  static final _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  @override
  Widget build(BuildContext context) {
    final med = widget.item.medication;
    final available = widget.item.available;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(item: widget.item),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: _hovered
              ? (Matrix4.identity()..translate(0.0, -4.0))
              : Matrix4.identity(),
          width: 220,
          height: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BADGE
              if (widget.item.discount != null && widget.item.discount! > 0)
                _badge('${widget.item.discount!.toInt()}% OFF'),

              const Spacer(),

              Center(
                child: SizedBox(
                  height: 80,
                  child: med.image != null && med.image!.isNotEmpty
                      ? Image.network(
                          med.image!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.medical_services, size: 64),
                        )
                      : const Icon(Icons.medical_services, size: 64),
                ),
              ),

              const Spacer(),

              Text(
                med.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              Text(
                _currencyFormatter.format(widget.item.price),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 12),

              // =====================
              // BOTÃO ADD AO CARRINHO
              // =====================
              GestureDetector(
                onTap: available
                    ? () async {
                        final cart = context.read<CartController>();

                        if (!cart.canAddItem(widget.item)) {
                          final confirm = await showConfirmClearCartDialog(
                            context,
                          );
                          if (!confirm) return;

                          cart.clear();
                        }

                        cart.addItem(widget.item);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Produto adicionado ao carrinho'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    : null,

                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: available ? 1 : 0.6,
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: available
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      available ? 'Adicionar ao carrinho' : 'Esgotado',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.orange,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
  );
}
