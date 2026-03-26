import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:SaveMed/core/controllers/address_controller.dart';
import 'package:SaveMed/core/controllers/auth_controller.dart';
import 'package:SaveMed/core/services/auth_service.dart';
import 'package:SaveMed/core/theme/app_colors.dart';
import 'package:SaveMed/core/utils/document_validator.dart';
import 'package:SaveMed/core/utils/input_formatters.dart';
import 'package:SaveMed/core/widgets/savemed_button.dart';
import 'package:SaveMed/core/widgets/savemed_footer.dart';
import 'package:SaveMed/features/admin/admin_page.dart';
import 'package:SaveMed/features/home/home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 600;
    final isDesktop = width >= 980;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _AuthHeader(),
          SizedBox(height: isMobile ? 12 : 20),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 24,
                0,
                isMobile ? 16 : 24,
                24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 18 : 28),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF8FFFD), Color(0xFFE2F2EE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: isMobile
                            ? _authHero()
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: isDesktop ? 5 : 1,
                                    child: _authHero(),
                                  ),
                                  SizedBox(width: isDesktop ? 40 : 24),
                                  Expanded(
                                    flex: 4,
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      child: isLogin
                                          ? LoginCard(
                                              key: const ValueKey('login'),
                                              onSwitch: () => setState(
                                                () => isLogin = false,
                                              ),
                                              isMobile: isMobile,
                                            )
                                          : RegisterCard(
                                              key: const ValueKey('register'),
                                              onSwitch: () => setState(
                                                () => isLogin = true,
                                              ),
                                              isMobile: isMobile,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      if (isMobile) ...[
                        const SizedBox(height: 18),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: isLogin
                              ? LoginCard(
                                  key: const ValueKey('login'),
                                  onSwitch: () =>
                                      setState(() => isLogin = false),
                                  isMobile: isMobile,
                                )
                              : RegisterCard(
                                  key: const ValueKey('register'),
                                  onSwitch: () =>
                                      setState(() => isLogin = true),
                                  isMobile: isMobile,
                                ),
                        ),
                      ],
                      SizedBox(height: isMobile ? 24 : 32),
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

  Widget _authHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'Acesso seguro',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Compre medicamentos com rapidez, acompanhe seus pedidos e resolva tudo em um so lugar.',
          style: TextStyle(
            fontSize: 30,
            height: 1.05,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Acesse sua conta para continuar a compra, consultar entregas e aproveitar uma experiencia simples tanto no celular quanto no computador.',
          style: TextStyle(color: AppColors.textLight, height: 1.5),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _HeroInfo(icon: Icons.receipt_long_outlined, label: 'Pedidos'),
            _HeroInfo(icon: Icons.local_shipping_outlined, label: 'Entrega'),
            _HeroInfo(
              icon: Icons.admin_panel_settings_outlined,
              label: 'Administracao',
            ),
          ],
        ),
      ],
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 760;

    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 12 : 24,
        12,
        isMobile ? 12 : 24,
        12,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 22,
        vertical: isMobile ? 14 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset('assets/images/logo.png'),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SaveMed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Login obrigatorio',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
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

class _HeroInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryDark),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthBaseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool isMobile;

  const AuthBaseCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? double.infinity : 420,
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textLight),
          ),
          SizedBox(height: isMobile ? 24 : 32),
          child,
        ],
      ),
    );
  }
}

class LoginCard extends StatefulWidget {
  final VoidCallback onSwitch;
  final bool isMobile;

