import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:SaveMed/core/controllers/cart_controller.dart';
import 'package:SaveMed/core/controllers/auth_controller.dart';
import 'package:SaveMed/core/controllers/order_controller.dart';
import 'package:SaveMed/core/widgets/savemed_button.dart';
import 'package:SaveMed/core/widgets/savemed_header.dart';
import 'package:SaveMed/core/widgets/savemed_footer.dart';
import 'package:SaveMed/features/payment/payment_page.dart';
import 'package:SaveMed/core/utils/input_formatters.dart';

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
      backgroundColor: const Color(0xFFF4F5F7),
      body: Column(
        children: [
          SaveMedHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 900;

                      return Column(
                        children: [
                          // =========================
                          // DESKTOP
                          // =========================
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _LeftColumn(cart, auth),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 2,
                                  child: _RightColumn(context, cart, auth),
                                ),
                              ],
                            ),

                          // =========================
                          // MOBILE / TABLET
                          // =========================
                          if (!isDesktop) ...[
                            _LeftColumn(cart, auth),
                            const SizedBox(height: 16),
                            _RightColumn(context, cart, auth),
                          ],

                          const SizedBox(height: 40),
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

  String _format(double value) =>
      'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
}

/* =======================================================
 * COLUNAS
 * ======================================================= */

class _LeftColumn extends StatelessWidget {
  final CartController cart;
  final AuthController auth;

  const _LeftColumn(this.cart, this.auth);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionCard(
          title: 'Confirmação do pedido',
          child: Column(
            children: [
              _InfoRow(label: 'Cliente', value: auth.user?['NAME'] ?? '-'),
              _InfoRow(label: 'Email', value: auth.user?['EMAIL'] ?? '-'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        _SectionCard(
          title: 'Endereço de entrega',
          child: Text(
            '${cart.selectedAddress?['STREET']}, '
            '${cart.selectedAddress?['NUMBER'] ?? 's/n'}\n'
            '${cart.selectedAddress?['CITY']} - '
            '${cart.selectedAddress?['STATE']}',
          ),
        ),
        const SizedBox(height: 12),

        _SectionCard(
          title: 'Itens',
          child: Column(
            children: cart.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.item.medication.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text('${item.quantity}x'),
                    const SizedBox(width: 12),
                    Text(
                      _format(item.item.price * item.quantity),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        _SectionCard(
          title: 'Frete',
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${cart.selectedShipping?['company']['name']}'
                  ' - ${cart.selectedShipping?['name']}',
                ),
              ),
              Text(
                '${cart.selectedShipping?['delivery_time']} dias',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(width: 12),
              Text(
                _format(toDouble(cart.selectedShipping?['price'])),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _format(double value) =>
      'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
}

class _RightColumn extends StatelessWidget {
  final BuildContext parentContext;
  final CartController cart;
  final AuthController auth;

  const _RightColumn(this.parentContext, this.cart, this.auth);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionCard(
          title: 'Resumo',
          child: Column(
            children: [
              _InfoRow(label: 'Produtos', value: _format(cart.subtotal)),
              _InfoRow(
                label: 'Frete',
                value: _format(toDouble(cart.selectedShipping?['price'])),
              ),
              const Divider(),
              _InfoRow(
                label: 'Total',
                value: _format(
                  cart.subtotal + toDouble(cart.selectedShipping?['price']),
                ),
                bold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: SaveMedButton(
            label: 'Ir para pagamento',
            onPressed: cart.selectedShipping == null
                ? null
                : () async {
                    try {
                      final orderCtrl = parentContext.read<OrderController>();

                      final orderId = await orderCtrl.createOrder(
                        customerId: auth.user!['ID'],
                        pharmacyId: cart.pharmacyId!,
                        addressId: cart.selectedAddress!['ID'],
                        shipping: cart.selectedShipping!,
                        subtotal: cart.subtotal,
                      );

                      await orderCtrl.createOrderItems(orderId, cart.items);

                      Navigator.push(
                        parentContext,
                        MaterialPageRoute(
                          builder: (_) => PaymentPage(orderId: orderId),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(content: Text('Erro ao criar pedido')),
                      );
                    }
                  },
          ),
        ),
      ],
    );
  }

  String _format(double value) =>
      'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
}

/* =======================================================
 * COMPONENTES AUXILIARES
 * ======================================================= */

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
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
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
