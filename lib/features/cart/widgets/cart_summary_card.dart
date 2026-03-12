import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:SaveMed/core/controllers/address_controller.dart';
import 'package:SaveMed/core/controllers/cart_controller.dart';
import 'package:SaveMed/core/controllers/pharmacy_controller.dart';
import 'package:SaveMed/core/theme/app_colors.dart';
import 'package:SaveMed/core/widgets/address_modal.dart';
import 'package:SaveMed/core/widgets/savemed_button.dart';
import 'package:SaveMed/features/checkout/checkout_page.dart';

class CartSummaryCard extends StatefulWidget {
  const CartSummaryCard({super.key});

  @override
  State<CartSummaryCard> createState() => _CartSummaryCardState();
}

class _CartSummaryCardState extends State<CartSummaryCard> {
  int? _lastPharmacyId;
  String? _lastCalculatedCep;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final cart = context.read<CartController>();
    final pharmacyCtrl = context.read<PharmacyController>();

    if (cart.pharmacyId != null && cart.pharmacyId != _lastPharmacyId) {
      _lastPharmacyId = cart.pharmacyId;
      pharmacyCtrl.loadAddress(cart.pharmacyId!);
      cart.clearAddress();
      _lastCalculatedCep = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pharmacyCep = context.select<PharmacyController, String?>(
      (ctrl) => ctrl.pharmacyAddress?['CEP'],
    );
    final cart = context.watch<CartController>();

    _maybeCalculateShipping(pharmacyCep, cart);

    final addressCtrl = context.watch<AddressController>();
    final validOptions = cart.shippingOptions
        .where((option) => option['price'] != null)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [Color(0xFF163A33), Color(0xFF1E6E5B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumo da compra',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cart.pharmacyName ?? 'Selecione itens de uma farmacia',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (cart.hasPharmacy) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.local_pharmacy, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cart.pharmacyName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle(
            title: 'Endereco de entrega',
            action: TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AddressModal(),
                );
              },
              icon: const Icon(Icons.add_location_alt_outlined, size: 18),
              label: const Text('Novo'),
            ),
          ),
          if (addressCtrl.addresses.isEmpty)
            const _MessageCard(
              icon: Icons.location_off_outlined,
              message: 'Cadastre um endereco para liberar o frete.',
            )
          else
            Column(
              children: addressCtrl.addresses.map<Widget>((address) {
                final selected = cart.selectedAddress?['ID'] == address['ID'];
                return _SelectableCard(
                  selected: selected,
                  icon: Icons.location_on_outlined,
                  title:
                      '${address['STREET']}, ${address['NUMBER'] ?? 's/n'}',
                  subtitle:
                      '${address['CITY']} - ${address['STATE']} | CEP ${address['CEP']}',
                  onTap: () {
                    cart.selectAddress(address);
                    _lastCalculatedCep = null;
                  },
                );
              }).toList(),
            ),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Resumo financeiro'),
          _ValueRow(
            label: 'Produtos (${cart.totalItems})',
            value: _format(cart.subtotal),
          ),
          const SizedBox(height: 6),
          _ShippingSection(cart: cart, validOptions: validOptions),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _ValueRow(
            label: 'Total',
            value: _format(cart.subtotal + _shippingPrice(cart.selectedShipping)),
            bold: true,
          ),
          const SizedBox(height: 18),
          SaveMedButton(
            label: 'Continuar compra',
            icon: Icons.east,
            onPressed: cart.items.isEmpty ||
                    cart.selectedAddress == null ||
                    cart.selectedShipping == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckoutPage()),
                    );
                  },
          ),
        ],
      ),
    );
  }

  void _maybeCalculateShipping(String? pharmacyCep, CartController cart) {
    if (pharmacyCep == null ||
        cart.selectedAddress == null ||
        cart.items.isEmpty) {
      return;
    }

    final userCep = cart.selectedAddress!['CEP'];
    if (userCep == null || _lastCalculatedCep == userCep) {
      return;
    }

    _lastCalculatedCep = userCep;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      cart.calculateShipping(pharmacyCep);
    });
  }
}

class _ShippingSection extends StatelessWidget {
  final CartController cart;
  final List<dynamic> validOptions;

  const _ShippingSection({
    required this.cart,
    required this.validOptions,
  });

  @override
  Widget build(BuildContext context) {
    if (cart.selectedAddress == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Text(
          'Selecione um endereco para calcular o frete.',
          style: TextStyle(color: AppColors.textLight, fontSize: 13),
        ),
      );
    }

    if (cart.loadingShipping) {
      return const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text(
              'Calculando frete...',
              style: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (validOptions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Text(
          'Nenhuma opcao de entrega disponivel para este endereco.',
          style: TextStyle(color: AppColors.textLight, fontSize: 13),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        for (final option in validOptions)
          _SelectableCard(
            selected: cart.selectedShipping?['id'] == option['id'],
            icon: Icons.local_shipping_outlined,
            title: '${option['company']['name']} - ${option['name']}',
            subtitle: '${option['delivery_time']} dias',
            trailing: Text(
              _format(double.tryParse(option['price'].toString()) ?? 0),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            onTap: () => cart.selectShipping(option),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;

  const _SectionTitle({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class _SelectableCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceMuted : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected ? Icons.check_circle : icon,
                size: 20,
                color: selected ? AppColors.primaryDark : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 10),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _MessageCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryDark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _ValueRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
      color: AppColors.textDark,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style.copyWith(color: AppColors.textLight)),
        Text(value, style: style),
      ],
    );
  }
}

double _shippingPrice(Map<String, dynamic>? shipping) {
  if (shipping == null) return 0;
  return double.tryParse(shipping['price'].toString()) ?? 0;
}

String _format(double value) =>
    'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