  const LoginCard({super.key, required this.onSwitch, required this.isMobile});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthBaseCard(
      title: 'Bem-vindo de volta',
      subtitle: _isSubmitting ? 'Entrando na sua conta...' : 'Novo por aqui?',
      isMobile: widget.isMobile,
      child: Column(
        children: [
          _Input(
            label: 'Email',
            hint: 'Seu email',
            icon: Icons.email_outlined,
            controller: emailController,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          _Input(
            label: 'Senha',
            hint: 'Sua senha',
            icon: Icons.lock_outline,
            obscure: true,
            controller: passwordController,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: SaveMedButton(
              loading: _isSubmitting,
              onPressed: _isSubmitting ? null : () => _handleLogin(context),
              label: 'Entrar',
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isSubmitting ? null : widget.onSwitch,
            child: const Text('Criar conta'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final authController = context.read<AuthController>();
    final addressController = context.read<AddressController>();

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      await authController.login(
        emailController.text,
        passwordController.text,
        addressController,
      );

      if (!mounted) return;
      final role = authController.user?['USER_ROLE'];
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => role == 'app_admin' || role == 'pharmacy_admin'
              ? const AdminPage()
              : const HomePage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _mapLoginError(e),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _mapLoginError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('invalid') ||
        message.contains('credenciais') ||
        message.contains('senha') ||
        message.contains('unauthorized')) {
      return 'Email ou senha incorretos. Confira seus dados e tente novamente.';
    }

    if (message.contains('network') || message.contains('socket')) {
      return 'Nao foi possivel conectar agora. Verifique sua internet e tente novamente.';
    }

    return 'Nao foi possivel entrar agora. Tente novamente em instantes.';
  }
}

enum RegisterProfileType { customer, pharmacy }

enum PharmacyRegistrationMode { newPharmacy, existingPharmacy }

class RegisterCard extends StatefulWidget {
  final VoidCallback onSwitch;
  final bool isMobile;

  const RegisterCard({
    super.key,
    required this.onSwitch,
    required this.isMobile,
  });

  @override
  State<RegisterCard> createState() => _RegisterCardState();
}

class _RegisterCardState extends State<RegisterCard> {
  RegisterProfileType profile = RegisterProfileType.customer;
  PharmacyRegistrationMode pharmacyMode = PharmacyRegistrationMode.newPharmacy;
  final _authService = AuthService();

  final docController = TextEditingController();
  final nameController = TextEditingController();
  final pharmacyNameController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipcodeController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final requestMessageController = TextEditingController();
  bool _isSubmitting = false;
  bool _loadingCep = false;
  bool _loadingPharmacies = false;
  String? _lastFetchedCep;
  List<dynamic> _pharmacies = [];
  int? _selectedPharmacyId;

  bool get isCustomer => profile == RegisterProfileType.customer;
  bool get isNewPharmacy =>
      pharmacyMode == PharmacyRegistrationMode.newPharmacy;

  @override
  void initState() {
    super.initState();
    zipcodeController.addListener(_handleZipcodeChanged);
    _loadPharmacies();
  }

  @override
  void dispose() {
    zipcodeController.removeListener(_handleZipcodeChanged);
    docController.dispose();
    nameController.dispose();
    pharmacyNameController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipcodeController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    requestMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthBaseCard(
      title: 'Crie sua conta',
      subtitle: _isSubmitting ? 'Criando sua conta...' : 'Ja tem conta?',
      isMobile: widget.isMobile,
      child: Column(
        children: [
          _ProfileSelector(
            selectedProfile: profile,
            onChanged: _isSubmitting
                ? (_) {}
                : (value) => setState(() {
                    profile = value;
                    if (value == RegisterProfileType.customer) {
                      pharmacyMode = PharmacyRegistrationMode.newPharmacy;
                    }
                  }),
          ),
          const SizedBox(height: 16),
          if (!isCustomer) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5FAF8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cadastro de farmacia',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Escolha se voce esta cadastrando uma nova farmacia ou se precisa pedir acesso a uma farmacia ja existente.',
                    style: TextStyle(color: AppColors.textLight, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _PharmacyModeSelector(
              selectedMode: pharmacyMode,
              onChanged: _isSubmitting
                  ? (_) {}
                  : (value) => setState(() => pharmacyMode = value),
            ),
            const SizedBox(height: 12),
          ],
          _Input(
            label: isCustomer ? 'CPF' : 'CNPJ',
            hint: isCustomer ? 'CPF' : 'CNPJ',
            icon: Icons.badge_outlined,
            controller: docController,
            inputFormatters: [isCustomer ? cpfFormatter : cnpjFormatter],
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 12),
          _Input(
            label: isCustomer ? 'Nome completo' : 'Nome do responsavel',
            hint: isCustomer ? 'Nome completo' : 'Nome do responsavel legal',
            icon: Icons.person_outline,
            controller: nameController,
            enabled: !_isSubmitting,
          ),
          if (!isCustomer) ...[
            if (isNewPharmacy) ...[
              const SizedBox(height: 12),
              _Input(
                label: 'Nome da nova farmacia',
                hint: 'Nome da farmacia',
                icon: Icons.local_pharmacy_outlined,
                controller: pharmacyNameController,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 12),
              _Input(
                label: 'Cidade',
                hint: 'Cidade',
                icon: Icons.location_city_outlined,
                controller: cityController,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 12),
              _Input(
                label: 'UF',
                hint: 'UF',
                icon: Icons.map_outlined,
                controller: stateController,
                enabled: !_isSubmitting,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                  LengthLimitingTextInputFormatter(2),
                ],
              ),
              const SizedBox(height: 12),
              _Input(
                label: 'CEP',
                hint: '00000-000',
                icon: Icons.markunread_mailbox_outlined,
                controller: zipcodeController,
                enabled: !_isSubmitting,
                inputFormatters: [cepFormatter],
                suffix: _loadingCep
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ] else ...[
              _PharmacySelectorField(
                pharmacies: _pharmacies,
                loading: _loadingPharmacies,
                selectedPharmacyId: _selectedPharmacyId,
                enabled: !_isSubmitting,
                onChanged: (value) =>
                    setState(() => _selectedPharmacyId = value),
              ),
              const SizedBox(height: 12),
              _Input(
                label: 'Mensagem para o admin',
                hint:
                    'Ex.: Sou o responsavel pela unidade e preciso acessar o painel.',
                icon: Icons.mark_email_read_outlined,
                controller: requestMessageController,
                enabled: !_isSubmitting,
                maxLines: 3,
              ),
            ],
          ],
          const SizedBox(height: 12),
          _Input(
            label: 'Email',
            hint: 'Email',
            icon: Icons.email_outlined,
            controller: emailController,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 12),
          _Input(
            label: 'Telefone',
            hint: '(00) 00000-0000',
            icon: Icons.phone_outlined,
            controller: phoneController,
            inputFormatters: [phoneFormatter],
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 12),
          _Input(
            label: 'Senha',
            hint: 'Senha',
            icon: Icons.lock_outline,
            obscure: true,
            controller: passwordController,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 12),
          _Input(
            label: 'Confirmar senha',
            hint: 'Confirmar senha',
            icon: Icons.lock_outline,
            obscure: true,
            controller: confirmController,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: SaveMedButton(
              loading: _isSubmitting,
              onPressed: _isSubmitting ? null : () => _handleRegister(context),
              label: 'Criar conta',
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isSubmitting ? null : widget.onSwitch,
            child: const Text('Fazer login'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final authController = context.read<AuthController>();
    final valid = isCustomer
        ? isValidCPF(docController.text)
        : isValidCNPJ(docController.text);

    if (!valid) {
      messenger.showSnackBar(
        SnackBar(content: Text(isCustomer ? 'CPF invalido' : 'CNPJ invalido')),
      );
      return;
    }

    if (!isCustomer &&
        isNewPharmacy &&
        (pharmacyNameController.text.trim().isEmpty ||
            cityController.text.trim().isEmpty ||
            stateController.text.trim().length != 2 ||
            zipcodeController.text.replaceAll(RegExp(r'\D'), '').length != 8)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Preencha nome da farmacia, cidade, UF e CEP validos'),
        ),
      );
      return;
    }

    if (!isCustomer && !isNewPharmacy && _selectedPharmacyId == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione a farmacia ja cadastrada para solicitar acesso',
          ),
        ),
      );
      return;
    }

    if (passwordController.text.length < 8 ||
        passwordController.text != confirmController.text) {
      messenger.showSnackBar(const SnackBar(content: Text('Senha invalida')));
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      await authController.register(
        isCustomer: isCustomer,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        document: docController.text,
        phone: phoneController.text,
        useExistingPharmacy: !isCustomer && !isNewPharmacy,
        pharmacyId: isCustomer ? null : _selectedPharmacyId,
        pharmacyName: isCustomer || !isNewPharmacy
            ? null
            : pharmacyNameController.text.trim(),
        city: isCustomer || !isNewPharmacy ? null : cityController.text.trim(),
        state: isCustomer || !isNewPharmacy
            ? null
            : stateController.text.trim().toUpperCase(),
        zipcode: isCustomer || !isNewPharmacy
            ? null
            : zipcodeController.text.trim(),
        requestMessage: isCustomer || isNewPharmacy
            ? null
            : requestMessageController.text.trim(),
      );

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isCustomer
                ? 'Conta criada com sucesso'
                : isNewPharmacy
                ? 'Conta de farmacia criada com sucesso. Verifique seu email.'
                : 'Solicitacao enviada para aprovacao da farmacia. Verifique seu email.',
          ),
        ),
      );
      widget.onSwitch();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(_mapRegisterError(e))));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _mapRegisterError(Object error) {
    final message = error.toString();
    final normalized = message.toLowerCase();

    if (normalized.contains('email ja cadastrado')) {
      return 'Este email ja esta em uso.';
    }

    if (normalized.contains('pharmacy_id')) {
      return 'Nao foi possivel vincular a farmacia ao usuario. Tente novamente.';
    }

    return message.replaceFirst('Exception: ', '');
  }

  void _handleZipcodeChanged() {
    if (isCustomer || !isNewPharmacy) return;

    final rawCep = zipcodeController.text.replaceAll(RegExp(r'\D'), '');
    if (rawCep.length != 8 || rawCep == _lastFetchedCep || _loadingCep) return;

    _fetchCep(rawCep);
  }

  Future<void> _fetchCep(String rawCep) async {
    setState(() => _loadingCep = true);

    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$rawCep/json/'),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['erro'] == true) return;

      cityController.text = (data['localidade'] ?? '').toString();
      stateController.text = (data['uf'] ?? '').toString().toUpperCase();
      _lastFetchedCep = rawCep;
    } catch (_) {
      // Ignora falhas de CEP e deixa o preenchimento manual disponivel.
    } finally {
      if (mounted) {
        setState(() => _loadingCep = false);
      }
    }
  }

  Future<void> _loadPharmacies() async {
    setState(() => _loadingPharmacies = true);
    try {
      final pharmacies = await _authService.listPharmacies();
      if (!mounted) return;
      setState(() => _pharmacies = pharmacies);
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() => _loadingPharmacies = false);
      }
    }
  }
}

