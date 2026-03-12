import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:SaveMed/core/controllers/cart_controller.dart';
import 'package:SaveMed/core/controllers/address_controller.dart';
import 'package:SaveMed/core/controllers/pharmacy_controller.dart';
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

    // =========================
    // 🏥 FARMÁCIA MUDOU
    // =========================
    if (cart.pharmacyId != null && cart.pharmacyId != _lastPharmacyId) {
      _lastPharmacyId = cart.pharmacyId;

      pharmacyCtrl.loadAddress(cart.pharmacyId!);

      // limpa dependências
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

    return _buildContent(context);
  }

  void _maybeCalculateShipping(String? pharmacyCep, CartController cart) {
    if (pharmacyCep == null) return;
    if (cart.selectedAddress == null) return;
    if (cart.items.isEmpty) return;

    final userCep = cart.selectedAddress!['CEP'];
    if (userCep == null) return;

    if (_lastCalculatedCep == userCep) return;

    _lastCalculatedCep = userCep;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      cart.calculateShipping(pharmacyCep);
    });
  }

  // ======================================================
  // UI PURA (sem lógica de negócio)
  // ======================================================
  Widget _buildContent(BuildContext context) {
    final cart = context.watch<CartController>();
    final addressCtrl = context.watch<AddressController>();
    final validOptions = cart.shippingOptions
        .where((o) => o['price'] != null)
        .toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========================
          // TÍTULO
          // =========================
          const Text(
            'Resumo da compra',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          // =========================
          // FARMÁCIA
          // =========================
          if (cart.hasPharmacy) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.local_pharmacy, size: 18, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cart.pharmacyName!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // =========================
          // ENDEREÇOS
          // =========================
          if (addressCtrl.addresses.isEmpty) ...[
            const Text(
              'Cadastre um endereço para continuar',
              style: TextStyle(fontSize: 12),
            ),
          ] else ...[
            const Text(
              'Endereço de entrega',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Column(
              children: addressCtrl.addresses.map<Widget>((addr) {
                final selected = cart.selectedAddress?['ID'] == addr['ID'];

                return InkWell(
                  onTap: () {
                    cart.selectAddress(addr);
                    _lastCalculatedCep = null; // força novo cálculo
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? Colors.green : Colors.grey.shade300,
                        width: selected ? 2 : 1,
                      ),
                      color: selected
                          ? Colors.green.withOpacity(0.05)
                          : Colors.transparent,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${addr['STREET']}, ${addr['NUMBER'] ?? 's/n'}\n'
                            '${addr['CITY']} - ${addr['STATE']}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddressModal(),
              );
            },
            icon: const Icon(Icons.add_location_alt, size: 18),
            label: const Text('Novo endereço'),
          ),

          const Divider(),

          // =========================
          // RESUMO
          // =========================
          _row('Produtos (${cart.totalItems})', _format(cart.subtotal)),

          // =========================
          // FRETE
          // =========================
          if (cart.selectedAddress == null) ...[
            _row('Frete', 'Selecione um endereço'),
          ] else if (cart.loadingShipping) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Calculando frete...',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ] else if (cart.shippingOptions.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Nenhuma opção de frete disponível',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ] else ...[
            const Text(
              'Opções de frete',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            Column(
              children: validOptions.map((option) {
                final selected = cart.selectedShipping?['id'] == option['id'];

                return InkWell(
                  onTap: () => cart.selectShipping(option),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? Colors.green : Colors.grey.shade300,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${option['company']['name']} - ${option['name']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                '${option['delivery_time']} dias',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _format(
                            double.tryParse(option['price'].toString()) ?? 0.0,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const Divider(),

          // =========================
          // TOTAL
          // =========================
          _row(
            'Total',
            _format(cart.subtotal + (cart.selectedShipping?['price'] ?? 0)),
            bold: true,
          ),

          const SizedBox(height: 16),

          // =========================
          // CHECKOUT
          // =========================
          SizedBox(
            width: double.infinity,
            height: 48,
            child: SaveMedButton(
              onPressed:
                  cart.items.isEmpty ||
                      cart.selectedAddress == null ||
                      cart.selectedShipping == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CheckoutPage()),
                      );
                    },
              label: 'Continuar compra',
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // HELPERS
  // =========================
  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
          ),
        ],
      ),
    );
  }

  String _format(double value) =>
      'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
}
