import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:SaveMed/core/controllers/cart_controller.dart';
import 'package:SaveMed/core/theme/app_colors.dart';
import 'package:SaveMed/core/widgets/confirm_clear_cart_dialog.dart';
import 'package:SaveMed/features/cart/cart_page.dart';
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
              ? (Matrix4.identity()..translateByDouble(0.0, -4.0, 0.0, 1.0))
              : Matrix4.identity(),
          width: MediaQuery.of(context).size.width <= 700 ? 188 : 220,
          height: MediaQuery.of(context).size.width <= 700 ? 290 : 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.item.discount > 0)
                _badge('${widget.item.discount}% OFF'),

              const SizedBox(height: 8),
              Center(
                child: Container(
                  height: 112,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: (med.image?.isNotEmpty ?? false)
                      ? Image.network(
                          med.image!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.medical_services, size: 64),
                        )
                      : const Icon(Icons.medical_services, size: 64),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                med.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 6),
              Text(
                med.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.textLight,
                ),
              ),
              const Spacer(),

              Text(
                _currencyFormatter.format(widget.item.price),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 10),

              // =====================
              // BOTÃO ADD AO CARRINHO
              // =====================
              GestureDetector(
                onTap: available
                    ? () async {
                        final cart = context.read<CartController>();
                        final messenger = ScaffoldMessenger.of(context);

                        if (!cart.canAddItem(widget.item)) {
                          final confirm = await showConfirmClearCartDialog(
                            context,
                          );
                          if (!confirm) return;

                          cart.clear();
                        }

                        if (!mounted) return;
                        cart.addItem(widget.item);

                        messenger.hideCurrentSnackBar();
                        messenger.showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Produto adicionado ao carrinho',
                            ),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'Ir para o carrinho',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CartPage(),
                                  ),
                                );
                              },
                            ),
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
                      borderRadius: BorderRadius.circular(16),
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
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