class _Input extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final Widget? suffix;
  final int maxLines;

  const _Input({
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.enabled = true,
    this.inputFormatters,
    this.controller,
    this.suffix,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscure,
          inputFormatters: inputFormatters,
          maxLines: obscure ? 1 : maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: suffix,
            filled: true,
            fillColor: enabled
                ? const Color(0xFFF8F9FB)
                : AppColors.surfaceMuted,
          ),
        ),
      ],
    );
  }
}

class _ProfileSelector extends StatelessWidget {
  final RegisterProfileType selectedProfile;
  final ValueChanged<RegisterProfileType> onChanged;

  const _ProfileSelector({
    required this.selectedProfile,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isCustomerActive = selectedProfile == RegisterProfileType.customer;

    return Row(
      children: [
        _button(
          'Cliente',
          isCustomerActive,
          () => onChanged(RegisterProfileType.customer),
        ),
        const SizedBox(width: 8),
        _button(
          'Farmacia',
          !isCustomerActive,
          () => onChanged(RegisterProfileType.pharmacy),
        ),
      ],
    );
  }

  Widget _button(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : const Color(0xFFE8F0F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _PharmacyModeSelector extends StatelessWidget {
  final PharmacyRegistrationMode selectedMode;
  final ValueChanged<PharmacyRegistrationMode> onChanged;

  const _PharmacyModeSelector({
    required this.selectedMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _modeCard(
            title: 'Nova farmacia',
            subtitle: 'Crio a farmacia e a conta admin agora',
            active: selectedMode == PharmacyRegistrationMode.newPharmacy,
            onTap: () => onChanged(PharmacyRegistrationMode.newPharmacy),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _modeCard(
            title: 'Ja cadastrada',
            subtitle: 'Peço aprovacao para entrar em uma farmacia existente',
            active: selectedMode == PharmacyRegistrationMode.existingPharmacy,
            onTap: () => onChanged(PharmacyRegistrationMode.existingPharmacy),
          ),
        ),
      ],
    );
  }

  Widget _modeCard({
    required String title,
    required String subtitle,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: active ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: active ? AppColors.primaryDark : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PharmacySelectorField extends StatelessWidget {
  final List<dynamic> pharmacies;
  final bool loading;
  final int? selectedPharmacyId;
  final bool enabled;
  final ValueChanged<int?> onChanged;

  const _PharmacySelectorField({
    required this.pharmacies,
    required this.loading,
    required this.selectedPharmacyId,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minha farmacia ja esta cadastrada',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          initialValue: selectedPharmacyId,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.store_mall_directory_outlined),
            filled: true,
            fillColor: enabled
                ? const Color(0xFFF8F9FB)
                : AppColors.surfaceMuted,
            hintText: loading
                ? 'Carregando farmacias...'
                : 'Selecione a farmacia',
          ),
          items: pharmacies.map((item) {
            final pharmacy = item as Map<String, dynamic>;
            final city = pharmacy['CITY']?.toString() ?? '';
            final state = pharmacy['STATE']?.toString() ?? '';
            final suffix = [city, state].where((e) => e.isNotEmpty).join(' - ');
            final label = suffix.isEmpty
                ? (pharmacy['NAME']?.toString() ?? 'Farmacia')
                : '${pharmacy['NAME']} ($suffix)';
            return DropdownMenuItem<int>(
              value: pharmacy['ID'] as int,
              child: Text(label, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: enabled && !loading ? onChanged : null,
        ),
      ],
    );
  }
}
