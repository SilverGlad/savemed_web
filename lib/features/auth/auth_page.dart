import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:SaveMed/core/controllers/address_controller.dart';
import 'package:SaveMed/core/controllers/auth_controller.dart';
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              const _AuthHeader(),
              SizedBox(height: isMobile ? 12 : 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 12 : 24,
                    0,
                    isMobile ? 12 : 24,
                    24,
                  ),
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
                                      duration: const Duration(milliseconds: 250),
                                      child: isLogin
                                          ? LoginCard(
                                              key: const ValueKey('login'),
                                              onSwitch: () => setState(() => isLogin = false),
                                              isMobile: isMobile,
                                            )
                                          : RegisterCard(
                                              key: const ValueKey('register'),
                                              onSwitch: () => setState(() => isLogin = true),
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
                                  onSwitch: () => setState(() => isLogin = false),
                                  isMobile: isMobile,
                                )
                              : RegisterCard(
                                  key: const ValueKey('register'),
                                  onSwitch: () => setState(() => isLogin = true),
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
            ],
          ),
        ),
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
          style: TextStyle(
            color: AppColors.textLight,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _HeroInfo(icon: Icons.receipt_long_outlined, label: 'Pedidos'),
            _HeroInfo(icon: Icons.local_shipping_outlined, label: 'Entrega'),
            _HeroInfo(icon: Icons.admin_panel_settings_outlined, label: 'Administracao'),
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
      margin: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 12, isMobile ? 16 : 24, 12),
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

enum RegisterProfileType { customer, seller }

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
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool get isCustomer => profile == RegisterProfileType.customer;

  @override
  void dispose() {
    docController.dispose();
    nameController.dispose();
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
      subtitle: 'Ja tem conta?',
      isMobile: widget.isMobile,
      child: Column(
        children: [
          _ProfileSelector(
            selectedProfile: profile,
            onChanged: (value) => setState(() => profile = value),
          ),
          const SizedBox(height: 16),
          _Input(
            label: isCustomer ? 'CPF' : 'CNPJ',
            hint: isCustomer ? 'CPF' : 'CNPJ',
            icon: Icons.badge_outlined,
            controller: docController,
            inputFormatters: [isCustomer ? cpfFormatter : cnpjFormatter],
          ),
          const SizedBox(height: 12),
          _Input(
            label: isCustomer ? 'Nome completo' : 'Razao social',
            hint: isCustomer ? 'Nome completo' : 'Razao social',
            icon: Icons.person_outline,
            controller: nameController,
          ),
          const SizedBox(height: 12),
          _Input(
            label: 'Email',
            hint: 'Email',
            icon: Icons.email_outlined,
            controller: emailController,
          ),
          const SizedBox(height: 12),
          _Input(
            label: 'Telefone',
            hint: '(00) 00000-0000',
            icon: Icons.phone_outlined,
            controller: phoneController,
            inputFormatters: [phoneFormatter],
          ),
          const SizedBox(height: 12),
          _Input(
            label: 'Senha',
            hint: 'Senha',
            icon: Icons.lock_outline,
            obscure: true,
            controller: passwordController,
          ),
          const SizedBox(height: 12),
          _Input(
            label: 'Confirmar senha',
            hint: 'Confirmar senha',
            icon: Icons.lock_outline,
            obscure: true,
            controller: confirmController,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: SaveMedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final authController = context.read<AuthController>();
                final valid = isCustomer
                    ? isValidCPF(docController.text)
                    : isValidCNPJ(docController.text);

                if (!valid) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        isCustomer ? 'CPF invalido' : 'CNPJ invalido',
                      ),
                    ),
                  );
                  return;
                }

                if (passwordController.text.length < 8 ||
                    passwordController.text != confirmController.text) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Senha invalida')),
                  );
                  return;
                }

                try {
                  await authController.register(
                    isCustomer: isCustomer,
                    name: nameController.text,
                    email: emailController.text,
                    password: passwordController.text,
                    document: docController.text,
                    phone: phoneController.text,
                  );

                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Conta criada com sucesso')),
                  );
                  widget.onSwitch();
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              label: 'Criar conta',
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onSwitch,
            child: const Text('Fazer login'),
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

  const _Input({
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.enabled = true,
    this.inputFormatters,
    this.controller,
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
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: enabled ? const Color(0xFFF8F9FB) : AppColors.surfaceMuted,
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
          'Vendedor',
          !isCustomerActive,
          () => onChanged(RegisterProfileType.seller),
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
