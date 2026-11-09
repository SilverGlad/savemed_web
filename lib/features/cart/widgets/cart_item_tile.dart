import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/theme/app_colors.dart';
import 'package:savemed/models/cart_item.dart';

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;

  const CartItemTile({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartController>();
    final item = cartItem.item;
    final isMobile = MediaQuery.of(context).size.width < 720;

    return isMobile
        ? _MobileCartItem(cart: cart, cartItem: cartItem)
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ProductImage(imageUrl: item.medication.image),
              const SizedBox(width: 16),
              Expanded(
                child: _ItemInfo(
                  name: item.medication.name,
                  unitPrice: item.price,
                  onRemove: () => cart.remove(cartItem),
                ),
              ),
              const SizedBox(width: 16),
              _QuantitySelector(
                quantity: cartItem.quantity,
                onDecrease: () => cart.decrease(cartItem),
                onIncrease: cart.canIncrease(cartItem)
                    ? () => cart.increase(cartItem)
                    : null,
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 108,
                child: Text(
                  _format(item.price * cartItem.quantity),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          );
  }
}

class _MobileCartItem extends StatelessWidget {
  final CartController cart;
  final CartItem cartItem;

  const _MobileCartItem({required this.cart, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final item = cartItem.item;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(imageUrl: item.medication.image),
              const SizedBox(width: 12),
              Expanded(
                child: _ItemInfo(
                  name: item.medication.name,
                  unitPrice: item.price,
                  onRemove: () => cart.remove(cartItem),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _QuantitySelector(
                quantity: cartItem.quantity,
                onDecrease: () => cart.decrease(cartItem),
                onIncrease: cart.canIncrease(cartItem)
                    ? () => cart.increase(cartItem)
                    : null,
              ),
              Text(
                _format(item.price * cartItem.quantity),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFF4FBF8), Color(0xFFE7F4F1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const Center(
                        child: Icon(
                          Icons.medication_outlined,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      ),
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.medication_outlined,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
              ),
            )
          : const Icon(
              Icons.medication_outlined,
              color: AppColors.primary,
              size: 36,
            ),
    );
  }
}

class _ItemInfo extends StatelessWidget {
  final String name;
  final double unitPrice;
  final VoidCallback onRemove;

  const _ItemInfo({
    required this.name,
    required this.unitPrice,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Unitário ${_format(unitPrice)}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: onRemove,
          style: TextButton.styleFrom(
            minimumSize: const Size(44, 44),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          child: const Text(
            'Remover do carrinho',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback? onIncrease;

  const _QuantitySelector({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.remove,
            tooltip: 'Diminuir quantidade',
            onTap: onDecrease,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          _QtyButton(
            icon: Icons.add,
            tooltip: onIncrease == null
                ? 'Limite do estoque disponível'
                : 'Aumentar quantidade',
            onTap: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _QtyButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, size: 18),
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surfaceMuted,
        foregroundColor: AppColors.primaryDark,
      ),
    );
  }
}

String _format(double value) =>
    'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
