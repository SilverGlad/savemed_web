import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/controllers/home_inventory_controller.dart';
import 'package:savemed/core/theme/app_colors.dart';
import 'package:savemed/core/widgets/inventory_section.dart';
import 'package:savemed/core/widgets/savemed_footer.dart';
import 'package:savemed/core/widgets/savemed_header.dart';
import 'package:savemed/features/cart/widgets/cart_item_tile.dart';
import 'package:savemed/features/cart/widgets/cart_summary_card.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1040;
    final horizontalPadding = width < 640 ? 12.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SaveMedHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Consumer<CartController>(
                    builder: (context, cart, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CartHero(cart: cart),
                          const SizedBox(height: 20),
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _SurfaceCard(
                                    padding: const EdgeInsets.all(22),
                                    child: _ProductList(cart: cart),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                const Expanded(
                                  flex: 4,
                                  child: CartSummaryCard(),
                                ),
                              ],
                            )
                          else ...[
                            _SurfaceCard(
                              padding: const EdgeInsets.all(18),
                              child: _ProductList(cart: cart),
                            ),
                            const SizedBox(height: 16),
                            const CartSummaryCard(),
                          ],
                          const SizedBox(height: 28),
                          const _SuggestionsSection(),
                          const SizedBox(height: 32),
                          const SaveMedFooter(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartHero extends StatelessWidget {
  final CartController cart;

  const _CartHero({required this.cart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemsLabel = cart.totalItems == 1
        ? '1 item'
        : '${cart.totalItems} itens';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0E7C62), Color(0xFF13A886)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Wrap(
        runSpacing: 16,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Carrinho SaveMed',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Revise os itens e feche sua compra com entrega farmaceutica.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Endereco, frete e pagamento ficam organizados em blocos simples para funcionar melhor no celular.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.84),
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricChip(label: 'Itens', value: itemsLabel),
              _MetricChip(label: 'Subtotal', value: _format(cart.subtotal)),
              _MetricChip(
                label: 'Farmacia',
                value: cart.pharmacyName ?? 'Nao definida',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final CartController cart;

  const _ProductList({required this.cart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Produtos no carrinho',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          cart.items.isEmpty
              ? 'Seu carrinho esta vazio no momento.'
              : 'Ajuste quantidades e remova itens antes de seguir para checkout.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        if (cart.items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 44,
                  color: AppColors.primary,
                ),
                SizedBox(height: 12),
                Text(
                  'Adicione medicamentos para continuar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              for (var index = 0; index < cart.items.length; index++) ...[
                CartItemTile(cartItem: cart.items[index]),
                if (index != cart.items.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
              ],
            ],
          ),
      ],
    );
  }
}

class _SuggestionsSection extends StatelessWidget {
  const _SuggestionsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sugestoes para complementar o pedido',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Itens populares entre clientes que compraram produtos semelhantes.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Consumer<HomeInventoryController>(
          builder: (_, ctrl, __) => InventorySection(
            title: '',
            items: ctrl.bestSellers.take(10).toList(),
            loading: ctrl.loading,
          ),
        ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SurfaceCard({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

String _format(double value) =>
    'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
