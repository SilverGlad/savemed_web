import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:savemed/core/api/api_error_message.dart';
import 'package:savemed/core/api/api_response.dart';
import 'package:savemed/core/controllers/address_controller.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/services/auth_service.dart';
import 'package:savemed/core/services/cep_lookup_service.dart';
import 'package:savemed/core/theme/app_colors.dart';
import 'package:savemed/core/utils/document_validator.dart';
import 'package:savemed/core/utils/field_validators.dart';
import 'package:savemed/core/utils/input_formatters.dart';
import 'package:savemed/core/widgets/savemed_button.dart';
import 'package:savemed/core/widgets/password_requirements.dart';
import 'package:savemed/core/widgets/savemed_footer.dart';
import 'package:savemed/core/widgets/savemed_logo.dart';
import 'package:savemed/features/auth/registration_error_mapper.dart';
import 'package:savemed/features/admin/admin_page.dart';
import 'package:savemed/features/home/home_page.dart';
import 'package:savemed/models/pharmacy_access_request.dart';
import 'package:savemed/models/pharmacy_search_result.dart';

class AuthPage extends StatefulWidget {
  final AuthService authService;

  const AuthPage({super.key, this.authService = const AuthService()});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  String loginEmailPrefill = '';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AutofillGroup(
        child: Column(
          children: [
            const _AuthHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: isLogin
                              ? LoginCard(
                                  key: const ValueKey('login'),
                                  authService: widget.authService,
                                  initialEmail: loginEmailPrefill,
                                  onSwitch: () => setState(() {
                                    loginEmailPrefill = '';
                                    isLogin = false;
                                  }),
                                  isMobile: isMobile,
                                )
                              : RegisterCard(
                                  key: const ValueKey('register'),
                                  authService: widget.authService,
                                  onSwitch: () =>
                                      setState(() => isLogin = true),
                                  onSwitchToLogin: (email) => setState(() {
                                    loginEmailPrefill = email;
                                    isLogin = true;
                                  }),
                                  isMobile: isMobile,
                                ),
                        ),
                        const SizedBox(height: 24),
                        const SaveMedFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
          borderRadius: BorderRadius.circular(8),
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
                color: AppColors.greenTint,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: const SaveMedLogoMark(width: 20, height: 34),
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
                    'Sua conta',
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
        borderRadius: BorderRadius.circular(8),
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
          FocusTraversalGroup(
            policy: ReadingOrderTraversalPolicy(),
            child: child,
          ),
        ],
      ),
    );
  }
}

class LoginCard extends StatefulWidget {
  final VoidCallback onSwitch;
  final String initialEmail;
  final bool isMobile;
  final AuthService authService;

