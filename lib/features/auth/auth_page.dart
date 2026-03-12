import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:SaveMed/core/controllers/auth_controller.dart';
import 'package:SaveMed/core/theme/app_colors.dart';
import 'package:SaveMed/core/utils/document_validator.dart';
import 'package:SaveMed/core/utils/input_formatters.dart';
import 'package:SaveMed/core/widgets/savemed_button.dart';
import 'package:SaveMed/core/widgets/savemed_footer.dart';
import 'package:SaveMed/core/widgets/savemed_header.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: Column(
        children: [
          SaveMedHeader(),
          SizedBox(height: isMobile ? 24 : 48),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
              child: Column(
                children: [
                  Center(
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
                  SizedBox(height: isMobile ? 32 : 48),
                  const SaveMedFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ======================================================
 * BASE CARD
 * ====================================================== */

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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
            style: const TextStyle(color: Colors.black54),
          ),
          SizedBox(height: isMobile ? 24 : 32),
          child,
        ],
      ),
    );
  }
}

/* ======================================================
 * LOGIN
 * ====================================================== */

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

  @override
  Widget build(BuildContext context) {
    return AuthBaseCard(
      title: 'Bem-vindo de volta',
      subtitle: 'Novo por aqui?',
      isMobile: widget.isMobile,
      child: Column(
        children: [
          _Input(
            label: 'Email',
            hint: 'Seu email',
            icon: Icons.email_outlined,
            controller: emailController,
          ),
          const SizedBox(height: 16),
          _Input(
            label: 'Senha',
            hint: 'Sua senha',
            icon: Icons.lock_outline,
            obscure: true,
            controller: passwordController,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: SaveMedButton(
              onPressed: () async {
                try {
                  await context.read<AuthController>().login(
                    emailController.text,
                    passwordController.text,
                    context,
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              label: 'Entrar',
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: widget.onSwitch,
            child: const Text('Criar conta'),
          ),
        ],
      ),
    );
  }
}

/* ======================================================
 * REGISTER
 * ====================================================== */

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
  Widget build(BuildContext context) {
    return AuthBaseCard(
      title: 'Crie sua conta',
      subtitle: 'Já tem conta?',
      isMobile: widget.isMobile,
      child: Column(
        children: [
          _ProfileSelector(
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
            label: isCustomer ? 'Nome completo' : 'Razão social',
            hint: isCustomer ? 'Nome completo' : 'Razão social',
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
                final valid = isCustomer
                    ? isValidCPF(docController.text)
                    : isValidCNPJ(docController.text);

                if (!valid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isCustomer ? 'CPF inválido' : 'CNPJ inválido',
                      ),
                    ),
                  );
                  return;
                }

                if (passwordController.text.length < 8 ||
                    passwordController.text != confirmController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Senha inválida')),
                  );
                  return;
                }

                try {
                  await context.read<AuthController>().register(
                    isCustomer: isCustomer,
                    name: nameController.text,
                    email: emailController.text,
                    password: passwordController.text,
                    document: docController.text,
                    phone: phoneController.text,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Conta criada com sucesso')),
                  );

                  widget.onSwitch();
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
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

/* ======================================================
 * INPUT
 * ====================================================== */

class _Input extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;

  const _Input({
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
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
          obscureText: obscure,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

/* ======================================================
 * PROFILE SELECTOR
 * ====================================================== */

class _ProfileSelector extends StatelessWidget {
  final ValueChanged<RegisterProfileType> onChanged;

  const _ProfileSelector({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _button('Cliente', true, () => onChanged(RegisterProfileType.customer)),
        const SizedBox(width: 8),
        _button('Vendedor', false, () => onChanged(RegisterProfileType.seller)),
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
