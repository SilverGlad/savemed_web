import 'dart:async';

import 'package:flutter/material.dart';
import 'package:savemed/core/domain/order_status.dart';
import 'package:savemed/core/domain/payment_method.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/controllers/card_controller.dart';
import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/controllers/payment_controller.dart';
import 'package:savemed/core/theme/app_colors.dart';
import 'package:savemed/core/widgets/add_card_modal.dart';
import 'package:savemed/core/widgets/savemed_button.dart';
import 'package:savemed/core/widgets/savemed_footer.dart';
import 'package:savemed/core/widgets/savemed_header.dart';

import 'payment_result_page.dart';

class PaymentPage extends StatefulWidget {
  final int orderId;

  const PaymentPage({super.key, required this.orderId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with WidgetsBindingObserver {
  PaymentMethod _method = PaymentMethod.credit;
  String? _pixQrCode;
  bool _pixGenerated = false;
  bool _paymentPending = false;
  bool _checkingStatus = false;
  String? _statusMessage;
  Timer? _paymentPollingTimer;
  CardController? _cardController;

  bool get _usesCard =>
      _method == PaymentMethod.credit || _method == PaymentMethod.debit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _cardController?.loadCards();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    final hasCardDetails =
        _cardController?.selected != null ||
        (_cardController?.cards.isNotEmpty ?? false);
    if (!hasCardDetails) return;
    _cardController?.clear();
    if (mounted) {
      setState(() {
        _statusMessage =
            'Por segurança, os dados do cartão foram apagados. Informe-os novamente para continuar.';
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cardController ??= context.read<CardController>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _paymentPollingTimer?.cancel();
    _cardController?.clearForRouteExit();
    super.dispose();
  }

  void _resetPix() {
    _paymentPollingTimer?.cancel();
    _pixGenerated = false;
    _pixQrCode = null;
  }

  void _startPaymentPolling() {
    final paymentCtrl = context.read<PaymentController>();
    final cartController = context.read<CartController>();

    _paymentPollingTimer?.cancel();
    _paymentPollingTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      if (_checkingStatus || !mounted) return;
      _checkingStatus = true;
      final status = await paymentCtrl.checkStatus(orderId: widget.orderId);
      _checkingStatus = false;
      if (!mounted) return;

      if (PaymentStatus.fromApi(status) == PaymentStatus.failed) {
        timer.cancel();
        setState(() {
          _paymentPending = false;
          _pixGenerated = false;
          _statusMessage =
              'Pagamento não aprovado. Escolha outra forma de pagamento.';
        });
        return;
      }

      if (PaymentStatus.fromApi(status) == PaymentStatus.paid) {
        timer.cancel();
        if (!mounted) return;
        cartController.clear();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                PaymentResultPage(success: true, orderId: widget.orderId),
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
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                28,
              ),
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
          'Escolha o método e conclua a cobrança sem sair do fluxo.',
          style: TextStyle(color: AppColors.textLight),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final buttons = [
              _PaymentMethodButton(
                label: 'Crédito',
                icon: Icons.credit_card_outlined,
                selected: _method == PaymentMethod.credit,
                enabled: !_paymentPending && !paymentCtrl.loading,
                onTap: () => setState(() {
                  if (_paymentPending || paymentCtrl.loading) return;
                  _method = PaymentMethod.credit;
                  _resetPix();
                }),
              ),
              _PaymentMethodButton(
                label: 'Débito',
                icon: Icons.account_balance_wallet_outlined,
                selected: _method == PaymentMethod.debit,
                enabled: !_paymentPending && !paymentCtrl.loading,
                onTap: () => setState(() {
                  if (_paymentPending || paymentCtrl.loading) return;
                  _method = PaymentMethod.debit;
                  _resetPix();
                }),
              ),
              _PaymentMethodButton(
                label: 'Pix',
                icon: Icons.qr_code_2_outlined,
                selected: _method == PaymentMethod.pix,
                enabled: !_paymentPending && !paymentCtrl.loading,
                onTap: () => setState(() {
                  if (_paymentPending || paymentCtrl.loading) return;
                  _method = PaymentMethod.pix;
                  _resetPix();
                }),
              ),
            ];

            if (constraints.maxWidth < 420) {
              return Column(
                children: [
                  for (var index = 0; index < buttons.length; index++) ...[
                    SizedBox(width: double.infinity, child: buttons[index]),
                    if (index != buttons.length - 1) const SizedBox(height: 8),
                  ],
                ],
              );
            }

            return Row(
              children: [
                for (var index = 0; index < buttons.length; index++) ...[
                  Expanded(child: buttons[index]),
                  if (index != buttons.length - 1) const SizedBox(width: 8),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        if (_paymentPending || _statusMessage != null) ...[
          Semantics(
            liveRegion: true,
            child: Text(
              _paymentPending
                  ? (_statusMessage ??
                        'Pagamento em processamento. Aguarde a confirmação. Não pague novamente.')
                  : _statusMessage!,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (_usesCard) ...[
          const Text(
            'Por segurança, os dados do cartão não ficam salvos. Em outra tentativa, informe-os novamente.',
            style: TextStyle(color: AppColors.textLight),
          ),
          const SizedBox(height: 12),
          _CardSelectionPanel(cardCtrl: cardCtrl),
          const SizedBox(height: 18),
        ],
        if (_method == PaymentMethod.pix) ...[
          _PixPanel(pixGenerated: _pixGenerated, pixQrCode: _pixQrCode),
          const SizedBox(height: 18),
        ],
        SaveMedButton(
          icon: _method == PaymentMethod.pix
              ? Icons.qr_code
              : Icons.lock_outline,
          label: _method == PaymentMethod.pix ? 'Gerar Pix' : 'Pagar agora',
          loading: paymentCtrl.loading,
          onPressed:
              paymentCtrl.loading ||
                  _paymentPending ||
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

    final paymentRequest = paymentCtrl.pay(
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
        'name': auth.user?.name,
        'email': auth.user?.email,
        'document': auth.user?.cpf,
        'phone': auth.user?.phoneNumber,
        'address': cart.selectedAddress == null
            ? null
            : {
                'zip_code': cart.selectedAddress!.cep,
                'city': cart.selectedAddress!.city,
                'state': cart.selectedAddress!.state,
                'line_1':
                    '${cart.selectedAddress!.street}, ${cart.selectedAddress!.number ?? ''}',
                'country': 'BR',
              },
      },
      deviceId: 'web-device',
    );
    if (_usesCard) cardCtrl.clear();
    final result = await paymentRequest;

    if (!context.mounted) return;

    if (result['status'] == 'pending' || result['code'] == 'PAYMENT_PENDING') {
      setState(() => _paymentPending = true);
      _startPaymentPolling();
      return;
    }

    if (result['success'] == true) {
      if (_method == PaymentMethod.pix) {
        setState(() {
          _paymentPending = true;
          _pixGenerated = true;
          _pixQrCode = result['qr_code'];
        });
        _startPaymentPolling();
        return;
      }

      if (result['status'] != 'paid') {
        setState(() => _paymentPending = true);
        _startPaymentPolling();
        return;
      }
      context.read<CartController>().clear();
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              PaymentResultPage(success: true, orderId: widget.orderId),
        ),
      );
      return;
    }

    final message =
        result['message'] ?? 'Pagamento não autorizado. Tente outro método.';

    if (result['outcome_unknown'] == true) {
      final status = await paymentCtrl.checkStatus(orderId: widget.orderId);
      if (!context.mounted) return;

      switch (PaymentStatus.fromApi(status)) {
        case PaymentStatus.paid:
          cart.clear();
          navigator.pushReplacement(
            MaterialPageRoute(
              builder: (_) =>
                  PaymentResultPage(success: true, orderId: widget.orderId),
            ),
          );
          return;
        case PaymentStatus.failed:
          break;
        case PaymentStatus.pending:
        case PaymentStatus.refunded:
        case PaymentStatus.unknown:
          setState(() {
            _paymentPending = true;
            _statusMessage = status == 'pending'
                ? 'Pagamento em processamento. Aguarde a confirmação. Não pague novamente.'
                : 'Não foi possível confirmar o resultado da cobrança. Estamos verificando; não tente pagar novamente.';
          });
          _startPaymentPolling();
          return;
      }
    }

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
  const _PaymentHero({required this.total, required this.orderId});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Pagamento', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      Text(
        'Pedido #$orderId • ${_format(total)}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    ],
  );
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
        borderRadius: BorderRadius.circular(8),
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
              _SummaryRow(label: 'Método', value: method.name.toUpperCase()),
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
                'Segurança',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 14),
              _SecurityItem(
                icon: Icons.verified_user_outlined,
                text: 'Dados sensíveis trafegam apenas na etapa de cobrança.',
              ),
              SizedBox(height: 12),
              _SecurityItem(
                icon: Icons.qr_code_2_outlined,
                text:
                    'Pix fica disponível com copia e cola e verificação de status.',
              ),
              SizedBox(height: 12),
              _SecurityItem(
                icon: Icons.local_shipping_outlined,
                text:
                    'O pedido permanece associado ao endereço e frete selecionados.',
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

  const _SecurityItem({required this.icon, required this.text});

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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cartões para esta tentativa',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          if (cardCtrl.cards.isEmpty)
            const Text(
              'Nenhum cartão informado.',
              style: TextStyle(color: AppColors.textLight),
            )
          else
            ...cardCtrl.cards.map((card) {
              final selected = cardCtrl.selected?.id == card.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: 'Cartão terminado em ${card.last4}',
                  onTap: () => cardCtrl.select(card),
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => cardCtrl.select(card),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.surfaceMuted : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                          width: selected ? 1.4 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.check_circle
                                : Icons.credit_card_outlined,
                            color: selected
                                ? AppColors.primaryDark
                                : AppColors.primary,
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
            label: const Text('Adicionar cartão'),
          ),
        ],
      ),
    );
  }
}

class _PixPanel extends StatelessWidget {
  final bool pixGenerated;
  final String? pixQrCode;

  const _PixPanel({required this.pixGenerated, required this.pixQrCode});

  @override
  Widget build(BuildContext context) {
    if (!pixGenerated) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Ao confirmar, você receberá um QR Code Pix com copia e cola.',
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) => QrImageView(
              data: pixQrCode!,
              size: constraints.maxWidth.clamp(0, 220),
              backgroundColor: Colors.white,
            ),
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
              borderRadius: BorderRadius.circular(8),
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
                  const SnackBar(content: Text('Código Pix copiado')),
                );
              },
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copiar código Pix'),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aguardando confirmação do pagamento...',
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
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textLight),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                color: AppColors.textDark,
              ),
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
  final bool enabled;
  final VoidCallback onTap;

  const _PaymentMethodButton({
    required this.label,
    required this.icon,
    required this.selected,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: '$label, forma de pagamento',
      onTap: enabled ? onTap : null,
      excludeSemantics: true,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 54,
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceMuted : AppColors.background,
            borderRadius: BorderRadius.circular(8),
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
