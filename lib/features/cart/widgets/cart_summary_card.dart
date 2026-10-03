import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:savemed/core/controllers/address_controller.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/controllers/pharmacy_controller.dart';
import 'package:savemed/core/theme/app_colors.dart';
import 'package:savemed/core/widgets/address_modal.dart';
import 'package:savemed/core/widgets/address_load_notice.dart';
import 'package:savemed/core/widgets/savemed_button.dart';
import 'package:savemed/features/checkout/checkout_page.dart';

class CartSummaryCard extends StatefulWidget {
  const CartSummaryCard({super.key});

  @override
  State<CartSummaryCard> createState() => _CartSummaryCardState();
}

class _CartSummaryCardState extends State<CartSummaryCard> {
  int? _lastPharmacyId;
  Object? _lastShippingInput;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final cart = context.read<CartController>();
    final pharmacyCtrl = context.read<PharmacyController>();

    if (cart.pharmacyId != null && cart.pharmacyId != _lastPharmacyId) {
      final pharmacyId = cart.pharmacyId!;
      _lastPharmacyId = pharmacyId;
      _lastShippingInput = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || cart.pharmacyId != pharmacyId) return;
        pharmacyCtrl.loadAddress(pharmacyId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pharmacyCtrl = context.watch<PharmacyController>();
    final cart = context.watch<CartController>();
    final pharmacyCep = pharmacyCtrl.addressPharmacyId == cart.pharmacyId
        ? pharmacyCtrl.pharmacyAddress?.cep
        : null;

    _maybeCalculateShipping(pharmacyCep, cart);

    final addressCtrl = context.watch<AddressController>();
    final validOptions = [
      ...cart.localDeliveryOptions,
      ...cart.shippingOptions.where((option) => option['price'] != null),
    ];

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
                  cart.pharmacyName ?? 'Selecione itens de uma farmácia',
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
                      const Icon(
                        Icons.local_pharmacy,
                        color: Colors.white,
                        size: 18,
                      ),
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
          if (pharmacyCtrl.addressPharmacyId == cart.pharmacyId &&
              pharmacyCtrl.addressError != null) ...[
            Semantics(
              liveRegion: true,
              child: const Text(
                'Não foi possível carregar o endereço da farmácia para calcular a entrega.',
              ),
            ),
            TextButton.icon(
              onPressed: () => pharmacyCtrl.loadAddress(cart.pharmacyId!),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar carregar a farmácia novamente'),
            ),
            const SizedBox(height: 12),
          ],
          _SectionTitle(
            title: 'Endereço de entrega',
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
          if (addressCtrl.loading)
            const LinearProgressIndicator(
              semanticsLabel: 'Carregando endereços',
            )
          else if (addressCtrl.error != null)
            AddressLoadNotice(
              onRetry: context.watch<AuthController>().user == null
                  ? null
                  : () {
                      final userId = context.read<AuthController>().user?.id;
                      if (userId != null) addressCtrl.reloadForUi(userId);
                    },
            )
          else if (addressCtrl.addresses.isEmpty)
            const _MessageCard(
              icon: Icons.location_off_outlined,
              message: 'Cadastre um endereço para liberar o frete.',
            )
          else
            Column(
              children: addressCtrl.addresses.map<Widget>((address) {
                final selected = cart.selectedAddress?.id == address.id;
                return _SelectableCard(
                  selected: selected,
                  icon: Icons.location_on_outlined,
                  title: '${address.street}, ${address.number ?? 's/n'}',
                  subtitle:
                      '${address.city} - ${address.state} | CEP ${address.cep}',
                  onTap: () {
                    cart.selectAddress(address);
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
            value: _format(
              cart.subtotal + _shippingPrice(cart.selectedShipping),
            ),
            bold: true,
          ),
          const SizedBox(height: 18),
          SaveMedButton(
            label: 'Continuar compra',
            icon: Icons.east,
            onPressed:
                cart.items.isEmpty ||
                    (cart.needsDeliveryAddress &&
                        cart.selectedAddress == null) ||
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

    final userCep = cart.selectedAddress!.cep;
    final input = (cart.pharmacyId, cart.shippingInputRevision, pharmacyCep);
    if (userCep.isEmpty || _lastShippingInput == input) {
      return;
    }

    _lastShippingInput = input;
    final pharmacyId = cart.pharmacyId;
    final revision = cart.shippingInputRevision;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          cart.pharmacyId != pharmacyId ||
          cart.shippingInputRevision != revision ||
          cart.selectedAddress?.cep != userCep) {
        return;
      }
      cart.calculateShipping(pharmacyCep);
    });
  }
}

class _ShippingSection extends StatefulWidget {
  final CartController cart;
  final List<dynamic> validOptions;

  const _ShippingSection({required this.cart, required this.validOptions});

  @override
  State<_ShippingSection> createState() => _ShippingSectionState();
}

class _ShippingSectionState extends State<_ShippingSection> {
  bool _showMelhorEnvioOptions = false;

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;
    final validOptions = widget.validOptions;
    final melhorEnvioOptions = validOptions
        .where((option) => option['method'] == 'melhor_envio')
        .toList();
    final visibleOptions = validOptions
        .where((option) => option['method'] != 'melhor_envio')
        .toList();
    final selectedMelhorEnvio =
        cart.selectedShipping?['method'] == 'melhor_envio';

    if (cart.selectedAddress == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Text(
          'Selecione um endereço para calcular o frete.',
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

    if (cart.shippingError != null && validOptions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          cart.shippingError!,
          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
        ),
      );
    }

    if (validOptions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Text(
          'Nenhuma opção de entrega disponível para este endereço.',
          style: TextStyle(color: AppColors.textLight, fontSize: 13),
        ),
      );
    }

    return Column(
      children: [
        if (cart.shippingError != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              cart.shippingError!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        for (final option in visibleOptions)
          _SelectableCard(
            selected: cart.selectedShipping?['id'] == option['id'],
            icon: option['method'] == 'pickup'
                ? Icons.storefront_outlined
                : Icons.local_shipping_outlined,
            title: _shippingTitle(option),
            subtitle: _shippingSubtitle(option),
            trailing: Text(
              _format(double.tryParse(option['price'].toString()) ?? 0),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            onTap: () => cart.selectShipping(option),
          ),
        if (melhorEnvioOptions.isNotEmpty)
          _SelectableCard(
            selected: selectedMelhorEnvio,
            icon: Icons.local_shipping_outlined,
            title: 'Entrega Melhor Envio',
            subtitle: _showMelhorEnvioOptions
                ? 'Escolha uma das opções abaixo.'
                : '${melhorEnvioOptions.length} opções disponíveis a partir de ${_format(_lowestPrice(melhorEnvioOptions))}.',
            trailing: Icon(
              _showMelhorEnvioOptions
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              color: AppColors.primaryDark,
            ),
            onTap: () {
              setState(
                () => _showMelhorEnvioOptions = !_showMelhorEnvioOptions,
              );
            },
          ),
        if (_showMelhorEnvioOptions)
          for (final option in melhorEnvioOptions)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _SelectableCard(
                selected: cart.selectedShipping?['id'] == option['id'],
                icon: Icons.local_shipping_outlined,
                title: _shippingTitle(option),
                subtitle: _shippingSubtitle(option),
                trailing: Text(
                  _format(double.tryParse(option['price'].toString()) ?? 0),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                onTap: () => cart.selectShipping(option),
              ),
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
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
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
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      value: subtitle,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
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
              if (trailing != null) ...[const SizedBox(width: 10), trailing!],
            ],
          ),
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
      children: [
        Expanded(
          child: Text(label, style: style.copyWith(color: AppColors.textLight)),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(value, textAlign: TextAlign.right, style: style),
        ),
      ],
    );
  }
}

double _shippingPrice(Map<String, dynamic>? shipping) {
  if (shipping == null) return 0;
  return double.tryParse(shipping['price'].toString()) ?? 0;
}

double _lowestPrice(List<dynamic> options) {
  final prices = options
      .map((option) => double.tryParse(option['price'].toString()))
      .whereType<double>()
      .toList();

  if (prices.isEmpty) return 0;
  prices.sort();
  return prices.first;
}

String _format(double value) =>
    'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

String _shippingTitle(Map<String, dynamic> option) {
  final company = option['company']?['name']?.toString();
  final name = option['name']?.toString();

  if (company == null || company.isEmpty) {
    return name ?? 'Entrega';
  }

  if (name == null || name.isEmpty) {
    return company;
  }

  return '$company - $name';
}

String _shippingSubtitle(Map<String, dynamic> option) {
  if (option['method'] == 'pickup') {
    return option['description']?.toString() ?? 'Retirada na farmácia.';
  }

  if (option['method'] == 'own_delivery') {
    return option['description']?.toString() ??
        'Entrega realizada pela farmácia.';
  }

  final deliveryTime = option['delivery_time']?.toString();
  if (deliveryTime == null || deliveryTime.isEmpty) {
    return 'Prazo a confirmar';
  }

  return '$deliveryTime dias';
}
