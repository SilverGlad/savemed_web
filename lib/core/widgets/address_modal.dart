import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:SaveMed/core/controllers/address_controller.dart';
import 'package:SaveMed/core/controllers/auth_controller.dart';
import 'package:SaveMed/core/widgets/savemed_button.dart';

class AddressModal extends StatefulWidget {
  final Map? address;

  const AddressModal({super.key, this.address});

  @override
  State<AddressModal> createState() => _AddressModalState();
}

class _AddressModalState extends State<AddressModal> {
  final cep = TextEditingController();
  final street = TextEditingController();
  final number = TextEditingController();
  final complement = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();

  bool noNumber = false;
  bool hasComplement = false;
  bool loadingCep = false;

  @override
  void initState() {
    super.initState();

    if (widget.address != null) {
      cep.text = widget.address!['CEP'] ?? '';
      street.text = widget.address!['STREET'] ?? '';
      number.text = widget.address!['NUMBER'] ?? '';
      city.text = widget.address!['CITY'] ?? '';
      state.text = widget.address!['STATE'] ?? '';
      complement.text = widget.address!['COMPLEMENT'] ?? '';
      hasComplement = widget.address!['COMPLEMENT'] != null;
      noNumber = widget.address!['NUMBER'] == null;
    }
  }

  Future<void> _fetchCep() async {
    final rawCep = cep.text.replaceAll(RegExp(r'\D'), '');
    if (rawCep.length != 8) return;

    setState(() => loadingCep = true);

    final res = await http.get(
      Uri.parse('https://viacep.com.br/ws/$rawCep/json/'),
    );
    final data = json.decode(res.body);

    if (!data.containsKey('erro')) {
      street.text = data['logradouro'] ?? '';
      city.text = data['localidade'] ?? '';
      state.text = data['uf'] ?? '';
    }

    setState(() => loadingCep = false);
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthController>().user!['ID'];

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.address == null ? 'Novo endereço' : 'Editar endereço',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              _input(
                label: 'CEP',
                controller: cep,
                icon: Icons.location_searching,
                keyboard: TextInputType.number,
                suffix: loadingCep
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _fetchCep,
                      ),
              ),

              const SizedBox(height: 12),
              _input(label: 'Rua', controller: street, icon: Icons.aod),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _input(
                      label: 'Número',
                      controller: number,
                      icon: Icons.pin,
                      enabled: !noNumber,
                    ),
                  ),
                  Checkbox(
                    value: noNumber,
                    onChanged: (v) {
                      setState(() {
                        noNumber = v!;
                        if (v) number.clear();
                      });
                    },
                  ),
                  const Text('Sem número'),
                ],
              ),

              Row(
                children: [
                  Checkbox(
                    value: hasComplement,
                    onChanged: (v) => setState(() => hasComplement = v!),
                  ),
                  const Text('Possui complemento'),
                ],
              ),

              if (hasComplement)
                _input(
                  label: 'Complemento',
                  controller: complement,
                  icon: Icons.add_home,
                ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _input(
                      label: 'Cidade',
                      controller: city,
                      icon: Icons.location_city,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    child: _input(
                      label: 'UF',
                      controller: state,
                      icon: Icons.map,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerRight,
                child: SaveMedButton(
                  label: 'Salvar endereço',
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final data = {
                      'USER_ID': userId,
                      'CEP': cep.text,
                      'STREET': street.text,
                      'NUMBER': noNumber ? null : number.text,
                      'COMPLEMENT': hasComplement ? complement.text : null,
                      'CITY': city.text,
                      'STATE': state.text,
                      'IS_DEFAULT': true,
                    };

                    final ctrl = context.read<AddressController>();

                    if (widget.address == null) {
                      await ctrl.add(data, userId);
                    } else {
                      await ctrl.update(widget.address!['ID'], data, userId);
                    }

                    if (!mounted) return;
                    navigator.pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    Widget? suffix,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
