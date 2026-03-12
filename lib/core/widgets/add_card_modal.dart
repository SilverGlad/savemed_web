import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:SaveMed/core/utils/input_formatters.dart';
import 'package:SaveMed/models/payment_card.dart';
import 'package:uuid/uuid.dart';

import '../../../core/controllers/card_controller.dart';
import '../../../core/widgets/savemed_button.dart';

class AddCardModal extends StatefulWidget {
  const AddCardModal({super.key});

  @override
  State<AddCardModal> createState() => _AddCardModalState();
}

class _AddCardModalState extends State<AddCardModal> {
  final _numberCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  String _brand = '';
  String _last4 = '••••';

  void _updateCardPreview() {
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Adicionar cartão'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CardPreview(
              brand: _brand,
              last4: _last4,
              name: _nameCtrl.text,
              exp: _expCtrl.text,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _numberCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
                  var spaced = '';

                  for (int i = 0; i < digits.length && i < 16; i++) {
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
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome do titular'),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _cpfCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                cpfFormatter,
              ],
              decoration: const InputDecoration(
                labelText: 'CPF',
                hintText: '000.000.000-00',
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
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
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _cvvCtrl,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: const InputDecoration(labelText: 'CVV'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        SaveMedButton(
          label: 'Salvar cartão',
          onPressed: () {
            final number = _numberCtrl.text.replaceAll(RegExp(r'\D'), '');
            final exp = _expCtrl.text.split('/');

            if (number.length < 12 || exp.length != 2) return;

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
              Text(
                name.isEmpty ? 'NOME DO TITULAR' : name.toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
              SizedBox(width: 8),
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