  const LoginCard({
    super.key,
    required this.onSwitch,
    this.initialEmail = '',
    required this.isMobile,
    required this.authService,
  });

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    emailController.text = widget.initialEmail;
  }

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
      subtitle: _isSubmitting
          ? 'Entrando na sua conta...'
          : 'Acesse seus pedidos e continue sua compra.',
      isMobile: widget.isMobile,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _Input(
              label: 'Email',
              hint: 'Seu e-mail',
              icon: Icons.email_outlined,
              controller: emailController,
              enabled: !_isSubmitting,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              validator: (value) => isValidEmail(value ?? '')
                  ? null
                  : 'Informe um e-mail válido.',
            ),
            const SizedBox(height: 16),
            _Input(
              label: 'Senha',
              hint: 'Sua senha',
              icon: Icons.lock_outline,
              obscure: !_showPassword,
              controller: passwordController,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(context),
              enabled: !_isSubmitting,
              validator: (value) =>
                  (value ?? '').isEmpty ? 'Informe sua senha.' : null,
              suffix: IconButton(
                tooltip: _showPassword
                    ? 'Ocultar senha do login'
                    : 'Mostrar senha do login',
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() => _showPassword = !_showPassword),
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
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
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final authController = context.read<AuthController>();
    final addressController = context.read<AddressController>();

    if (!(_formKey.currentState?.validate() ?? false)) return;
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
              borderRadius: BorderRadius.circular(8),
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
      builder: (_) => _ForgotPasswordDialog(
        initialEmail: emailController.text,
        service: widget.authService,
      ),
    );
  }

  String _mapLoginError(Object error) {
    if (error is ApiResponseException &&
        error.code == 'PASSWORD_SETUP_REQUIRED') {
      return 'Seu convite está pendente. Use Recuperar minha senha e informe o código recebido por e-mail.';
    }
    return ApiErrorMessage.forUser(
      error,
      fallback: 'Não foi possível entrar agora. Tente novamente em instantes.',
      statusMessages: const {
        401: 'Email ou senha incorretos. Confira os dados e tente novamente.',
        403: 'Esta conta está inativa. Procure o administrador responsável.',
        404: 'Email ou senha incorretos. Confira os dados e tente novamente.',
      },
      allowValidationMessage: false,
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  final String initialEmail;
  final AuthService service;

  const _ForgotPasswordDialog({
    required this.initialEmail,
    required this.service,
  });

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _sendingCode = false;
  bool _resettingPassword = false;
  bool _codeSent = false;
  bool _showNewPassword = false;
  bool _showNewPasswordConfirmation = false;
  bool _validatingEmailOnly = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail.trim());
    _passwordController.addListener(_refreshPasswordRequirements);
    _confirmController.addListener(_refreshPasswordRequirements);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.removeListener(_refreshPasswordRequirements);
    _confirmController.removeListener(_refreshPasswordRequirements);
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text('Recuperar conta'),
      content: SizedBox(
        width: 420,
        child: AutofillGroup(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _codeSent
                        ? 'Digite o código enviado para seu e-mail e escolha uma nova senha.'
                        : 'Informe seu e-mail para receber o código de recuperação.',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _Input(
                    key: const ValueKey('forgot-email'),
                    label: 'Email',
                    hint: 'Seu e-mail',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    enabled: !_codeSent && !_sendingCode && !_resettingPassword,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    validator: (value) => isValidEmail(value ?? '')
                        ? null
                        : 'Informe um e-mail válido.',
                  ),
                  if (_codeSent) ...[
                    const SizedBox(height: 12),
                    _Input(
                      key: const ValueKey('forgot-code'),
                      label: 'Código',
                      hint: '6 dígitos',
                      icon: Icons.pin_outlined,
                      controller: _codeController,
                      enabled: !_resettingPassword,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      autofillHints: const [AutofillHints.oneTimeCode],
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (_validatingEmailOnly) return null;
                        return (value ?? '').trim().length == 6
                            ? null
                            : 'Informe o código de 6 dígitos.';
                      },
                    ),
                    const SizedBox(height: 12),
                    _Input(
                      key: const ValueKey('forgot-password'),
                      label: 'Nova senha',
                      hint: 'Nova senha',
                      icon: Icons.lock_outline,
                      obscure: !_showNewPassword,
                      controller: _passwordController,
                      enabled: !_resettingPassword,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.next,
                      validator: (value) => _validatingEmailOnly
                          ? null
                          : validatePasswordLength(value ?? ''),
                      suffix: IconButton(
                        tooltip: _showNewPassword
                            ? 'Ocultar nova senha'
                            : 'Mostrar nova senha',
                        onPressed: _resettingPassword
                            ? null
                            : () => setState(
                                () => _showNewPassword = !_showNewPassword,
                              ),
                        icon: Icon(
                          _showNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Input(
                      key: const ValueKey('forgot-password-confirmation'),
                      label: 'Confirmar nova senha',
                      hint: 'Confirme a nova senha',
                      icon: Icons.lock_outline,
                      obscure: !_showNewPasswordConfirmation,
                      controller: _confirmController,
                      enabled: !_resettingPassword,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleResetPassword(),
                      validator: (value) => _validatingEmailOnly
                          ? null
                          : validatePasswordConfirmation(
                              _passwordController.text,
                              value ?? '',
                            ),
                      suffix: IconButton(
                        tooltip: _showNewPasswordConfirmation
                            ? 'Ocultar confirmação da nova senha'
                            : 'Mostrar confirmação da nova senha',
                        onPressed: _resettingPassword
                            ? null
                            : () => setState(
                                () => _showNewPasswordConfirmation =
                                    !_showNewPasswordConfirmation,
                              ),
                        icon: Icon(
                          _showNewPasswordConfirmation
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PasswordRequirements(
                      password: _passwordController.text,
                      confirmation: _confirmController.text,
                    ),
                  ],
                ],
              ),
            ),
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
            onPressed: _sendingCode || _resettingPassword ? null : _changeEmail,
            child: const Text('Alterar e-mail'),
          ),
        if (_codeSent)
          TextButton(
            onPressed: _sendingCode || _resettingPassword
                ? null
                : _handleSendCode,
            child: const Text('Reenviar código'),
          ),
        if (!_codeSent)
          TextButton(
            onPressed: _sendingCode || _resettingPassword
                ? null
                : _useExistingCode,
            child: const Text('Já tenho um código'),
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
    final isResending = _codeSent;

    _validatingEmailOnly = true;
    final valid = _formKey.currentState?.validate() ?? false;
    _validatingEmailOnly = false;
    if (!valid) return;

    FocusScope.of(context).unfocus();
    setState(() => _sendingCode = true);

    try {
      final message = await widget.service.forgotPassword(email: email);
      if (!mounted) return;
      setState(() {
        if (isResending) _clearRecoveryCodeData();
        _codeSent = true;
      });
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

  void _useExistingCode() {
    _validatingEmailOnly = true;
    final valid = _formKey.currentState?.validate() ?? false;
    _validatingEmailOnly = false;
    if (!valid) return;
    FocusScope.of(context).unfocus();
    setState(() => _codeSent = true);
  }

  void _changeEmail() {
    setState(() {
      _codeSent = false;
      _clearRecoveryCodeData();
    });
  }

  void _clearRecoveryCodeData() {
    _codeController.clear();
    _passwordController.clear();
    _confirmController.clear();
  }

  Future<void> _handleResetPassword() async {
    final messenger = ScaffoldMessenger.of(context);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _resettingPassword = true);

    try {
      final message = await widget.service.resetPassword(
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
    return ApiErrorMessage.forUser(
      error,
      fallback:
          'Não foi possível concluir a recuperação. Tente novamente em instantes.',
    );
  }

  void _refreshPasswordRequirements() {
    if (mounted) setState(() {});
  }
}

enum RegisterProfileType { customer, pharmacy }

enum PharmacyRegistrationMode { newPharmacy, existingPharmacy }

class RegisterCard extends StatefulWidget {
  final VoidCallback onSwitch;
  final ValueChanged<String>? onSwitchToLogin;
  final bool isMobile;
  final AuthService authService;

  const RegisterCard({
    super.key,
    required this.onSwitch,
    this.onSwitchToLogin,
    required this.isMobile,
    required this.authService,
  });

  @override
  State<RegisterCard> createState() => _RegisterCardState();
}

class _RegisterCardState extends State<RegisterCard> {
  final _formKey = GlobalKey<FormState>();
  RegisterProfileType profile = RegisterProfileType.customer;
  PharmacyRegistrationMode pharmacyMode = PharmacyRegistrationMode.newPharmacy;

  final docController = TextEditingController();
  final cnpjController = TextEditingController();
  final cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final cnpjFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final nameController = TextEditingController();
  final pharmacyNameController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipcodeController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final passwordFocusNode = FocusNode();
  final confirmationFocusNode = FocusNode();
  final pharmacySearchController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSearchingPharmacies = false;
  bool _hasSearchedPharmacies = false;
  List<PharmacySearchResult> _pharmacyResults = const [];
  PharmacySearchResult? _selectedPharmacy;
  bool _loadingCep = false;
  bool _showPassword = false;
  bool _showPasswordConfirmation = false;
  String? _uncertainRegistrationEmail;
  String? _serverEmailError;
  String? _serverCnpjError;
  String? _serverPhoneError;
  int _pharmacyStep = 0;
  String? _lastFetchedCep;

  bool get isCustomer => profile == RegisterProfileType.customer;
  bool get isExistingPharmacy =>
      !isCustomer && pharmacyMode == PharmacyRegistrationMode.existingPharmacy;

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
    cnpjController.dispose();
    nameController.dispose();
    pharmacyNameController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipcodeController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    passwordFocusNode.dispose();
    confirmationFocusNode.dispose();
    pharmacySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthBaseCard(
      title: 'Crie sua conta',
      subtitle: _isSubmitting
          ? 'Criando sua conta...'
          : 'Cadastre-se para comprar e acompanhar seus pedidos.',
      isMobile: widget.isMobile,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _ProfileSelector(
              selectedProfile: profile,
              onChanged: _isSubmitting
                  ? (_) {}
                  : (value) => setState(() {
                      profile = value;
                      _pharmacyStep = 0;
                      _serverEmailError = null;
                      _serverCnpjError = null;
                      _serverPhoneError = null;
                    }),
            ),
            const SizedBox(height: 16),
            if (!isCustomer) ...[
              _PharmacyModeSelector(
                selectedMode: pharmacyMode,
                enabled: !_isSubmitting,
                onChanged: (mode) => setState(() {
                  pharmacyMode = mode;
                  _pharmacyStep = 0;
                  _serverEmailError = null;
                  _serverCnpjError = null;
                  _serverPhoneError = null;
                }),
              ),
              const SizedBox(height: 12),
            ],
            if (!isCustomer && !isExistingPharmacy) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FAF8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nova farmácia',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Cadastre a farmácia e o primeiro administrador em uma única operação.',
                      style: TextStyle(color: AppColors.textLight, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _RegistrationSteps(currentStep: _pharmacyStep),
              const SizedBox(height: 4),
            ],
            if (isExistingPharmacy) _buildExistingPharmacyRequest(),
            if (!isExistingPharmacy && (isCustomer || _pharmacyStep == 1)) ...[
              _Input(
                key: const ValueKey('register-document'),
                label: isCustomer ? 'CPF' : 'CNPJ',
                hint: isCustomer ? 'CPF' : 'CNPJ',
                icon: Icons.badge_outlined,
                controller: isCustomer ? docController : cnpjController,
                onChanged: isCustomer
                    ? null
                    : (_) {
                        if (_serverCnpjError != null) {
                          setState(() => _serverCnpjError = null);
                        }
                      },
                inputFormatters: [isCustomer ? cpfFormatter : cnpjFormatter],
                enabled: !_isSubmitting,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (!isCustomer && _serverCnpjError != null) {
                    return _serverCnpjError;
                  }
                  final valid = isCustomer
                      ? isValidCPF(value ?? '')
                      : isValidCNPJ(value ?? '');
                  if (valid) return null;
                  return isCustomer
                      ? 'Informe um CPF válido.'
                      : 'Informe um CNPJ válido.';
                },
              ),
              const SizedBox(height: 12),
            ],
            if (!isExistingPharmacy && (isCustomer || _pharmacyStep == 0))
              _Input(
                key: const ValueKey('register-name'),
                label: isCustomer ? 'Nome completo' : 'Nome do responsável',
                hint: isCustomer ? 'Nome completo' : 'Nome completo',
                icon: Icons.person_outline,
                controller: nameController,
                enabled: !_isSubmitting,
                autofillHints: const [AutofillHints.name],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: !isCustomer && !isExistingPharmacy
                    ? (_) => _advancePharmacyStep()
                    : null,
                validator: (value) => isValidRequiredText(value ?? '')
                    ? null
                    : 'Informe o nome completo.',
              ),
            if (!isCustomer && !isExistingPharmacy && _pharmacyStep == 1) ...[
              const SizedBox(height: 12),
              _Input(
                key: const ValueKey('register-pharmacy-name'),
                label: 'Nome da nova farmácia',
                hint: 'Nome da farmácia',
                icon: Icons.local_pharmacy_outlined,
                controller: pharmacyNameController,
                enabled: !_isSubmitting,
                autofillHints: const [AutofillHints.organizationName],
                textInputAction: TextInputAction.next,
                validator: (value) => isValidRequiredText(value ?? '')
                    ? null
                    : 'Informe o nome da farmácia.',
              ),
              const SizedBox(height: 12),
              _Input(
                key: const ValueKey('register-city'),
                label: 'Cidade',
                hint: 'Cidade',
                icon: Icons.location_city_outlined,
                controller: cityController,
                enabled: !_isSubmitting,
                autofillHints: const [AutofillHints.addressCity],
                textInputAction: TextInputAction.next,
                validator: (value) => isValidRequiredText(value ?? '')
                    ? null
                    : 'Informe a cidade.',
              ),
              const SizedBox(height: 12),
              _Input(
                key: const ValueKey('register-state'),
                label: 'UF',
                hint: 'UF',
                icon: Icons.map_outlined,
                controller: stateController,
                enabled: !_isSubmitting,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                  LengthLimitingTextInputFormatter(2),
                ],
                autofillHints: const [AutofillHints.addressState],
                textInputAction: TextInputAction.next,
                validator: (value) => (value ?? '').trim().length == 2
                    ? null
                    : 'Informe uma UF valida.',
              ),
              const SizedBox(height: 12),
              _Input(
                key: const ValueKey('register-zipcode'),
                label: 'CEP',
                hint: '00000-000',
                icon: Icons.markunread_mailbox_outlined,
                controller: zipcodeController,
                enabled: !_isSubmitting,
                inputFormatters: [cepFormatter],
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.postalCode],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _advancePharmacyStep(),
                validator: (value) => digitsOnly(value ?? '').length == 8
                    ? null
                    : 'Informe um CEP válido.',
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
            if (!isExistingPharmacy && (isCustomer || _pharmacyStep == 2)) ...[
              const SizedBox(height: 12),
              _Input(
                key: const ValueKey('register-email'),
                label: 'Email',
                hint: 'Email',
                icon: Icons.email_outlined,
                controller: emailController,
                onChanged: (_) {
                  if (_serverEmailError != null) {
                    setState(() => _serverEmailError = null);
                  }
                },
                enabled: !_isSubmitting,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (_serverEmailError != null) return _serverEmailError;
                  return isValidEmail(value ?? '')
                      ? null
                      : 'Informe um e-mail válido.';
                },
              ),
              const SizedBox(height: 12),
              _Input(
                key: const ValueKey('register-phone'),
                label: 'Telefone',
                hint: '(00) 00000-0000',
                icon: Icons.phone_outlined,
                controller: phoneController,
                inputFormatters: [phoneFormatter],
                onChanged: (_) {
                  if (_serverPhoneError != null) {
                    setState(() => _serverPhoneError = null);
                  }
                },
                enabled: !_isSubmitting,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                textInputAction: isCustomer
                    ? TextInputAction.next
                    : TextInputAction.done,
                onFieldSubmitted: !isCustomer
                    ? (_) => _advancePharmacyStep()
                    : null,
                validator: (value) {
                  if (_serverPhoneError != null) return _serverPhoneError;
                  return isValidPhone(value ?? '')
                      ? null
                      : 'Informe um telefone válido com DDD.';
                },
              ),
            ],
            if (!isExistingPharmacy && (isCustomer || _pharmacyStep == 3)) ...[
              const SizedBox(height: 12),
              if (!isCustomer) ...[
                const _RegistrationNotice(
                  icon: Icons.check_circle_outline,
                  text:
                      'A farmácia e o acesso administrativo serão ativados imediatamente. Depois do cadastro, entre com o e-mail e a senha informados.',
                ),
                const SizedBox(height: 12),
              ],
              _Input(
                key: const ValueKey('register-password'),
                label: 'Senha',
                hint: 'Crie uma senha',
                icon: Icons.lock_outline,
                obscure: !_showPassword,
                controller: passwordController,
                focusNode: passwordFocusNode,
                enabled: !_isSubmitting,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => confirmationFocusNode.requestFocus(),
                validator: (value) => validatePasswordLength(value ?? ''),
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
                hint: 'Repita a senha',
                icon: Icons.lock_outline,
                obscure: !_showPasswordConfirmation,
                controller: confirmController,
                focusNode: confirmationFocusNode,
                enabled: !_isSubmitting,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleRegister(context),
                validator: (value) => validatePasswordConfirmation(
                  passwordController.text,
                  value ?? '',
                ),
                suffix: IconButton(
                  tooltip: _showPasswordConfirmation
                      ? 'Ocultar confirmação'
                      : 'Mostrar confirmação',
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
              PasswordRequirements(
                password: passwordController.text,
                confirmation: confirmController.text,
              ),
            ],
            if (_uncertainRegistrationEmail != null) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE4BC76)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF80530D)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Não foi possível confirmar se a conta foi criada '
                          'usando ${_uncertainRegistrationEmail!}. Tente '
                          'entrar com esse endereço antes de enviar novamente.',
                          style: TextStyle(
                            color: AppColors.textDark,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  key: const ValueKey('registration-uncertain-login'),
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          final email = _uncertainRegistrationEmail;
                          if (email != null && widget.onSwitchToLogin != null) {
                            widget.onSwitchToLogin!(email);
                          } else {
                            widget.onSwitch();
                          }
                        },
                  icon: const Icon(Icons.login),
                  label: const Text('Ir para login'),
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (isExistingPharmacy)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: SaveMedButton(
                  loading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _handleAccessRequest,
                  label: 'Enviar solicitação',
                ),
              )
            else if (isCustomer)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: SaveMedButton(
                  loading: _isSubmitting,
                  onPressed: _isSubmitting
                      ? null
                      : () => _handleRegister(context),
                  label: 'Criar conta',
                ),
              )
            else
              Row(
                children: [
                  if (_pharmacyStep > 0) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () => setState(() => _pharmacyStep--),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Voltar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: _pharmacyStep < 3
                          ? FilledButton.icon(
                              onPressed: _isSubmitting
                                  ? null
                                  : _advancePharmacyStep,
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Continuar'),
                            )
                          : SaveMedButton(
                              loading: _isSubmitting,
                              onPressed: _isSubmitting
                                  ? null
                                  : () => _handleRegister(context),
                              label: 'Criar conta e farmácia',
                            ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isSubmitting ? null : widget.onSwitch,
              child: const Text('Fazer login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingPharmacyRequest() {
    return Column(
      children: [
        const _RegistrationNotice(
          icon: Icons.verified_user_outlined,
          text:
              'Busque por nome, cidade, CNPJ ou ID. A solicitação não pede senha. Após a aprovação, você receberá um código para definir a sua.',
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('access-pharmacy-search'),
          controller: pharmacySearchController,
          enabled: !_isSubmitting && !_isSearchingPharmacies,
          textInputAction: TextInputAction.search,
          onFieldSubmitted: (_) => _searchPharmacies(),
          decoration: InputDecoration(
            labelText: 'Buscar farmácia',
            hintText: 'Nome ou CNPJ',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearchingPharmacies
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    tooltip: 'Buscar farmácia',
                    onPressed: _searchPharmacies,
                    icon: const Icon(Icons.arrow_forward),
                  ),
          ),
        ),
        if (_hasSearchedPharmacies && _pharmacyResults.isEmpty) ...[
          const SizedBox(height: 10),
          const _RegistrationNotice(
            icon: Icons.search_off_outlined,
            text:
                'Nenhuma farmácia encontrada. Revise a busca ou escolha Nova farmácia.',
          ),
        ],
        if (_pharmacyResults.isNotEmpty) ...[
          const SizedBox(height: 10),
          FormField<PharmacySearchResult>(
            key: ValueKey(
              'access-pharmacy-options-${_pharmacyResults.map((item) => item.id).join('-')}',
            ),
            initialValue: _selectedPharmacy,
            validator: (value) => value == null
                ? 'Selecione a farmácia para a qual deseja acesso.'
                : null,
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _pharmacyResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final pharmacy = _pharmacyResults[index];
                      final selected = field.value?.id == pharmacy.id;
                      final details = [
                        if (pharmacy.location.isNotEmpty) pharmacy.location,
                        if (pharmacy.maskedCnpj != null) pharmacy.maskedCnpj!,
                        'ID ${pharmacy.id}',
                      ].join(' | ');
                      return ListTile(
                        selected: selected,
                        onTap: _isSubmitting
                            ? null
                            : () {
                                field.didChange(pharmacy);
                                setState(() => _selectedPharmacy = pharmacy);
                              },
                        leading: Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: selected ? AppColors.primary : null,
                        ),
                        title: Text(pharmacy.name),
                        subtitle: Text(details),
                      );
                    },
                  ),
                ),
                if (field.hasError) ...[
                  const SizedBox(height: 6),
                  Text(
                    field.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        _Input(
          key: const ValueKey('access-responsible-name'),
          label: 'Nome do responsável',
          hint: 'Nome completo',
          icon: Icons.person_outline,
          controller: nameController,
          enabled: !_isSubmitting,
          autofillHints: const [AutofillHints.name],
          textInputAction: TextInputAction.next,
          validator: (value) => isValidRequiredText(value ?? '')
              ? null
              : 'Informe o nome completo.',
        ),
        const SizedBox(height: 12),
        _Input(
          key: const ValueKey('access-responsible-document'),
          label: 'CPF do responsável',
          hint: '000.000.000-00',
          icon: Icons.badge_outlined,
          controller: docController,
          inputFormatters: [cpfFormatter],
          enabled: !_isSubmitting,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: (value) =>
              isValidCPF(value ?? '') ? null : 'Informe um CPF válido.',
        ),
        const SizedBox(height: 12),
        _Input(
          key: const ValueKey('access-email'),
          label: 'Email',
          hint: 'responsavel@empresa.com.br',
          icon: Icons.email_outlined,
          controller: emailController,
          enabled: !_isSubmitting,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
          validator: (value) =>
              isValidEmail(value ?? '') ? null : 'Informe um e-mail válido.',
        ),
        const SizedBox(height: 12),
        _Input(
          key: const ValueKey('access-phone'),
          label: 'Telefone',
          hint: '(00) 00000-0000',
          icon: Icons.phone_outlined,
          controller: phoneController,
          inputFormatters: [phoneFormatter],
          enabled: !_isSubmitting,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleAccessRequest(),
          validator: (value) => isValidPhone(value ?? '')
              ? null
              : 'Informe um telefone válido com DDD.',
        ),
      ],
    );
  }

  Future<void> _searchPharmacies() async {
    final query = pharmacySearchController.text.trim();
    if (query.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite ao menos 2 caracteres para buscar.'),
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isSearchingPharmacies = true);
    try {
      final results = await widget.authService.searchPharmaciesForAccess(query);
      if (!mounted) return;
      setState(() {
        _pharmacyResults = results;
        _selectedPharmacy = null;
        _hasSearchedPharmacies = true;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ApiErrorMessage.forUser(
              error,
              fallback: 'Não foi possível buscar farmácias. Tente novamente.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSearchingPharmacies = false);
    }
  }

  Future<void> _handleAccessRequest() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final pharmacy = _selectedPharmacy;
    if (pharmacy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Busque e selecione uma farmácia.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
    });
    try {
      final message = await widget.authService.requestPharmacyAccess(
        PharmacyAccessRequest(
          pharmacyId: pharmacy.id,
          responsibleName: nameController.text,
          responsibleDocument: docController.text,
          email: emailController.text,
          phone: phoneController.text,
        ),
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Solicitação enviada'),
          content: Text(
            '$message Acompanhe as próximas instruções pelo e-mail informado.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
      if (mounted) widget.onSwitch();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ApiErrorMessage.forUser(
              error,
              fallback:
                  'Não foi possível enviar a solicitação. Tente novamente.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _advancePharmacyStep() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _pharmacyStep++);
  }

  Future<void> _handleRegister(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final focusScope = FocusScope.of(context);
    final authController = context.read<AuthController>();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_uncertainRegistrationEmail != null) {
      final shouldRetry = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Confirmar novo envio'),
          content: Text(
            'A tentativa anterior para $_uncertainRegistrationEmail pode ter '
            'criado a conta. Tente entrar com esse endereço antes de enviar '
            'novamente. Quer continuar mesmo assim?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Enviar novamente'),
            ),
          ],
        ),
      );
      if (shouldRetry != true || !mounted) return;
    }

    focusScope.unfocus();
    setState(() {
      _isSubmitting = true;
      _uncertainRegistrationEmail = null;
    });

    try {
      await authController.register(
        isCustomer: isCustomer,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        document: isCustomer ? docController.text : cnpjController.text,
        phone: phoneController.text,
        pharmacyName: isCustomer ? null : pharmacyNameController.text.trim(),
        city: isCustomer ? null : cityController.text.trim(),
        state: isCustomer ? null : stateController.text.trim().toUpperCase(),
        zipcode: isCustomer ? null : zipcodeController.text.trim(),
      );

      if (!mounted) return;
      TextInput.finishAutofillContext(shouldSave: true);
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Conta criada com sucesso. Agora entre com seu e-mail e senha.',
          ),
        ),
      );
      widget.onSwitch();
    } catch (e) {
      if (!mounted) return;
      final outcomeUnknown = RegistrationErrorMapper.hasUncertainOutcome(e);
      if (outcomeUnknown) {
        setState(
          () => _uncertainRegistrationEmail = emailController.text.trim(),
        );
      } else {
        final fieldError = RegistrationErrorMapper.fieldError(e);
        if (fieldError != null) {
          setState(() {
            if (fieldError.$1 == 'email') {
              _serverEmailError = fieldError.$2;
              if (!isCustomer) _pharmacyStep = 2;
            } else if (fieldError.$1 == 'phone') {
              _serverPhoneError = fieldError.$2;
              if (!isCustomer) _pharmacyStep = 2;
            } else {
              _serverCnpjError = fieldError.$2;
              _pharmacyStep = 1;
            }
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _formKey.currentState?.validate();
          });
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text(RegistrationErrorMapper.message(e)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
      final address = await CepLookupService.lookup(rawCep);
      if (address == null) return;

      cityController.text = address.city;
      stateController.text = address.state;
      _lastFetchedCep = rawCep;
    } catch (_) {
      // Ignora falhas de CEP e deixa o preenchimento manual disponível.
    } finally {
      if (mounted) {
        setState(() => _loadingCep = false);
      }
    }
  }
}

class _RegistrationSteps extends StatelessWidget {
  final int currentStep;

  const _RegistrationSteps({required this.currentStep});

  static const _labels = ['Responsável', 'Farmácia', 'Contato', 'Segurança'];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Etapa ${currentStep + 1} de ${_labels.length}: ${_labels[currentStep]}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Etapa ${currentStep + 1} de ${_labels.length}',
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(_labels.length, (index) {
              final active = index <= currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(
                    right: index == _labels.length - 1 ? 0 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _labels[currentStep],
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistrationNotice extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RegistrationNotice({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryDark),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
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
  final FocusNode? focusNode;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;

  const _Input({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.enabled = true,
    this.inputFormatters,
    this.controller,
    this.focusNode,
    this.suffix,
    this.keyboardType,
    this.autofillHints,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          obscureText: obscure,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          validator: validator,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          maxLines: 1,
          decoration: InputDecoration(
            hint: Text(
              hint,
              semanticsLabel: label,
              style: Theme.of(context).textTheme.bodyLarge?.merge(
                Theme.of(context).inputDecorationTheme.hintStyle,
              ),
            ),
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
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<RegisterProfileType>(
        segments: const [
          ButtonSegment(
            value: RegisterProfileType.customer,
            icon: Icon(Icons.person_outline),
            label: Text('Cliente'),
          ),
          ButtonSegment(
            value: RegisterProfileType.pharmacy,
            icon: Icon(Icons.local_pharmacy_outlined),
            label: Text('Farmácia'),
          ),
        ],
        selected: {selectedProfile},
        onSelectionChanged: (selection) => onChanged(selection.first),
        showSelectedIcon: false,
        expandedInsets: EdgeInsets.zero,
        style: const ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size.fromHeight(48)),
        ),
      ),
    );
  }
}

class _PharmacyModeSelector extends StatelessWidget {
  final PharmacyRegistrationMode selectedMode;
  final bool enabled;
  final ValueChanged<PharmacyRegistrationMode> onChanged;

  const _PharmacyModeSelector({
    required this.selectedMode,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<PharmacyRegistrationMode>(
        segments: const [
          ButtonSegment(
            value: PharmacyRegistrationMode.newPharmacy,
            icon: Icon(Icons.add_business_outlined),
            label: Text('Nova farmácia'),
          ),
          ButtonSegment(
            value: PharmacyRegistrationMode.existingPharmacy,
            icon: Icon(Icons.how_to_reg_outlined),
            label: Text('Solicitar acesso'),
          ),
        ],
        selected: {selectedMode},
        onSelectionChanged: enabled
            ? (selection) => onChanged(selection.first)
            : null,
        showSelectedIcon: false,
      ),
    );
  }
}
