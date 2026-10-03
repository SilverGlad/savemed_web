import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/controllers/home_inventory_controller.dart';
import 'package:savemed/core/theme/app_colors.dart';
import 'package:savemed/core/utils/money_formatter.dart';
import 'package:savemed/core/widgets/inventory_section.dart';
import 'package:savemed/core/widgets/savemed_footer.dart';
import 'package:savemed/core/widgets/savemed_header.dart';
import 'package:savemed/features/cart/widgets/cart_item_tile.dart';
import 'package:savemed/features/cart/widgets/cart_summary_card.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _summaryKey = GlobalKey();

  void _reviewOrder() {
    final summaryContext = _summaryKey.currentContext;
    if (summaryContext == null) return;
    Scrollable.ensureVisible(
      summaryContext,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1040;
    final horizontalPadding = width < 640 ? 12.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar:
          isDesktop || MediaQuery.viewInsetsOf(context).bottom > 0
          ? null
          : Consumer<CartController>(
              builder: (context, cart, _) => cart.items.isEmpty
                  ? const SizedBox.shrink()
                  : _CartReviewBar(cart: cart, onReview: _reviewOrder),
            ),
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
                                Expanded(
                                  flex: 4,
                                  child: CartSummaryCard(key: _summaryKey),
                                ),
                              ],
                            )
                          else ...[
                            _SurfaceCard(
                              padding: const EdgeInsets.all(18),
                              child: _ProductList(cart: cart),
                            ),
                            const SizedBox(height: 16),
                            if (cart.items.isNotEmpty)
                              CartSummaryCard(key: _summaryKey),
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

class _CartReviewBar extends StatelessWidget {
  final CartController cart;
  final VoidCallback onReview;

  const _CartReviewBar({required this.cart, required this.onReview});

  @override
  Widget build(BuildContext context) {
    final subtotal = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Subtotal dos produtos', style: TextStyle(fontSize: 12)),
        Text(
          formatBrl(cart.subtotal),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ],
    );
    final review = FilledButton.icon(
      onPressed: onReview,
      icon: const Icon(Icons.receipt_long_outlined),
      label: const Text('Revisar pedido'),
    );
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < 360 ||
                  MediaQuery.textScalerOf(context).scale(14) > 18;
              if (stacked) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [subtotal, const SizedBox(height: 8), review],
                );
              }
              return Row(
                children: [
                  Expanded(child: subtotal),
                  const SizedBox(width: 12),
                  Flexible(child: review),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CartHero extends StatelessWidget {
  final CartController cart;
  const _CartHero({required this.cart});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Meu carrinho', style: Theme.of(context).textTheme.headlineSmall),
      if (cart.items.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text('${cart.totalItems} itens • ${cart.pharmacyName ?? ''}'),
      ],
    ],
  );
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
              ? 'Seu carrinho está vazio no momento.'
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
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 44,
                  color: AppColors.primary,
                ),
                SizedBox(height: 12),
                const Text(
                  'Adicione medicamentos para continuar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  icon: const Icon(Icons.storefront_outlined),
                  label: const Text('Ver produtos'),
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
          'Sugestões para complementar o pedido',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Outros produtos disponíveis no catálogo.',
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
        borderRadius: BorderRadius.circular(8),
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
