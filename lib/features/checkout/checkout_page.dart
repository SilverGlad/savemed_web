import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/controllers/order_controller.dart';
import 'package:savemed/core/theme/app_colors.dart';
import 'package:savemed/core/widgets/savemed_button.dart';
import 'package:savemed/core/widgets/savemed_footer.dart';
import 'package:savemed/core/widgets/savemed_header.dart';
import 'package:savemed/features/payment/payment_page.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final auth = context.watch<AuthController>();

    if (cart.items.isEmpty) {
      return const Scaffold(body: Center(child: Text('Carrinho vazio')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SaveMedHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1160),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 980;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CheckoutHero(cart: cart),
                          const SizedBox(height: 20),
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _LeftColumn(cart: cart, auth: auth),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 4,
                                  child: _RightColumn(cart: cart, auth: auth),
                                ),
                              ],
                            )
                          else ...[
                            _LeftColumn(cart: cart, auth: auth),
                            const SizedBox(height: 16),
                            _RightColumn(cart: cart, auth: auth),
                          ],
                          const SizedBox(height: 28),
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

class _CheckoutHero extends StatelessWidget {
  final CartController cart;

  const _CheckoutHero({required this.cart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FFFD), Color(0xFFE3F4EF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        runSpacing: 14,
        spacing: 14,
        alignment: WrapAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Checkout',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Confirme entrega, itens e valores antes do pagamento.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'O fluxo esta organizado para leitura rapida no celular, sem esconder informacoes importantes.',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeroPill(
                label: 'Itens',
                value: '${cart.totalItems}',
                icon: Icons.shopping_bag_outlined,
              ),
              _HeroPill(
                label: 'Frete',
                value: _format(_shippingPrice(cart.selectedShipping)),
                icon: Icons.local_shipping_outlined,
              ),
              _HeroPill(
                label: 'Total',
                value: _format(
                  cart.subtotal + _shippingPrice(cart.selectedShipping),
                ),
                icon: Icons.payments_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeroPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 20),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftColumn extends StatelessWidget {
  final CartController cart;
  final AuthController auth;

  const _LeftColumn({required this.cart, required this.auth});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionCard(
          title: 'Dados do cliente',
          icon: Icons.person_outline,
          child: Column(
            children: [
              _InfoRow(label: 'Cliente', value: auth.user?['NAME'] ?? '-'),
              _InfoRow(label: 'Email', value: auth.user?['EMAIL'] ?? '-'),
              _InfoRow(label: 'Documento', value: auth.user?['CPF'] ?? '-'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: cart.isPickupSelected ? 'Retirada' : 'Entrega',
          icon: Icons.location_on_outlined,
          child: cart.isPickupSelected
              ? const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Retirada diretamente na farmacia.',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Nao e necessario informar endereco de entrega para este pedido.',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cart.selectedAddress?['STREET']}, ${cart.selectedAddress?['NUMBER'] ?? 's/n'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${cart.selectedAddress?['NEIGHBORHOOD'] ?? ''} ${cart.selectedAddress?['CITY']} - ${cart.selectedAddress?['STATE']}',
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'CEP ${cart.selectedAddress?['CEP'] ?? '-'}',
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Itens do pedido',
          icon: Icons.receipt_long_outlined,
          child: Column(
            children: cart.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.medication_outlined,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.item.medication.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.quantity}x unidades',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _format(item.item.price * item.quantity),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Frete selecionado',
          icon: Icons.local_shipping_outlined,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _shippingTitle(cart.selectedShipping),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _shippingSubtitle(cart.selectedShipping),
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
              Text(
                _format(_shippingPrice(cart.selectedShipping)),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RightColumn extends StatelessWidget {
  final CartController cart;
  final AuthController auth;

  const _RightColumn({required this.cart, required this.auth});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionCard(
          title: 'Resumo final',
          icon: Icons.summarize_outlined,
          child: Column(
            children: [
              _InfoRow(label: 'Produtos', value: _format(cart.subtotal)),
              _InfoRow(
                label: 'Frete',
                value: _format(_shippingPrice(cart.selectedShipping)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: AppColors.border),
              ),
              _InfoRow(
                label: 'Total',
                value: _format(
                  cart.subtotal + _shippingPrice(cart.selectedShipping),
                ),
                bold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF173630),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Proximo passo',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Ao continuar, o pedido sera criado e a cobranca sera iniciada na etapa de pagamento.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SaveMedButton(
          label: 'Ir para pagamento',
          icon: Icons.lock_outline,
          onPressed: cart.selectedShipping == null
              ? null
              : () => _submitOrder(context),
        ),
      ],
    );
  }

  Future<void> _submitOrder(BuildContext context) async {
    final orderCtrl = context.read<OrderController>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final orderId = await orderCtrl.createOrder(
        customerId: auth.user!['ID'],
        pharmacyId: cart.pharmacyId!,
        addressId: cart.selectedAddress?['ID'],
        shipping: cart.selectedShipping!,
        subtotal: cart.subtotal,
      );

      await orderCtrl.createOrderItems(orderId, cart.items);

      if (!context.mounted) return;
      navigator.push(
        MaterialPageRoute(builder: (_) => PaymentPage(orderId: orderId)),
      );
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Erro ao criar pedido')),
      );
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _InfoRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textLight)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _format(double value) =>
    'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

double _shippingPrice(Map<String, dynamic>? shipping) {
  if (shipping == null) return 0;
  return double.tryParse(shipping['price'].toString()) ?? 0;
}

String _shippingTitle(Map<String, dynamic>? shipping) {
  if (shipping == null) return '-';

  final company = shipping['company']?['name']?.toString();
  final name = shipping['name']?.toString();

  if (company == null || company.isEmpty) {
    return name ?? 'Entrega';
  }

  if (name == null || name.isEmpty) {
    return company;
  }

  return '$company - $name';
}

String _shippingSubtitle(Map<String, dynamic>? shipping) {
  if (shipping == null) return '-';

  final method = shipping['method']?.toString();
  if (method == 'pickup') {
    return shipping['description']?.toString() ?? 'Retirada na farmacia.';
  }

  if (method == 'own_delivery') {
    return shipping['description']?.toString() ??
        'Entrega realizada pela farmacia.';
  }

  final deliveryTime = shipping['delivery_time']?.toString();
  if (deliveryTime == null || deliveryTime.isEmpty) {
    return 'Prazo a confirmar';
  }

  return '$deliveryTime dias';
}
