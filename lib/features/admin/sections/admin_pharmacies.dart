part of '../admin_page.dart';

class _PharmaciesPage extends _AdminListPage {
  final bool canCreate;

  const _PharmaciesPage({required super.pharmacyId, required this.canCreate});

  @override
  State<_PharmaciesPage> createState() => _PharmaciesPageState();
}

class _PharmaciesPageState extends _AdminListPageState<_PharmaciesPage> {
  @override
  String get title => widget.pharmacyId == null ? 'Farmacias' : 'Minha loja';

  @override
  String get subtitle =>
      'Dados cadastrais, contato e configuracoes de entrega.';

  @override
  bool get canCreate => widget.canCreate && widget.pharmacyId == null;

  @override
  String get createLabel => 'Nova farmacia';

  @override
  Future<List<dynamic>> fetch() async {
    final pharmacies = await service.listPharmacies();
    if (widget.pharmacyId == null) return pharmacies;
    return pharmacies.where((item) => item['ID'] == widget.pharmacyId).toList();
  }

  @override
  bool matches(Map<String, dynamic> item, String query) =>
      textMatch(item, query);

  @override
  List<DataColumn> get columns => const [
    DataColumn(label: Text('Nome')),
    DataColumn(label: Text('CNPJ')),
    DataColumn(label: Text('Cidade')),
    DataColumn(label: Text('Status')),
    DataColumn(label: Text('Entrega')),
    DataColumn(label: Text('Retirada')),
    DataColumn(label: Text('Acoes')),
  ];

