part of '../admin_page.dart';

class _PharmaciesPage extends _AdminListPage {
  final bool canCreate;

  const _PharmaciesPage({
    required super.pharmacyId,
    required super.service,
    required this.canCreate,
  });

  @override
  State<_PharmaciesPage> createState() => _PharmaciesPageState();
}

class _PharmaciesPageState
    extends _AdminListPageState<_PharmaciesPage, Pharmacy> {
  @override
  String get title =>
      widget.pharmacyId == null ? 'Farmácias' : 'Minha farmácia';

  @override
  String get subtitle =>
      'Dados cadastrais, contato e configurações de entrega.';

  @override
  bool get canCreate => widget.canCreate && widget.pharmacyId == null;

  @override
  String get createLabel => 'Nova farmácia';

  @override
  Future<List<Pharmacy>> fetch() async {
    final pharmacies = await service.listPharmacies();
    if (widget.pharmacyId == null) return pharmacies;
    return pharmacies.where((item) => item.id == widget.pharmacyId).toList();
  }

  @override
  bool matches(Pharmacy item, String query) => [
    item.name,
    item.cnpj,
    item.phone,
    item.city,
    item.state,
    item.zipcode,
  ].whereType<String>().any((value) => value.toLowerCase().contains(query));

  @override
  List<DataColumn> get columns => const [
    DataColumn(label: Text('Nome')),
    DataColumn(label: Text('CNPJ')),
    DataColumn(label: Text('Cidade')),
    DataColumn(label: Text('Status')),
    DataColumn(label: Text('Entrega')),
    DataColumn(label: Text('Retirada')),
    DataColumn(label: Text('Ações')),
  ];

  @override
  DataRow buildRow(Pharmacy item) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AdminThumbnail(imageUrl: item.image),
              const SizedBox(width: 10),
              _PrimaryCell(title: item.name, subtitle: 'ID ${item.id}'),
            ],
          ),
        ),
        DataCell(Text(item.cnpj ?? '-')),
        DataCell(Text(item.addressLine.isEmpty ? '-' : item.addressLine)),
        DataCell(_pharmacyStatus(item)),
        DataCell(_BoolChip(value: item.acceptsOwnDelivery)),
        DataCell(_BoolChip(value: item.acceptsPickup)),
        DataCell(
          _RowActions(
            onEdit: () => _showDialog(item: item),
            onDelete: widget.canCreate ? () => _confirmDeactivate(item) : null,
            deleteLabel: 'Inativar',
            deleteIcon: Icons.block_outlined,
            extra: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _AdminIconButton(
                  tooltip: 'Operação da loja',
                  icon: Icons.storefront_outlined,
                  onPressed: () => _showOperation(item),
                ),
                _AdminIconButton(
                  tooltip: 'Usuários da farmácia',
                  icon: Icons.group_outlined,
                  onPressed: () => _showUsersDialog(item),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildMobileItem(Pharmacy item) {
    return _CompactTile(
      title: item.name,
      subtitle: item.addressLine.isEmpty ? '-' : item.addressLine,
      leading: _AdminThumbnail(imageUrl: item.image, size: 72),
      chips: [
        if (item.cnpj != null) _SmallChip('CNPJ ${item.cnpj}'),
        if (item.phone != null) _SmallChip('Telefone ${item.phone}'),
        _pharmacyStatus(item),
        _BoolChip(value: item.acceptsOwnDelivery, label: 'Entrega'),
        _BoolChip(value: item.acceptsPickup, label: 'Retirada'),
      ],
      onEdit: () => _showDialog(item: item),
      onDelete: widget.canCreate ? () => _confirmDeactivate(item) : null,
      deleteLabel: 'Inativar',
      deleteIcon: Icons.block_outlined,
      extra: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _AdminIconButton(
            tooltip: 'Operação da loja',
            icon: Icons.storefront_outlined,
            onPressed: () => _showOperation(item),
          ),
          _AdminIconButton(
            tooltip: 'Usuários da farmácia',
            icon: Icons.group_outlined,
            onPressed: () => _showUsersDialog(item),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> onCreate() => _showDialog();

  Future<void> _showOperation(Pharmacy item) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(item.name)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: PharmacyOperationPanel(
                  pharmacyId: item.id,
                  service: service,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (mounted) await reload();
  }

  Future<void> _showDialog({Pharmacy? item}) async {
    final name = TextEditingController(text: item?.name ?? '');
    final cnpj = TextEditingController(text: item?.cnpj ?? '');
    final phone = TextEditingController(text: item?.phone ?? '');
    final city = TextEditingController(text: item?.city ?? '');
    final state = TextEditingController(text: item?.state ?? '');
    final zip = TextEditingController(text: item?.zipcode ?? '');
    final price = TextEditingController(
      text: item?.ownDeliveryPrice?.toString() ?? '',
    );
    final pricePerKm = TextEditingController(
      text: item?.ownDeliveryPricePerKm?.toString() ?? '',
    );
    final maxKm = TextEditingController(
      text: item?.ownDeliveryMaxDistanceKm?.toString() ?? '',
    );
    final note = TextEditingController(text: item?.ownDeliveryNote ?? '');
    final inactiveReason = TextEditingController(
      text: item?.inactiveReason ?? '',
    );
    _SelectedAdminImage? selectedImage;
    var persistedPharmacyId = item?.id;
    var active = item?.isActive ?? true;
    var ownDelivery = item?.acceptsOwnDelivery ?? false;
    var pickup = item?.acceptsPickup ?? false;
    var loadingCep = false;

    await _showAdminDialog(
      context: context,
      title: item == null ? 'Nova farmácia' : 'Editar farmácia',
      controllers: [
        name,
        cnpj,
        phone,
        city,
        state,
        zip,
        price,
        pricePerKm,
        maxKm,
        note,
        inactiveReason,
      ],
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _FormSectionHeading(
                title: 'Dados cadastrais',
                description: 'Identificação e contato principal da farmácia.',
                icon: Icons.storefront_outlined,
              ),
              _FormGrid(
                children: [
                  _input(
                    name,
                    'Nome',
                    validator: (value) =>
                        _requiredTextValidator(value, 'o nome'),
                  ),
                  _input(
                    cnpj,
                    'CNPJ',
                    keyboardType: TextInputType.number,
                    inputFormatters: [cnpjFormatter],
                    validator: _cnpjValidator,
                  ),
                  _input(
                    phone,
                    'Telefone',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [phoneFormatter],
                    validator: _phoneValidator,
                  ),
                  _input(
                    city,
                    'Cidade',
                    validator: (value) =>
                        _requiredTextValidator(value, 'a cidade'),
                  ),
                  _input(
                    state,
                    'UF',
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                      LengthLimitingTextInputFormatter(2),
                    ],
                    validator: _ufValidator,
                  ),
                  _input(
                    zip,
                    'CEP',
                    keyboardType: TextInputType.number,
                    inputFormatters: [cepFormatter],
                    validator: _cepValidator,
                    suffixIcon: loadingCep
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            tooltip: 'Buscar CEP',
                            onPressed: () async {
                              if (digitsOnly(zip.text).length != 8) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Informe um CEP válido para buscar.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              setModalState(() => loadingCep = true);
                              try {
                                final address = await CepLookupService.lookup(
                                  zip.text,
                                );
                                if (!context.mounted) return;
                                if (address == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'CEP não encontrado. Preencha o endereço manualmente.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                city.text = address.city;
                                state.text = address.state;
                              } catch (error) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(_cleanError(error))),
                                );
                              } finally {
                                if (context.mounted) {
                                  setModalState(() => loadingCep = false);
                                }
                              }
                            },
                            icon: const Icon(Icons.search),
                          ),
                  ),
                ],
              ),
              _FullWidthFormField(
                child: _AdminImagePicker(
                  label: 'Imagem da farmácia (PNG, JPEG ou WebP)',
                  selectedFilename: selectedImage?.name,
                  hasExistingImage: item?.image != null,
                  existingImageUrl: item?.image,
                  selectedBytes: selectedImage?.bytes,
                  onSelected: (file) =>
                      setModalState(() => selectedImage = file),
                ),
              ),
              const Divider(height: 32),
              const _FormSectionHeading(
                title: 'Operação',
                description:
                    'Disponibilidade da farmácia e impacto na vitrine.',
                icon: Icons.settings_outlined,
              ),
              _SwitchRow(
                title: 'Farmácia ativa',
                value: active,
                onChanged: (value) => setModalState(() => active = value),
              ),
              if (!active) ...[
                const _InfoPanel(
                  icon: Icons.info_outline,
                  title: 'A farmácia sairá da vitrine',
                  body:
                      'Usuários perderão o acesso operacional, mas pedidos, produtos e histórico serão preservados.',
                ),
                const SizedBox(height: 12),
                _input(
                  inactiveReason,
                  'Motivo da inativação',
                  validator: (value) =>
                      active ? null : _requiredTextValidator(value, 'o motivo'),
                ),
              ],
              const Divider(height: 32),
              const _FormSectionHeading(
                title: 'Entrega e retirada',
                description: 'Modalidades, valores e raio de atendimento.',
                icon: Icons.local_shipping_outlined,
              ),
              _SwitchRow(
                title: 'Entrega própria',
                value: ownDelivery,
                onChanged: (value) => setModalState(() => ownDelivery = value),
              ),
              if (ownDelivery)
                _FormGrid(
                  children: [
                    _input(
                      price,
                      'Valor base',
                      validator: (value) =>
                          _nonNegativeNumberValidator(value, 'um valor base'),
                    ),
                    _input(
                      pricePerKm,
                      'Valor por km',
                      validator: (value) =>
                          _nonNegativeNumberValidator(value, 'um valor por km'),
                    ),
                    _input(
                      maxKm,
                      'Raio máximo km',
                      validator: (value) =>
                          _positiveNumberValidator(value, 'um raio'),
                    ),
                    _input(note, 'Observações'),
                  ],
                ),
              _SwitchRow(
                title: 'Retirada no local',
                value: pickup,
                onChanged: (value) => setModalState(() => pickup = value),
              ),
            ],
          );
        },
      ),
      onSave: () => handle(() async {
        if (!isValidRequiredText(name.text) ||
            !isValidCNPJ(cnpj.text) ||
            !isValidPhone(phone.text) ||
            !isValidRequiredText(city.text) ||
            state.text.trim().length != 2 ||
            digitsOnly(zip.text).length != 8) {
          throw Exception(
            'Revise nome, CNPJ, telefone, cidade, UF e CEP da farmácia.',
          );
        }
        final basePrice = _toDouble(price.text);
        final perKm = _toDouble(pricePerKm.text);
        final distance = _toDouble(maxKm.text);
        if (ownDelivery &&
            (basePrice == null ||
                perKm == null ||
                distance == null ||
                basePrice < 0 ||
                perKm < 0 ||
                distance <= 0)) {
          throw Exception('Informe valores de entrega válidos e positivos.');
        }
        if (!active && !isValidRequiredText(inactiveReason.text)) {
          throw Exception('Informe o motivo da inativação da farmácia.');
        }
        persistedPharmacyId = await service.savePharmacy({
          'NAME': name.text.trim(),
          'CNPJ': digitsOnly(cnpj.text),
          'PHONE': digitsOnly(phone.text),
          'CITY': city.text.trim(),
          'STATE': state.text.trim().toUpperCase(),
          'ZIPCODE': digitsOnly(zip.text),
          'IS_ACTIVE': active,
          'INACTIVE_REASON': active ? null : inactiveReason.text.trim(),
          'ACCEPTS_OWN_DELIVERY': ownDelivery,
          'ACCEPTS_PICKUP': pickup,
          'OWN_DELIVERY_PRICE': ownDelivery ? basePrice : null,
          'OWN_DELIVERY_PRICE_PER_KM': ownDelivery ? perKm : null,
          'OWN_DELIVERY_MAX_DISTANCE_KM': ownDelivery ? distance : null,
          'OWN_DELIVERY_NOTE': ownDelivery ? note.text.trim() : null,
        }, id: persistedPharmacyId);
        final image = selectedImage;
        if (image != null && persistedPharmacyId != null) {
          if (!hasCurrentAdminSession) return;
          await service.uploadPharmacyImage(
            persistedPharmacyId!,
            bytes: image.bytes,
            filename: image.name,
          );
        }
      }),
    );
  }

  Widget _pharmacyStatus(Pharmacy item) {
    final active = item.isActive;
    final reason = item.inactiveReason ?? 'Motivo não informado';
    return Tooltip(
      message: active ? 'Farmácia disponível na vitrine' : reason,
      child: _SmallChip(
        active ? 'Ativa' : 'Inativa',
        color: active ? AppColors.success : _AdminColors.muted,
      ),
    );
  }

  Future<void> _confirmDeactivate(Pharmacy pharmacy) async {
    if (!pharmacy.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta farmácia já está inativa.')),
      );
      return;
    }
    var reason = '';
    final formKey = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Inativar farmácia?'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${pharmacy.name} sairá da vitrine e deixará de receber pedidos. O histórico será preservado.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Motivo da inativação',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _requiredTextValidator(value, 'o motivo'),
                onChanged: (value) => reason = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Inativar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await handle(
        () => service.deactivatePharmacy(pharmacy.id, reason: reason.trim()),
      );
    }
  }

  Future<void> _showUsersDialog(Pharmacy pharmacy) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _PharmacyUsersDialog(
        pharmacy: pharmacy,
        service: service,
        onCreateUser: () => _showCreatePharmacyUserDialog(pharmacy),
        onResetUser: _showResetPasswordDialog,
      ),
    );
  }

  Future<void> _showCreatePharmacyUserDialog(Pharmacy pharmacy) async {
    final name = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    var role = UserRole.pharmacyUser;
    var successMessage = 'Convite enviado com sucesso.';

    await _showAdminDialog(
      context: context,
      title: 'Convidar usuário para ${pharmacy.name}',
      controllers: [name, email, phone],
      child: _FormGrid(
        children: [
          const _FullWidthFormField(
            child: _InfoPanel(
              icon: Icons.mark_email_read_outlined,
              title: 'Senha definida pelo usuário',
              body:
                  'Enviaremos um código por e-mail. O acesso só será liberado depois que a pessoa definir a própria senha.',
            ),
          ),
          _input(
            name,
            'Nome',
            validator: (value) => _requiredTextValidator(value, 'o nome'),
          ),
          _input(
            email,
            'Email',
            keyboardType: TextInputType.emailAddress,
            validator: _emailValidator,
          ),
          _input(
            phone,
            'Telefone (opcional)',
            keyboardType: TextInputType.phone,
            inputFormatters: [phoneFormatter],
            validator: (value) => _phoneValidator(value, optional: true),
          ),
          DropdownButtonFormField<UserRole>(
            isExpanded: true,
            initialValue: role,
            decoration: const InputDecoration(
              labelText: 'Perfil de acesso',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: UserRole.pharmacyUser,
                child: Text('Operador da farmácia'),
              ),
              DropdownMenuItem(
                value: UserRole.pharmacyAdmin,
                child: Text('Administrador da farmácia'),
              ),
            ],
            onChanged: (value) {
              if (value != null) role = value;
            },
          ),
        ],
      ),
      onSave: () => handle(() async {
        if (!isValidRequiredText(name.text) || !isValidEmail(email.text)) {
          throw Exception('Informe nome e e-mail válidos para o usuário.');
        }
        if (phone.text.isNotEmpty && !isValidPhone(phone.text)) {
          throw Exception('Informe um telefone válido com DDD.');
        }
        successMessage = await service.invitePharmacyUser(
          pharmacyId: pharmacy.id,
          name: name.text.trim(),
          email: email.text.trim(),
          phone: digitsOnly(phone.text),
          role: role,
        );
      }, successMessage: () => successMessage),
    );
  }

  Future<void> _showResetPasswordDialog(AppUser user) async {
    final password = TextEditingController();
    final confirm = TextEditingController();

    await _showAdminDialog(
      context: context,
      title: 'Resetar senha de ${user.name}',
      controllers: [password, confirm],
      child: _FormGrid(
        children: [
          _input(
            password,
            'Nova senha',
            obscureText: true,
            validator: (value) => validatePasswordLength(value ?? ''),
          ),
          _input(
            confirm,
            'Confirmar senha',
            obscureText: true,
            validator: (value) =>
                validatePasswordConfirmation(password.text, value ?? ''),
          ),
          _FullWidthFormField(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: password,
              builder: (context, passwordValue, _) =>
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: confirm,
                    builder: (context, confirmationValue, _) =>
                        PasswordRequirements(
                          password: passwordValue.text,
                          confirmation: confirmationValue.text,
                        ),
                  ),
            ),
          ),
        ],
      ),
      onSave: () => handle(() async {
        final passwordError = validatePassword(password.text, confirm.text);
        if (passwordError != null) throw Exception(passwordError);
        await service.resetUserPassword(user.id, password.text);
      }),
    );
  }
}
