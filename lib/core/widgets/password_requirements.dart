import 'package:flutter/material.dart';
import 'package:savemed/core/theme/app_colors.dart';

class PasswordRequirements extends StatelessWidget {
  final String password;
  final String confirmation;

  const PasswordRequirements({
    super.key,
    required this.password,
    required this.confirmation,
  });

  @override
  Widget build(BuildContext context) {
    final hasMinimumLength = password.length >= 8;
    final passwordsMatch = confirmation.isNotEmpty && password == confirmation;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Requisitos da senha',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
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
        : 'Não atendido';

    return Semantics(
      label: '$label: $status',
      excludeSemantics: true,
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