  @override
  DataRow buildRow(Map<String, dynamic> item) {
    return DataRow(
      cells: [
        DataCell(_PrimaryCell(title: _str(item['NAME']), subtitle: _id(item))),
        DataCell(Text(_str(item['CNPJ'], fallback: '-'))),
        DataCell(Text(_addressLine(item))),
        DataCell(_BoolChip(value: item['IS_ACTIVE'] != false, label: 'Ativa')),
        DataCell(_BoolChip(value: item['ACCEPTS_OWN_DELIVERY'] == true)),
        DataCell(_BoolChip(value: item['ACCEPTS_PICKUP'] == true)),
        DataCell(
          _RowActions(
            onEdit: () => _showDialog(item: item),
            onDelete: widget.canCreate
                ? () => confirmDelete(
                    itemLabel: 'a farmacia ${_str(item['NAME'])}',
                    action: () => service.deletePharmacy(item['ID']),
                  )
                : null,
            extra: widget.canCreate
                ? TextButton(
                    onPressed: () => _showUsersDialog(item),
                    child: const Text('Usuarios'),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget buildMobileItem(Map<String, dynamic> item) {
    return _CompactTile(
      title: _str(item['NAME'], fallback: 'Farmacia'),
      subtitle: _addressLine(item),
      chips: [
        _BoolChip(value: item['IS_ACTIVE'] != false, label: 'Ativa'),
        _BoolChip(
          value: item['ACCEPTS_OWN_DELIVERY'] == true,
          label: 'Entrega',
        ),
        _BoolChip(value: item['ACCEPTS_PICKUP'] == true, label: 'Retirada'),
      ],
      onEdit: () => _showDialog(item: item),
      onDelete: widget.canCreate
          ? () => confirmDelete(
              itemLabel: 'a farmacia ${_str(item['NAME'])}',
              action: () => service.deletePharmacy(item['ID']),
            )
          : null,
      extra: widget.canCreate
          ? TextButton(
              onPressed: () => _showUsersDialog(item),
              child: const Text('Usuarios'),
            )
          : null,
    );
  }

  @override
  Future<void> onCreate() => _showDialog();

  Future<void> _showDialog({Map<String, dynamic>? item}) async {
    final name = TextEditingController(text: _str(item?['NAME']));
    final cnpj = TextEditingController(text: _str(item?['CNPJ']));
    final phone = TextEditingController(text: _str(item?['PHONE']));
    final city = TextEditingController(text: _str(item?['CITY']));
    final state = TextEditingController(text: _str(item?['STATE']));
    final zip = TextEditingController(text: _str(item?['ZIPCODE']));
    final price = TextEditingController(
      text: _str(item?['OWN_DELIVERY_PRICE']),
    );
    final pricePerKm = TextEditingController(
      text: _str(item?['OWN_DELIVERY_PRICE_PER_KM']),
    );
    final maxKm = TextEditingController(
      text: _str(item?['OWN_DELIVERY_MAX_DISTANCE_KM']),
    );
    final note = TextEditingController(text: _str(item?['OWN_DELIVERY_NOTE']));
    var active = item?['IS_ACTIVE'] != false;
    var ownDelivery = item?['ACCEPTS_OWN_DELIVERY'] == true;
    var pickup = item?['ACCEPTS_PICKUP'] == true;

    await _showAdminDialog(
      context: context,
      title: item == null ? 'Nova farmacia' : 'Editar farmacia',
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FormGrid(
                children: [
                  _input(name, 'Nome'),
                  _input(
                    cnpj,
                    'CNPJ',
                    keyboardType: TextInputType.number,
                    inputFormatters: [cnpjFormatter],
                  ),
                  _input(
                    phone,
                    'Telefone',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [phoneFormatter],
                  ),
                  _input(city, 'Cidade'),
                  _input(
                    state,
                    'UF',
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                      LengthLimitingTextInputFormatter(2),
                    ],
                  ),
                  _input(
                    zip,
                    'CEP',
                    keyboardType: TextInputType.number,
                    inputFormatters: [cepFormatter],
                  ),
                ],
              ),
              _SwitchRow(
                title: 'Farmacia ativa',
                value: active,
                onChanged: (value) => setModalState(() => active = value),
              ),
              _SwitchRow(
                title: 'Entrega propria',
                value: ownDelivery,
                onChanged: (value) => setModalState(() => ownDelivery = value),
              ),
              if (ownDelivery)
                _FormGrid(
                  children: [
                    _input(price, 'Valor base'),
                    _input(pricePerKm, 'Valor por km'),
                    _input(maxKm, 'Raio maximo km'),
                    _input(note, 'Observacoes'),
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
            'Revise nome, CNPJ, telefone, cidade, UF e CEP da farmacia.',
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
          throw Exception('Informe valores de entrega validos e positivos.');
        }
        await service.savePharmacy({
          'NAME': name.text.trim(),
          'CNPJ': digitsOnly(cnpj.text),
          'PHONE': digitsOnly(phone.text),
          'CITY': city.text.trim(),
          'STATE': state.text.trim().toUpperCase(),
          'ZIPCODE': digitsOnly(zip.text),
          'IS_ACTIVE': active,
          'ACCEPTS_OWN_DELIVERY': ownDelivery,
          'ACCEPTS_PICKUP': pickup,
          'OWN_DELIVERY_PRICE': ownDelivery ? basePrice : null,
          'OWN_DELIVERY_PRICE_PER_KM': ownDelivery ? perKm : null,
          'OWN_DELIVERY_MAX_DISTANCE_KM': ownDelivery ? distance : null,
          'OWN_DELIVERY_NOTE': ownDelivery ? note.text.trim() : null,
        }, id: item?['ID'] as int?);
      }),
    );
  }

  Future<void> _showUsersDialog(Map<String, dynamic> pharmacy) async {
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

  Future<void> _showCreatePharmacyUserDialog(
    Map<String, dynamic> pharmacy,
  ) async {
    final name = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    final password = TextEditingController();
    final confirm = TextEditingController();
    var role = UserRole.pharmacyUser;

    await _showAdminDialog(
      context: context,
      title:
          'Criar usuario para ${_str(pharmacy['NAME'], fallback: 'farmacia')}',
      child: _FormGrid(
        children: [
          _input(name, 'Nome'),
          _input(email, 'Email', keyboardType: TextInputType.emailAddress),
          _input(
            phone,
            'Telefone',
            keyboardType: TextInputType.phone,
            inputFormatters: [phoneFormatter],
          ),
          _input(password, 'Senha temporaria', obscureText: true),
          _input(confirm, 'Confirmar senha', obscureText: true),
          DropdownButtonFormField<UserRole>(
            initialValue: role,
            decoration: const InputDecoration(
              labelText: 'Perfil de acesso',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: UserRole.pharmacyUser,
                child: Text('Operador da farmacia'),
              ),
              DropdownMenuItem(
                value: UserRole.pharmacyAdmin,
                child: Text('Administrador da farmacia'),
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
          throw Exception('Informe nome e email validos para o usuario.');
        }
        if (phone.text.isNotEmpty && !isValidPhone(phone.text)) {
          throw Exception('Informe um telefone valido com DDD.');
        }
        final passwordError = validatePassword(password.text, confirm.text);
        if (passwordError != null) throw Exception(passwordError);
        await service.createPharmacyUser(
          pharmacyId: pharmacy['ID'] as int,
          name: name.text.trim(),
          email: email.text.trim(),
          phone: digitsOnly(phone.text),
          password: password.text,
          role: role,
        );
      }),
    );
  }

  Future<void> _showResetPasswordDialog(Map<String, dynamic> user) async {
    final password = TextEditingController();
    final confirm = TextEditingController();

    await _showAdminDialog(
      context: context,
      title: 'Resetar senha de ${_str(user['NAME'], fallback: 'usuario')}',
      child: _FormGrid(
        children: [
          _input(password, 'Nova senha', obscureText: true),
          _input(confirm, 'Confirmar senha', obscureText: true),
        ],
      ),
      onSave: () => handle(() async {
        final passwordError = validatePassword(password.text, confirm.text);
        if (passwordError != null) throw Exception(passwordError);
        await service.resetUserPassword(user['ID'] as int, password.text);
      }),
    );
  }
}
