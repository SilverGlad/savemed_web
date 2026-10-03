import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/navigation/app_routes.dart';
import 'package:savemed/core/widgets/confirm_clear_cart_dialog.dart';
import 'package:savemed/core/widgets/savemed_header.dart';
import 'package:savemed/core/widgets/savemed_footer.dart';
import 'package:savemed/features/cart/cart_page.dart';
import '../../models/inventory_item.dart';
import '../../core/theme/app_colors.dart';

class ProductDetailPage extends StatelessWidget {
  final InventoryItem item;

  const ProductDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final med = item.medication;
    final hasDiscount = item.originalPrice > item.price;
    final available = item.available;

    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 900;
    final showStickyPurchase =
        isMobile && MediaQuery.viewInsetsOf(context).bottom == 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: showStickyPurchase
          ? _purchaseBar(context, available)
          : null,
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
                child: Column(
                  children: [
                    ConstrainedBox(
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
                                Expanded(
                                  child: _card(child: _productImage(med.image)),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: _card(
                                    child: _infoBlock(
                                      context,
                                      med.name,
                                      item.price,
                                      item.originalPrice,
                                      hasDiscount,
                                      available,
                                      showPurchaseAction: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
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
                                showPurchaseAction: false,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _card(child: _descriptionBlock(med.description)),
                          ],

                          SizedBox(height: isMobile ? 120 : 64),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: const SaveMedFooter(),
                    ),
                  ],
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
    const placeholder = Icon(
      Icons.image_not_supported_outlined,
      size: 96,
      color: Colors.grey,
    );
    return AspectRatio(
      aspectRatio: 1,
      child: image != null
          ? Image.network(
              image,
              fit: BoxFit.contain,
              semanticLabel: 'Imagem do produto',
              errorBuilder: (_, __, ___) => placeholder,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const Center(child: CircularProgressIndicator()),
            )
          : placeholder,
    );
  }

  // =====================
  // DESCRIÇÃO
  // =====================
  Widget _descriptionBlock(String? description) {
    final medication = item.medication;
    final hasDetails =
        medication.brand != null ||
        medication.unit != null ||
        medication.activeIngredients.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descrição',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          description?.trim().isNotEmpty == true
              ? description!.trim()
              : 'Descrição não informada.',
        ),
        if (medication.requiresPrescription) ...[
          const SizedBox(height: 16),
          Semantics(
            excludeSemantics: true,
            label:
                'A farmácia informa que este produto exige apresentação de receita.',
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.medical_information_outlined,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'A farmácia informa que este produto exige apresentação de receita.',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (hasDetails) ...[
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Informações do produto',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (medication.brand != null) _factRow('Marca', medication.brand!),
          if (medication.unit != null)
            _factRow('Apresentação', medication.unit!),
          if (medication.activeIngredients.isNotEmpty)
            _factRow(
              'Princípios ativos',
              medication.activeIngredients
                  .map((ingredient) => ingredient.name)
                  .join(', '),
            ),
        ],
      ],
    );
  }

  Widget _factRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textLight),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: AppColors.textDark)),
      ],
    ),
  );

  // =====================
  // BLOCO DE INFO
  // =====================
  Widget _infoBlock(
    BuildContext context,
    String name,
    double price,
    double originalPrice,
    bool hasDiscount,
    bool available, {
    required bool showPurchaseAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('Vendido por'),
        TextButton.icon(
          onPressed: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.pharmacy, arguments: item.pharmacy),
          icon: const Icon(Icons.storefront_outlined),
          label: Text(item.pharmacy.name),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            if (item.pharmacy.acceptsPickup) const Text('Retirada na farmácia'),
            if (item.pharmacy.acceptsOwnDelivery)
              const Text('Entrega da farmácia'),
          ],
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              _formatPrice(price),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            if (hasDiscount) ...[
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

        if (showPurchaseAction)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: available ? () => _addToCart(context) : null,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                available ? 'Adicionar ao carrinho' : item.unavailableLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Widget _purchaseBar(BuildContext context, bool available) {
    final media = MediaQuery.of(context);
    final compact = media.size.width <= 360 || media.textScaler.scale(16) > 19;
    final price = Text(
      _formatPrice(item.price),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
    final action = SizedBox(
      width: compact ? double.infinity : 184,
      height: 48,
      child: FilledButton.icon(
        onPressed: available ? () => _addToCart(context) : null,
        icon: const Icon(Icons.add_shopping_cart_outlined),
        label: Text(available ? 'Adicionar' : item.unavailableLabel),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );

    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            media.size.width <= 360 ? 12 : 20,
            12,
            media.size.width <= 360 ? 12 : 20,
            12,
          ),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: compact
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [price, const SizedBox(height: 8), action],
                )
              : Row(
                  children: [
                    Expanded(child: price),
                    const SizedBox(width: 12),
                    action,
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _addToCart(BuildContext context) async {
    final cart = context.read<CartController>();
    final messenger = ScaffoldMessenger.of(context);
    if (!cart.canAddItem(item)) {
      final confirm = await showConfirmClearCartDialog(context);
      if (!confirm || !context.mounted) return;
      cart.clear();
    }

    final added = cart.addItem(item);
    if (!context.mounted) return;
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

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  String _formatPrice(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
