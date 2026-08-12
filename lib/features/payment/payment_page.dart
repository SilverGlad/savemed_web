import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:SaveMed/core/controllers/auth_controller.dart';
import 'package:SaveMed/core/controllers/card_controller.dart';
import 'package:SaveMed/core/controllers/cart_controller.dart';
import 'package:SaveMed/core/controllers/payment_controller.dart';
import 'package:SaveMed/core/theme/app_colors.dart';
import 'package:SaveMed/core/widgets/add_card_modal.dart';
import 'package:SaveMed/core/widgets/savemed_button.dart';
import 'package:SaveMed/core/widgets/savemed_footer.dart';
import 'package:SaveMed/core/widgets/savemed_header.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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

  void _startPixPolling() {
    final paymentCtrl = context.read<PaymentController>();
    final cartController = context.read<CartController>();

    _pixPollingTimer?.cancel();
    _pixPollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final status = await paymentCtrl.checkStatus(orderId: widget.orderId);

      if (status == 'paid') {
        timer.cancel();
        if (!mounted) return;
        cartController.clear();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const PaymentResultPage(success: true),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final auth = context.watch<AuthController>();
    final paymentCtrl = context.watch<PaymentController>();
    final cardCtrl = context.watch<CardController>();
    final total = cart.subtotal + _shippingPrice(cart.selectedShipping);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 960;
    final horizontalPadding = width < 640 ? 12.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SaveMedHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 18, horizontalPadding, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PaymentHero(total: total, orderId: widget.orderId),
                      const SizedBox(height: 20),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: _PaymentPanel(
                                child: _buildPaymentBody(
                                  context,
                                  auth: auth,
                                  cart: cart,
                                  cardCtrl: cardCtrl,
                                  paymentCtrl: paymentCtrl,
                                  total: total,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 4,
                              child: _PaymentSidebar(
                                cart: cart,
                                total: total,
                                method: _method,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _PaymentPanel(
                          child: _buildPaymentBody(
                            context,
                            auth: auth,
                            cart: cart,
                            cardCtrl: cardCtrl,
                            paymentCtrl: paymentCtrl,
                            total: total,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _PaymentSidebar(
                          cart: cart,
                          total: total,
                          method: _method,
                        ),
                      ],
                      const SizedBox(height: 28),
                      const SaveMedFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBody(
    BuildContext context, {
    required AuthController auth,
    required CartController cart,
    required CardController cardCtrl,
    required PaymentController paymentCtrl,
    required double total,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Forma de pagamento',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Escolha o metodo e conclua a cobranca sem sair do fluxo.',
          style: TextStyle(color: AppColors.textLight),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _PaymentMethodButton(
              label: 'Credito',
              icon: Icons.credit_card_outlined,
              selected: _method == PaymentMethod.credit,
              onTap: () => setState(() {
                _method = PaymentMethod.credit;
                _resetPix();
              }),
            ),
            const SizedBox(width: 8),
            _PaymentMethodButton(
              label: 'Debito',
              icon: Icons.account_balance_wallet_outlined,
              selected: _method == PaymentMethod.debit,
              onTap: () => setState(() {
                _method = PaymentMethod.debit;
                _resetPix();
              }),
            ),
            const SizedBox(width: 8),
            _PaymentMethodButton(
              label: 'Pix',
              icon: Icons.qr_code_2_outlined,
              selected: _method == PaymentMethod.pix,
              onTap: () => setState(() {
                _method = PaymentMethod.pix;
                _resetPix();
              }),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_usesCard) ...[
          _CardSelectionPanel(cardCtrl: cardCtrl),
          const SizedBox(height: 18),
        ],
        if (_method == PaymentMethod.pix) ...[
          _PixPanel(
            pixGenerated: _pixGenerated,
            pixQrCode: _pixQrCode,
          ),
          const SizedBox(height: 18),
        ],
        SaveMedButton(
          icon: _method == PaymentMethod.pix ? Icons.qr_code : Icons.lock_outline,
          label: _method == PaymentMethod.pix ? 'Gerar Pix' : 'Pagar agora',
          loading: paymentCtrl.loading,
          onPressed: paymentCtrl.loading ||
                  (_usesCard && cardCtrl.selected == null) ||
                  (_method == PaymentMethod.pix && _pixGenerated)
              ? null
              : () => _handlePayment(
                    context,
                    auth: auth,
                    cart: cart,
                    cardCtrl: cardCtrl,
                    paymentCtrl: paymentCtrl,
                    total: total,
                  ),
        ),
      ],
    );
  }

  Future<void> _handlePayment(
    BuildContext context, {
    required AuthController auth,
    required CartController cart,
    required CardController cardCtrl,
    required PaymentController paymentCtrl,
    required double total,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final result = await paymentCtrl.pay(
      orderId: widget.orderId,
      amount: total,
      method: _method,
      card: _usesCard
          ? {
              'number': cardCtrl.selected!.number,
              'holderName': cardCtrl.selected!.holderName,
              'expMonth': cardCtrl.selected!.expMonth,
              'expYear': cardCtrl.selected!.expYear,
              'cvv': cardCtrl.selected!.cvv,
            }
          : null,
      customer: {
        'name': auth.user?['NAME'],
        'email': auth.user?['EMAIL'],
        'document': auth.user?['CPF'],
        'phone': auth.user?['PHONE_NUMBER'],
        'address': {
          'zip_code': cart.selectedAddress!['CEP'],
          'city': cart.selectedAddress!['CITY'],
          'state': cart.selectedAddress!['STATE'],
          'line_1':
              '${cart.selectedAddress!['STREET']}, ${cart.selectedAddress!['NUMBER']}',
          'country': 'BR',
        },
      },
      deviceId: 'web-device',
    );

    if (!context.mounted) return;

    if (result['success'] == true) {
      if (_method == PaymentMethod.pix) {
        setState(() {
          _pixGenerated = true;
          _pixQrCode = result['qr_code'];
        });
        _startPixPolling();
        return;
      }

      context.read<CartController>().clear();
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => const PaymentResultPage(success: true),
        ),
      );
      return;
    }

    final message =
        result['message'] ??
        'Pagamento nao autorizado. Tente outro metodo.';

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _PaymentHero extends StatelessWidget {
  final double total;
  final int orderId;

  const _PaymentHero({
    required this.total,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF183631), Color(0xFF0F8B6E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedido #$orderId',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Finalize o pagamento com seguranca.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pix gera QR Code imediatamente. Cartao conclui a cobranca no mesmo fluxo.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total a pagar',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _format(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentPanel extends StatelessWidget {
  final Widget child;

  const _PaymentPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
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

class _PaymentSidebar extends StatelessWidget {
  final CartController cart;
  final double total;
  final PaymentMethod method;

  const _PaymentSidebar({
    required this.cart,
    required this.total,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PaymentPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              _SummaryRow(label: 'Produtos', value: _format(cart.subtotal)),
              _SummaryRow(
                label: 'Frete',
                value: _format(_shippingPrice(cart.selectedShipping)),
              ),
              _SummaryRow(
                label: 'Metodo',
                value: method.name.toUpperCase(),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: AppColors.border),
              ),
              _SummaryRow(label: 'Total', value: _format(total), bold: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PaymentPanel(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seguranca',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 14),
              _SecurityItem(
                icon: Icons.verified_user_outlined,
                text: 'Dados sensiveis trafegam apenas na etapa de cobranca.',
              ),
              SizedBox(height: 12),
              _SecurityItem(
                icon: Icons.qr_code_2_outlined,
                text: 'Pix fica disponivel com copia e cola e verificacao de status.',
              ),
              SizedBox(height: 12),
              _SecurityItem(
                icon: Icons.local_shipping_outlined,
                text: 'O pedido permanece associado ao endereco e frete selecionados.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SecurityItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SecurityItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _CardSelectionPanel extends StatelessWidget {
  final CardController cardCtrl;

  const _CardSelectionPanel({required this.cardCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cartoes salvos',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          if (cardCtrl.cards.isEmpty)
            const Text(
              'Nenhum cartao cadastrado.',
              style: TextStyle(color: AppColors.textLight),
            )
          else
            ...cardCtrl.cards.map((card) {
              final selected = cardCtrl.selected?.id == card.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => cardCtrl.select(card),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.surfaceMuted : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: selected ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.check_circle
                              : Icons.credit_card_outlined,
                          color: selected ? AppColors.primaryDark : AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '•••• ${card.last4}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const AddCardModal(),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar cartao'),
          ),
        ],
      ),
    );
  }
}

class _PixPanel extends StatelessWidget {
  final bool pixGenerated;
  final String? pixQrCode;

  const _PixPanel({
    required this.pixGenerated,
    required this.pixQrCode,
  });

  @override
  Widget build(BuildContext context) {
    if (!pixGenerated) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          'Ao confirmar, voce recebera um QR Code Pix com copia e cola.',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          QrImageView(
            data: pixQrCode!,
            size: 220,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Escaneie o QR Code para pagar',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: SelectableText(
              pixQrCode!,
              style: const TextStyle(fontSize: 12, color: AppColors.textDark),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: pixQrCode!));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Codigo Pix copiado')),
                );
              },
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copiar codigo Pix'),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aguardando confirmacao do pagamento...',
            style: TextStyle(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textLight),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 54,
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceMuted : AppColors.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppColors.primaryDark : AppColors.textLight,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.primaryDark : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double _shippingPrice(Map<String, dynamic>? shipping) {
  if (shipping == null) return 0;
  return double.tryParse(shipping['price'].toString()) ?? 0;
}

String _format(double value) =>
    'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
