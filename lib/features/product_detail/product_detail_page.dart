import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SaveMed/core/controllers/cart_controller.dart';
import 'package:SaveMed/core/widgets/confirm_clear_cart_dialog.dart';
import 'package:SaveMed/core/widgets/savemed_header.dart';
import 'package:SaveMed/core/widgets/savemed_footer.dart';
import 'package:SaveMed/features/cart/cart_page.dart';
import '../../models/inventory_item.dart';

class ProductDetailPage extends StatelessWidget {
  final InventoryItem item;

  const ProductDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final med = item.medication;
    final hasDiscount = item.originalPrice > item.price;
    final available = item.stock > 0;

    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: Column(
        children: [
          // =====================
          // HEADER
          // =====================
          SaveMedHeader(),

          // =====================
          // CONTEÚDO
          // =====================
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 12 : 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =====================
                      // DESKTOP
                      // =====================
                      if (!isMobile) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 420,
                              child: _card(child: _productImage(med.image)),
                            ),
                            const SizedBox(width: 24),
                            SizedBox(
                              width: 420,
                              child: _card(
                                child: _infoBlock(
                                  context,
                                  med.name,
                                  item.price,
                                  item.originalPrice,
                                  hasDiscount,
                                  available,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 420,
                          child: _card(
                            child: _descriptionBlock(med.description),
                          ),
                        ),
                      ],

                      // =====================
                      // MOBILE
                      // =====================
                      if (isMobile) ...[
                        _card(child: _productImage(med.image)),
                        const SizedBox(height: 16),
                        _card(
                          child: _infoBlock(
                            context,
                            med.name,
                            item.price,
                            item.originalPrice,
                            hasDiscount,
                            available,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _card(child: _descriptionBlock(med.description)),
                      ],

                      SizedBox(height: isMobile ? 32 : 64),
                      const SaveMedFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================
  // IMAGEM
  // =====================
  Widget _productImage(String? image) {
    return AspectRatio(
      aspectRatio: 1,
      child: image != null
          ? Image.network(image, fit: BoxFit.contain)
          : const Icon(Icons.image, size: 120, color: Colors.grey),
    );
  }

  // =====================
  // DESCRIÇÃO
  // =====================
  Widget _descriptionBlock(String? description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descrição',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(description ?? '-'),
      ],
    );
  }

  // =====================
  // BLOCO DE INFO
  // =====================
  Widget _infoBlock(
    BuildContext context,
    String name,
    double price,
    double originalPrice,
    bool hasDiscount,
    bool available,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatPrice(price),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            if (hasDiscount) ...[
              const SizedBox(width: 12),
              Text(
                _formatPrice(originalPrice),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 24),

        GestureDetector(
          onTap: available
              ? () async {
                  final cart = context.read<CartController>();

                  if (!cart.canAddItem(item)) {
                    final confirm = await showConfirmClearCartDialog(context);
                    if (!confirm) return;
                    cart.clear();
                  }

                  cart.addItem(item);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  );
                }
              : null,
          child: Container(
            width: double.infinity,
            height: 48,
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
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =====================
  // CARD BASE
  // =====================
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  String _formatPrice(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
