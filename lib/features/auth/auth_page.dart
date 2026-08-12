import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:savemed/core/controllers/address_controller.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/services/auth_service.dart';
import 'package:savemed/core/theme/app_colors.dart';
import 'package:savemed/core/utils/document_validator.dart';
import 'package:savemed/core/utils/field_validators.dart';
import 'package:savemed/core/utils/input_formatters.dart';
import 'package:savemed/core/widgets/savemed_button.dart';
import 'package:savemed/core/widgets/savemed_footer.dart';
import 'package:savemed/features/admin/admin_page.dart';
import 'package:savemed/features/home/home_page.dart';

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

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1180),
      child: Container(
        margin: EdgeInsets.fromLTRB(
          isMobile ? 12 : 0,
          12,
          isMobile ? 12 : 0,
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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () => _openForgotPasswordDialog(),
              child: const Text('Esqueci minha senha'),
            ),
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
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              authController.isAdmin ? const AdminPage() : const HomePage(),
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

  Future<void> _openForgotPasswordDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => _ForgotPasswordDialog(initialEmail: emailController.text),
    );
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

    if (message.contains('usuario') || message.contains('usuário')) {
      return 'Usuario nao encontrado. Verifique o email cadastrado.';
    }

    if (message.contains('jwt') || message.contains('secret')) {
      return 'A API esta com erro de configuracao de login. Acione o suporte.';
    }

    return 'Nao foi possivel entrar agora. Tente novamente em instantes.';
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  final String initialEmail;

  const _ForgotPasswordDialog({required this.initialEmail});

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final _service = AuthService();
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _sendingCode = false;
  bool _resettingPassword = false;
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Recuperar conta'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _codeSent
                    ? 'Digite o código enviado para seu email e escolha uma nova senha.'
                    : 'Informe seu email para receber o código de recuperação.',
                style: const TextStyle(
                  color: AppColors.textLight,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              _Input(
                label: 'Email',
                hint: 'Seu email',
                icon: Icons.email_outlined,
                controller: _emailController,
                enabled: !_sendingCode && !_resettingPassword,
              ),
              if (_codeSent) ...[
                const SizedBox(height: 12),
                _Input(
                  label: 'Código',
                  hint: '6 dígitos',
                  icon: Icons.pin_outlined,
                  controller: _codeController,
                  enabled: !_resettingPassword,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
                const SizedBox(height: 12),
                _Input(
                  label: 'Nova senha',
                  hint: 'Nova senha',
                  icon: Icons.lock_outline,
                  obscure: true,
                  controller: _passwordController,
                  enabled: !_resettingPassword,
                ),
                const SizedBox(height: 12),
                _Input(
                  label: 'Confirmar nova senha',
                  hint: 'Confirme a nova senha',
                  icon: Icons.lock_outline,
                  obscure: true,
                  controller: _confirmController,
                  enabled: !_resettingPassword,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sendingCode || _resettingPassword
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        if (_codeSent)
          TextButton(
            onPressed: _sendingCode || _resettingPassword
                ? null
                : _handleSendCode,
            child: const Text('Reenviar código'),
          ),
        FilledButton(
          onPressed: _sendingCode || _resettingPassword
              ? null
              : _codeSent
              ? _handleResetPassword
              : _handleSendCode,
          child: Text(
            _sendingCode
                ? 'Enviando...'
                : _resettingPassword
                ? 'Salvando...'
                : _codeSent
                ? 'Redefinir senha'
                : 'Enviar código',
          ),
        ),
      ],
    );
  }

  Future<void> _handleSendCode() async {
    final messenger = ScaffoldMessenger.of(context);
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Informe seu email para continuar')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _sendingCode = true);

    try {
      final message = await _service.forgotPassword(email: email);
      if (!mounted) return;
      setState(() => _codeSent = true);
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(_cleanErrorMessage(e))));
    } finally {
      if (mounted) {
        setState(() => _sendingCode = false);
      }
    }
  }

  Future<void> _handleResetPassword() async {
    final messenger = ScaffoldMessenger.of(context);

    if (_codeController.text.trim().length != 6) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Informe o código de 6 dígitos')),
      );
      return;
    }

    if (_passwordController.text.length < 8 ||
        _passwordController.text != _confirmController.text) {
      messenger.showSnackBar(
        const SnackBar(content: Text('A nova senha está inválida')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _resettingPassword = true);

    try {
      final message = await _service.resetPassword(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(_cleanErrorMessage(e))));
    } finally {
      if (mounted) {
        setState(() => _resettingPassword = false);
      }
    }
  }

  String _cleanErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

