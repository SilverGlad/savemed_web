import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SaveMed/core/controllers/cart_controller.dart';
import 'package:SaveMed/models/cart_item.dart';

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;

  const CartItemTile({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartController>();
    final item = cartItem.item;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IMAGEM
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade100,
          ),
          child: item.medication.image != null
              ? Image.network(item.medication.image!, fit: BoxFit.contain)
              : const Icon(Icons.image, size: 40),
        ),

        const SizedBox(width: 16),

        // INFO
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.medication.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => cart.remove(cartItem),
                child: const Text(
                  'Excluir',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // QUANTIDADE
        Row(
          children: [
            _qtyButton(Icons.remove, onTap: () => cart.decrease(cartItem)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('${cartItem.quantity}'),
            ),
            _qtyButton(Icons.add, onTap: () => cart.increase(cartItem)),
          ],
        ),

        const SizedBox(width: 24),

        // PREÇO
        Text(
          _format(item.price * cartItem.quantity),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _qtyButton(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green),
        ),
        child: Icon(icon, size: 16, color: Colors.green),
      ),
    );
  }

  String _format(double value) =>
      'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
}
