import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:savemed/core/utils/input_formatters.dart';
import 'package:savemed/models/payment_card.dart';
import 'package:uuid/uuid.dart';

import '../../../core/controllers/card_controller.dart';
import '../../../core/widgets/savemed_button.dart';

class AddCardModal extends StatefulWidget {
  const AddCardModal({super.key});

  @override
  State<AddCardModal> createState() => _AddCardModalState();
}

class _AddCardModalState extends State<AddCardModal>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _numberCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  String _brand = '';
  String _last4 = '••••';
  String? _securityMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clearEntryFields();
    _numberCtrl.dispose();
    _nameCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed || !mounted) return;
    _clearEntryFields(resetForm: true);
    setState(() {
      _securityMessage =
          'Por segurança, os dados do cartão foram apagados. Insira novamente para continuar.';
    });
  }

  void _clearEntryFields({bool resetForm = false}) {
    if (resetForm) _formKey.currentState?.reset();
    _numberCtrl.clear();
    _nameCtrl.clear();
    _expCtrl.clear();
    _cvvCtrl.clear();
    _brand = '';
    _last4 = '••••';
  }

  void _updateCardPreview() {
    _securityMessage = null;
    final number = _numberCtrl.text.replaceAll(RegExp(r'\D'), '');

    if (number.isNotEmpty) {
      _last4 = number.length >= 4
          ? number.substring(number.length - 4)
          : number;
      _brand = _detectBrand(number);
    } else {
      _last4 = '••••';
      _brand = '';
    }

    setState(() {});
  }

  String _detectBrand(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5')) return 'Mastercard';
    if (number.startsWith('3')) return 'Amex';
    if (number.startsWith('6')) return 'Elo';
    return '';
  }

  String? _validateCardNumber(String? value) {
    final number = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (number.length < 13 || number.length > 19) {
      return 'O número deve ter entre 13 e 19 dígitos.';
    }

    var sum = 0;
    var doubleDigit = false;
    for (var index = number.length - 1; index >= 0; index--) {
      var digit = int.parse(number[index]);
      if (doubleDigit) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      doubleDigit = !doubleDigit;
    }
    return sum % 10 == 0 ? null : 'Confira o número do cartão.';
  }

  String? _validateExpiration(String? value) {
    final parts = (value ?? '').split('/');
    if (parts.length != 2 || parts[0].length != 2 || parts[1].length != 2) {
      return 'Informe a validade no formato MM/AA.';
    }
    final month = int.tryParse(parts[0]);
    final shortYear = int.tryParse(parts[1]);
    if (month == null || month < 1 || month > 12 || shortYear == null) {
      return 'Informe um mês entre 01 e 12.';
    }

    final year = 2000 + shortYear;
    final now = DateTime.now();
    if (year < now.year || (year == now.year && month < now.month)) {
      return 'Este cartão está vencido.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 400;
    final expirationField = TextFormField(
      controller: _expCtrl,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        expiryDateFormatter,
      ],
      decoration: const InputDecoration(
        labelText: 'Validade',
        hintText: 'MM/AA',
      ),
      onChanged: (_) => setState(() => _securityMessage = null),
      validator: _validateExpiration,
    );
    final cvvField = TextFormField(
      controller: _cvvCtrl,
      keyboardType: TextInputType.number,
      obscureText: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      decoration: const InputDecoration(labelText: 'CVV'),
      onChanged: (_) => setState(() => _securityMessage = null),
      validator: (value) {
        final cvv = value ?? '';
        return cvv.length == 3 || cvv.length == 4
            ? null
            : 'Informe um CVV de 3 ou 4 dígitos.';
      },
    );

    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Adicionar cartão'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CardPreview(
                brand: _brand,
                last4: _last4,
                name: _nameCtrl.text,
                exp: _expCtrl.text,
              ),

              if (_securityMessage != null) ...[
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _securityMessage!,
                    key: const ValueKey('card-security-message'),
                    style: const TextStyle(color: Colors.deepOrange),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              TextFormField(
                controller: _numberCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
                    var spaced = '';

                    for (int i = 0; i < digits.length && i < 19; i++) {
                      if (i % 4 == 0 && i != 0) spaced += ' ';
                      spaced += digits[i];
                    }

                    return TextEditingValue(
                      text: spaced,
                      selection: TextSelection.collapsed(offset: spaced.length),
                    );
                  }),
                ],
                decoration: const InputDecoration(
                  labelText: 'Número do cartão',
                  hintText: '0000 0000 0000 0000',
                ),
                onChanged: (_) => _updateCardPreview(),
                validator: _validateCardNumber,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome do titular'),
                validator: (value) {
                  final name = (value ?? '').trim();
                  if (name.length < 2) return 'Informe o nome do titular.';
                  if (name.length > 64) return 'Use até 64 caracteres.';
                  return null;
                },
                onChanged: (_) => setState(() => _securityMessage = null),
              ),

              const SizedBox(height: 12),

              if (isNarrow) ...[
                expirationField,
                const SizedBox(height: 12),
                cvvField,
              ] else
                Row(
                  children: [
                    Expanded(child: expirationField),
                    const SizedBox(width: 12),
                    Expanded(child: cvvField),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        SaveMedButton(
          label: 'Usar cartão',
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            final number = _numberCtrl.text.replaceAll(RegExp(r'\D'), '');
            final exp = _expCtrl.text.split('/');

            final card = PaymentCard(
              id: const Uuid().v4(),
              brand: _brand,
              last4: number.substring(number.length - 4),
              expMonth: int.parse(exp[0]),
              expYear: int.parse('20${exp[1]}'),

              // 👇 novos campos
              number: number,
              holderName: _nameCtrl.text.trim(),
              cvv: _cvvCtrl.text.trim(),
            );

            context.read<CardController>().addCard(card);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class _CardPreview extends StatelessWidget {
  final String brand;
  final String last4;
  final String name;
  final String exp;

  const _CardPreview({
    required this.brand,
    required this.last4,
    required this.name,
    required this.exp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            brand.isEmpty ? 'Cartão' : brand,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '•••• •••• •••• $last4',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name.isEmpty ? 'NOME DO TITULAR' : name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                exp.isEmpty ? 'MM/AA' : exp,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
