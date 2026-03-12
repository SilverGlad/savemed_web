import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:SaveMed/core/controllers/card_controller.dart';
import 'package:SaveMed/core/controllers/payment_controller.dart';
import 'package:SaveMed/core/widgets/add_card_modal.dart';

import '../../core/widgets/savemed_header.dart';
import '../../core/widgets/savemed_footer.dart';
import '../../core/widgets/savemed_button.dart';
import '../../core/controllers/cart_controller.dart';
import '../../core/controllers/auth_controller.dart';
import 'payment_result_page.dart';

enum PaymentMethod { credit, debit, pix }

class PaymentPage extends StatefulWidget {
  final int orderId;

  const PaymentPage({super.key, required this.orderId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  PaymentMethod _method = PaymentMethod.credit;

  String? _pixQrCode;
  bool _pixGenerated = false;
  Timer? _pixPollingTimer;

  bool get _usesCard =>
      _method == PaymentMethod.credit || _method == PaymentMethod.debit;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CardController>().loadCards();
    });
  }

  @override
  void dispose() {
    _pixPollingTimer?.cancel();
    super.dispose();
  }

  void _resetPix() {
    _pixPollingTimer?.cancel();
    _pixGenerated = false;
    _pixQrCode = null;
  }

  void _startPixPolling(BuildContext context) {
    final paymentCtrl = context.read<PaymentController>();

    _pixPollingTimer?.cancel();

    _pixPollingTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      final status = await paymentCtrl.checkStatus(orderId: widget.orderId);

      if (status == 'paid') {
        timer.cancel();

        context.read<CartController>().clear();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const PaymentResultPage(success: true),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final auth = context.watch<AuthController>();
    final paymentCtrl = context.watch<PaymentController>();
    final cardCtrl = context.watch<CardController>();

    final total = cart.subtotal + (cart.selectedShipping?['price'] ?? 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: Column(
        children: [
          SaveMedHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pagamento',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // =========================
                          // MÉTODO
                          // =========================
                          Row(
                            children: [
                              _PaymentMethodButton(
                                label: 'Crédito',
                                icon: Icons.credit_card,
                                selected: _method == PaymentMethod.credit,
                                onTap: () => setState(() {
                                  _method = PaymentMethod.credit;
                                  _resetPix();
                                }),
                              ),
                              const SizedBox(width: 8),
                              _PaymentMethodButton(
                                label: 'Débito',
                                icon: Icons.account_balance,
                                selected: _method == PaymentMethod.debit,
                                onTap: () => setState(() {
                                  _method = PaymentMethod.debit;
                                  _resetPix();
                                }),
                              ),
                              const SizedBox(width: 8),
                              _PaymentMethodButton(
                                label: 'Pix',
                                icon: Icons.qr_code,
                                selected: _method == PaymentMethod.pix,
                                onTap: () => setState(() {
                                  _method = PaymentMethod.pix;
                                  _resetPix();
                                }),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // =========================
                          // CARTÃO
                          // =========================
                          if (_usesCard) ...[
                            if (cardCtrl.cards.isEmpty)
                              const Text('Nenhum cartão cadastrado')
                            else
                              ...cardCtrl.cards.map((card) {
                                final selected =
                                    cardCtrl.selected?.id == card.id;
                                return InkWell(
                                  onTap: () => cardCtrl.select(card),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: selected
                                            ? Colors.green
                                            : Colors.grey.shade300,
                                        width: selected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          selected
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_off,
                                          color: selected
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 12),
                                        Text('•••• ${card.last4}'),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            TextButton.icon(
                              onPressed: () => showDialog(
                                context: context,
                                builder: (_) => const AddCardModal(),
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('Adicionar cartão'),
                            ),
                          ],

                          // =========================
                          // PIX
                          // =========================
                          if (_method == PaymentMethod.pix) ...[
                            if (!_pixGenerated)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Ao confirmar, você receberá um QR Code Pix.',
                                  style: TextStyle(fontSize: 13),
                                ),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 12),

                                  // =========================
                                  // QR CODE
                                  // =========================
                                  QrImageView(
                                    data: _pixQrCode!,
                                    size: 220,
                                    backgroundColor: Colors.white,
                                  ),

                                  const SizedBox(height: 16),

                                  const Text(
                                    'Escaneie o QR Code para pagar',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // =========================
                                  // PIX COPIA E COLA
                                  // =========================
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: SelectableText(
                                      _pixQrCode!,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // =========================
                                  // BOTÃO COPIAR
                                  // =========================
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.copy),
                                      label: const Text('Copiar código Pix'),
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(text: _pixQrCode!),
                                        );

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Código Pix copiado'),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  const Text(
                                    'Aguardando confirmação do pagamento…',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                          ],

                          const Divider(height: 32),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total'),
                              Text(
                                'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          SaveMedButton(
                            icon: _method == PaymentMethod.pix
                                ? Icons.qr_code
                                : Icons.lock,
                            label: _method == PaymentMethod.pix
                                ? 'Gerar Pix'
                                : 'Pagar',
                            onPressed:
                                paymentCtrl.loading ||
                                    (_usesCard && cardCtrl.selected == null) ||
                                    (_method == PaymentMethod.pix &&
                                        _pixGenerated)
                                ? null
                                : () async {
                                    final result = await paymentCtrl.pay(
                                      orderId: widget.orderId,
                                      amount: total,
                                      method: _method,
                                      card: _usesCard
                                          ? {
                                              'number':
                                                  cardCtrl.selected!.number,
                                              'holderName':
                                                  cardCtrl.selected!.holderName,
                                              'expMonth':
                                                  cardCtrl.selected!.expMonth,
                                              'expYear':
                                                  cardCtrl.selected!.expYear,
                                              'cvv': cardCtrl.selected!.cvv,
                                            }
                                          : null,
                                      customer: {
                                        'name': auth.user?['NAME'],
                                        'email': auth.user?['EMAIL'],
                                        'document': auth.user?['CPF'],
                                        'phone': auth.user?['PHONE'],
                                        'address': {
                                          'zip_code':
                                              cart.selectedAddress!['CEP'],
                                          'city': cart.selectedAddress!['CITY'],
                                          'state':
                                              cart.selectedAddress!['STATE'],
                                          'line_1':
                                              '${cart.selectedAddress!['STREET']}, ${cart.selectedAddress!['NUMBER']}',
                                          'country': 'BR',
                                        },
                                      },
                                      deviceId: 'web-device',
                                    );

                                    // =========================
                                    // RESULTADO DO PAGAMENTO
                                    // =========================
                                    if (result['success'] == true) {
                                      // =========================
                                      // PIX
                                      // =========================
                                      if (_method == PaymentMethod.pix) {
                                        setState(() {
                                          _pixGenerated = true;
                                          _pixQrCode = result['qr_code'];
                                        });

                                        _startPixPolling(context);
                                      }
                                      // =========================
                                      // CARTÃO (CRÉDITO / DÉBITO)
                                      // =========================
                                      else {
                                        context.read<CartController>().clear();

                                        if (mounted) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const PaymentResultPage(
                                                    success: true,
                                                  ),
                                            ),
                                          );
                                        }
                                      }
                                    } else {
                                      // =========================
                                      // ❌ ERRO / RECUSA
                                      // =========================
                                      final message =
                                          result['message'] ??
                                          'Pagamento não autorizado. Tente outro cartão ou método.';

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(message),
                                          backgroundColor: Colors.red.shade600,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SaveMedFooter(),
        ],
      ),
    );
  }
}

// =========================
// BOTÃO MÉTODO
// =========================
class _PaymentMethodButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: selected
                ? Colors.green.withOpacity(0.12)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? Colors.green : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.green : Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.green : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
