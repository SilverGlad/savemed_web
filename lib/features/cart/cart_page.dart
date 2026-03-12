import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SaveMed/core/controllers/cart_controller.dart';
import 'package:SaveMed/core/controllers/home_inventory_controller.dart';
import 'package:SaveMed/core/widgets/inventory_section.dart';
import 'package:SaveMed/core/widgets/savemed_footer.dart';
import 'package:SaveMed/core/widgets/savemed_header.dart';
import 'package:SaveMed/features/cart/widgets/cart_item_tile.dart';
import 'package:SaveMed/features/cart/widgets/cart_summary_card.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;
    final isMobile = width <= 600;

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
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Consumer<CartController>(
                builder: (context, cart, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =====================
                      // DESKTOP LAYOUT
                      // =====================
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 7,
                              child: _card(child: _productList(cart)),
                            ),
                            const SizedBox(width: 24),
                            const Expanded(flex: 3, child: CartSummaryCard()),
                          ],
                        ),

                      // =====================
                      // MOBILE / TABLET LAYOUT
                      // =====================
                      if (!isDesktop) ...[
                        _card(child: _productList(cart)),
                        const SizedBox(height: 16),
                        _card(child: const CartSummaryCard()),
                      ],

                      const SizedBox(height: 32),

                      // =====================
                      // SUGESTÕES
                      // =====================
                      const Text(
                        'Produtos que você também pode gostar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Consumer<HomeInventoryController>(
                        builder: (_, ctrl, __) => InventorySection(
                          title: '',
                          items: ctrl.bestSellers.take(10).toList(),
                          loading: ctrl.loading,
                        ),
                      ),

                      SizedBox(height: isMobile ? 32 : 48),

                      // =====================
                      // FOOTER
                      // =====================
                      const SaveMedFooter(),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================
  // PRODUTOS DO CARRINHO
  // =====================
  Widget _productList(CartController cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Produtos no carrinho',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(),

        if (cart.items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Seu carrinho está vazio'),
          )
        else
          Column(
            children: cart.items
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: CartItemTile(cartItem: e),
                  ),
                )
                .toList(),
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
}
