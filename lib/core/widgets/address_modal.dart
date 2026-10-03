import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../api/api_error_message.dart';
import '../controllers/address_controller.dart';
import '../controllers/auth_controller.dart';
import '../services/cep_lookup_service.dart';
import '../utils/field_validators.dart';
import '../utils/input_formatters.dart';
import '../../models/postal_address.dart';

class AddressModal extends StatefulWidget {
  final PostalAddress? address;

  const AddressModal({super.key, this.address});

  @override
  State<AddressModal> createState() => _AddressModalState();
}

class _AddressModalState extends State<AddressModal> {
  final _formKey = GlobalKey<FormState>();
  final cep = TextEditingController();
  final street = TextEditingController();
  final number = TextEditingController();
  final complement = TextEditingController();
  final neighborhood = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();

  bool noNumber = false;
  bool hasComplement = false;
  bool loadingCep = false;
  bool saving = false;
  String? formError;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    if (address == null) return;

    cep.text = address.cep;
    street.text = address.street;
    number.text = address.number ?? '';
    complement.text = address.complement ?? '';
    neighborhood.text = address.neighborhood ?? '';
    city.text = address.city;
    state.text = address.state;
    hasComplement = complement.text.isNotEmpty;
    noNumber = number.text.isEmpty;
  }

  @override
  void dispose() {
    cep.dispose();
    street.dispose();
    number.dispose();
    complement.dispose();
    neighborhood.dispose();
    city.dispose();
    state.dispose();
    super.dispose();
  }

  Future<void> _fetchCep() async {
    if (digitsOnly(cep.text).length != 8) {
      setState(
        () => formError = 'Informe um CEP válido para realizar a busca.',
      );
      return;
    }

    setState(() {
      loadingCep = true;
      formError = null;
    });
    try {
      final address = await CepLookupService.lookup(cep.text);
      if (!mounted) return;
      if (address == null) {
        setState(() {
          formError = 'CEP não encontrado. Preencha o endereço manualmente.';
        });
        return;
      }
      street.text = address.street;
      neighborhood.text = address.neighborhood;
      city.text = address.city;
      state.text = address.state;
    } catch (error) {
      if (!mounted) return;
      setState(() {
        formError = ApiErrorMessage.forUser(
          error,
          fallback: 'Não foi possível consultar o CEP. Preencha manualmente.',
        );
      });
    } finally {
      if (mounted) setState(() => loadingCep = false);
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final authUserId = context.read<AuthController>().user?.id;
    if (authUserId == null) {
      setState(() => formError = 'Sua sessão expirou. Entre novamente.');
      return;
    }

    setState(() {
      saving = true;
      formError = null;
    });
    try {
      final address = PostalAddress(
        cep: digitsOnly(cep.text),
        street: street.text.trim(),
        number: noNumber ? null : number.text.trim(),
        complement: hasComplement ? complement.text.trim() : null,
        neighborhood: neighborhood.text.trim(),
        city: city.text.trim(),
        state: state.text.trim().toUpperCase(),
        isDefault: true,
      );
      final controller = context.read<AddressController>();
      final addressId = widget.address?.id;
      if (widget.address != null && addressId == null) {
        throw const FormatException('Endereço inválido.');
      }
      if (addressId == null) {
        await controller.add(address, authUserId);
      } else {
        await controller.update(addressId, address, authUserId);
      }
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        formError = ApiErrorMessage.forUser(
          error,
          fallback: 'Não foi possível salvar o endereço. Tente novamente.',
        );
      });
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(widget.address == null ? 'Novo endereço' : 'Editar endereço'),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _input(
                  label: 'CEP',
                  controller: cep,
                  icon: Icons.location_searching,
                  keyboard: TextInputType.number,
                  inputFormatters: [cepFormatter],
                  validator: (value) => digitsOnly(value ?? '').length == 8
                      ? null
                      : 'Informe um CEP com 8 dígitos.',
                  suffix: loadingCep
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search),
                          tooltip: 'Buscar CEP',
                          onPressed: saving ? null : _fetchCep,
                        ),
                ),
                const SizedBox(height: 12),
                _input(
                  label: 'Rua',
                  controller: street,
                  icon: Icons.signpost_outlined,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                _input(
                  label: 'Bairro',
                  controller: neighborhood,
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 4),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: noNumber,
                  title: const Text('Endereço sem número'),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: saving
                      ? null
                      : (value) => setState(() {
                          noNumber = value ?? false;
                          if (noNumber) number.clear();
                        }),
                ),
                if (!noNumber)
                  _input(
                    label: 'Número',
                    controller: number,
                    icon: Icons.pin_outlined,
                    validator: _requiredValidator,
                  ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: hasComplement,
                  title: const Text('Adicionar complemento'),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: saving
                      ? null
                      : (value) => setState(() {
                          hasComplement = value ?? false;
                          if (!hasComplement) complement.clear();
                        }),
                ),
                if (hasComplement)
                  _input(
                    label: 'Complemento',
                    controller: complement,
                    icon: Icons.add_home_outlined,
                  ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 440;
                    final cityField = _input(
                      label: 'Cidade',
                      controller: city,
                      icon: Icons.location_city_outlined,
                      validator: _requiredValidator,
                    );
                    final stateField = _input(
                      label: 'UF',
                      controller: state,
                      icon: Icons.map_outlined,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (value) =>
                          value?.trim().length == 2 ? null : 'Informe a UF.',
                    );
                    if (compact) {
                      return Column(
                        children: [
                          cityField,
                          const SizedBox(height: 12),
                          stateField,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: cityField),
                        const SizedBox(width: 12),
                        SizedBox(width: 150, child: stateField),
                      ],
                    );
                  },
                ),
                if (formError != null) ...[
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      formError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: saving ? null : _save,
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(saving ? 'Salvando' : 'Salvar endereço'),
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    return isValidRequiredText(value ?? '') ? null : 'Campo obrigatório.';
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      enabled: !saving,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
