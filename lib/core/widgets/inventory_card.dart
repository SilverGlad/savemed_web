import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/theme/app_colors.dart';
import 'package:savemed/core/widgets/confirm_clear_cart_dialog.dart';
import 'package:savemed/features/cart/cart_page.dart';
import 'package:savemed/features/product_detail/product_detail_page.dart';
import 'package:savemed/models/inventory_item.dart';
import 'catalog_layout.dart';

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
    final isMobile = MediaQuery.sizeOf(context).width <= 700;
    final cardHeight = CatalogLayout.cardHeight(context);
    final cardWidth = isMobile ? 224.0 : 264.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        button: true,
        label: 'Abrir detalhes de ${med.name}',
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
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
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  child: widget.item.discount > 0
                      ? _badge('${widget.item.discount}% OFF')
                      : null,
                ),

                const SizedBox(height: 8),
                Center(
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: (med.image?.isNotEmpty ?? false)
                        ? Image.network(
                            med.image!,
                            fit: BoxFit.contain,
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                ? child
                                : const Center(
                                    child: Icon(
                                      Icons.medication_outlined,
                                      color: AppColors.primary,
                                      size: 36,
                                    ),
                                  ),
                            errorBuilder: (_, __, ___) => const Center(
                              child: Text(
                                'Imagem indisponível',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : const Center(
                            child: Text(
                              'Sem imagem',
                              textAlign: TextAlign.center,
                            ),
                          ),
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
                  widget.item.pharmacy.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  _currencyFormatter.format(widget.item.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 14),

                // =====================
                // BOTÃO ADD AO CARRINHO
                // =====================
                Semantics(
                  container: true,
                  button: true,
                  enabled: available,
                  onTap: available ? _addToCart : null,
                  label: available
                      ? 'Adicionar ${med.name} ao carrinho'
                      : '${med.name}: ${widget.item.unavailableLabel}',
                  excludeSemantics: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: available ? _addToCart : null,

                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: available ? 1 : 0.6,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 46),
                        decoration: BoxDecoration(
                          color: available
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 11,
                        ),
                        child: Text(
                          available
                              ? 'Adicionar'
                              : widget.item.unavailableLabel,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart() async {
    if (!widget.item.available) return;
    final cart = context.read<CartController>();
    final messenger = ScaffoldMessenger.of(context);
    if (!cart.canAddItem(widget.item)) {
      final confirm = await showConfirmClearCartDialog(context);
      if (!confirm || !mounted) return;
      cart.clear();
    }
    if (!mounted) return;
    final added = cart.addItem(widget.item);
    messenger.hideCurrentSnackBar();
    if (!added) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível adicionar mais unidades. Confira o estoque e a farmácia do carrinho.',
          ),
        ),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Produto adicionado ao carrinho'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Ir para o carrinho',
          onPressed: () {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartPage()),
            );
          },
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
