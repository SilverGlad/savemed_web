import 'package:flutter/material.dart';
import 'package:savemed/core/utils/document_formatter.dart';
import 'package:provider/provider.dart';

import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/controllers/order_controller.dart';
import 'package:savemed/core/services/shipping_service.dart';
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
    final isMobile = MediaQuery.of(context).size.width < 640;

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
              padding: EdgeInsets.fromLTRB(
                isMobile ? 12 : 24,
                18,
                isMobile ? 12 : 24,
                28,
              ),
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Revisar pedido', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      Text(cart.pharmacyName ?? 'Confirme os itens e a entrega'),
    ],
  );
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
              _InfoRow(label: 'Cliente', value: auth.user?.name ?? '-'),
              _InfoRow(label: 'Email', value: auth.user?.email ?? '-'),
              _InfoRow(
                label: 'Documento',
                value: formatCpfForDisplay(auth.user?.cpf),
              ),
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
                      'Retirada diretamente na farmácia.',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Não é necessário informar endereço de entrega para este pedido.',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cart.selectedAddress?.street}, ${cart.selectedAddress?.number ?? 's/n'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${cart.selectedAddress?.neighborhood ?? ''} ${cart.selectedAddress?.city} - ${cart.selectedAddress?.state}',
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'CEP ${cart.selectedAddress?.cep ?? '-'}',
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
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Próximo passo',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Ao continuar, o pedido será criado e a cobrança será iniciada na etapa de pagamento.',
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
        customerId: auth.user!.id,
        pharmacyId: cart.pharmacyId!,
        addressId: cart.selectedAddress?.id,
        shipping: cart.selectedShipping!,
        subtotal: cart.subtotal,
        items: cart.items,
      );

      if (!context.mounted) return;
      navigator.push(
        MaterialPageRoute(builder: (_) => PaymentPage(orderId: orderId)),
      );
    } catch (error) {
      if (!context.mounted) return;
      final message = error is ShippingQuoteException
          ? error.message
          : 'Não foi possível criar o pedido. Tente novamente.';
      messenger.showSnackBar(SnackBar(content: Text(message)));
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
    return shipping['description']?.toString() ?? 'Retirada na farmácia.';
  }

  if (method == 'own_delivery') {
    return shipping['description']?.toString() ??
        'Entrega realizada pela farmácia.';
  }

  final deliveryTime = shipping['delivery_time']?.toString();
  if (deliveryTime == null || deliveryTime.isEmpty) {
    return 'Prazo a confirmar';
  }

  return '$deliveryTime dias';
}