enum RegisterProfileType { customer, pharmacy }

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
  bool _isSubmitting = false;
  bool _loadingCep = false;
  bool _showPassword = false;
  bool _showPasswordConfirmation = false;
  String? _lastFetchedCep;

  bool get isCustomer => profile == RegisterProfileType.customer;

  @override
  void initState() {
    super.initState();
    zipcodeController.addListener(_handleZipcodeChanged);
    passwordController.addListener(_refreshPasswordRequirements);
    confirmController.addListener(_refreshPasswordRequirements);
  }

  @override
  void dispose() {
    zipcodeController.removeListener(_handleZipcodeChanged);
    passwordController.removeListener(_refreshPasswordRequirements);
    confirmController.removeListener(_refreshPasswordRequirements);
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
                : (value) => setState(() => profile = value),
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
                    'Cadastre os dados da nova farmacia e do responsavel pela conta administrativa.',
                    style: TextStyle(color: AppColors.textLight, height: 1.4),
                  ),
                ],
              ),
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
            key: const ValueKey('register-password'),
            label: 'Senha',
            hint: 'Crie uma senha',
            icon: Icons.lock_outline,
            obscure: !_showPassword,
            controller: passwordController,
            enabled: !_isSubmitting,
            suffix: IconButton(
              tooltip: _showPassword ? 'Ocultar senha' : 'Mostrar senha',
              onPressed: _isSubmitting
                  ? null
                  : () => setState(() => _showPassword = !_showPassword),
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Input(
            key: const ValueKey('register-password-confirmation'),
            label: 'Confirmar senha',
            hint: 'Digite a senha novamente',
            icon: Icons.lock_outline,
            obscure: !_showPasswordConfirmation,
            controller: confirmController,
            enabled: !_isSubmitting,
            suffix: IconButton(
              tooltip: _showPasswordConfirmation
                  ? 'Ocultar confirmacao'
                  : 'Mostrar confirmacao',
              onPressed: _isSubmitting
                  ? null
                  : () => setState(
                      () => _showPasswordConfirmation =
                          !_showPasswordConfirmation,
                    ),
              icon: Icon(
                _showPasswordConfirmation
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PasswordRequirements(
            password: passwordController.text,
            confirmation: confirmController.text,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: SaveMedButton(
              loading: _isSubmitting,
              onPressed: _isSubmitting ? null : () => _handleRegister(context),
              label: isCustomer ? 'Criar conta' : 'Criar conta e farmacia',
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

    if (!isValidRequiredText(nameController.text)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Informe o nome completo.')),
      );
      return;
    }

    if (!isValidEmail(emailController.text)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Informe um email valido.')),
      );
      return;
    }

    if (!isValidPhone(phoneController.text)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Informe um telefone valido com DDD.')),
      );
      return;
    }

    if (!valid) {
      messenger.showSnackBar(
        SnackBar(content: Text(isCustomer ? 'CPF invalido' : 'CNPJ invalido')),
      );
      return;
    }

    if (!isCustomer &&
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

    final passwordError = validatePassword(
      passwordController.text,
      confirmController.text,
    );
    if (passwordError != null) {
      messenger.showSnackBar(SnackBar(content: Text(passwordError)));
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
        pharmacyName: isCustomer ? null : pharmacyNameController.text.trim(),
        city: isCustomer ? null : cityController.text.trim(),
        state: isCustomer ? null : stateController.text.trim().toUpperCase(),
        zipcode: isCustomer ? null : zipcodeController.text.trim(),
      );

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isCustomer
                ? 'Conta criada com sucesso'
                : 'Conta de farmacia criada com sucesso. Verifique seu email.',
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
    if (isCustomer) return;

    final rawCep = zipcodeController.text.replaceAll(RegExp(r'\D'), '');
    if (rawCep.length != 8 || rawCep == _lastFetchedCep || _loadingCep) return;

    _fetchCep(rawCep);
  }

  void _refreshPasswordRequirements() {
    if (mounted) setState(() {});
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

  const _Input({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.enabled = true,
    this.inputFormatters,
    this.controller,
    this.suffix,
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
          maxLines: 1,
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

class _PasswordRequirements extends StatelessWidget {
  final String password;
  final String confirmation;

  const _PasswordRequirements({
    required this.password,
    required this.confirmation,
  });

  @override
  Widget build(BuildContext context) {
    final hasMinimumLength = password.length >= 8;
    final passwordsMatch = confirmation.isNotEmpty && password == confirmation;

    return Semantics(
      container: true,
      label: 'Requisitos da senha',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sua senha deve:',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _PasswordRequirementRow(
              label: 'Ter pelo menos 8 caracteres',
              met: hasMinimumLength,
              active: password.isNotEmpty,
            ),
            const SizedBox(height: 6),
            _PasswordRequirementRow(
              label: 'Ser igual nos dois campos',
              met: passwordsMatch,
              active: confirmation.isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordRequirementRow extends StatelessWidget {
  final String label;
  final bool met;
  final bool active;

  const _PasswordRequirementRow({
    required this.label,
    required this.met,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = !active
        ? AppColors.textLight
        : met
        ? AppColors.success
        : AppColors.danger;
    final icon = !active
        ? Icons.radio_button_unchecked
        : met
        ? Icons.check_circle
        : Icons.cancel;
    final status = !active
        ? 'Pendente'
        : met
        ? 'Atendido'
        : 'Nao atendido';

    return Semantics(
      label: '$label: $status',
      child: Row(
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
