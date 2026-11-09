import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SaveMedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final double height;
  final IconData? icon; // 👈 NOVO (opcional)

  const SaveMedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.outlined = false,
    this.height = 48,
    this.icon, // 👈 opcional
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || loading;
    final theme = Theme.of(context);

    final backgroundColor = outlined
        ? Colors.transparent
        : (isDisabled
              ? AppColors.primary.withValues(alpha: 0.45)
              : AppColors.primary);

    final foregroundColor = outlined ? AppColors.primary : Colors.white;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: double.infinity, minHeight: height),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: outlined ? 0 : 1,
          shadowColor: AppColors.primary.withValues(alpha: 0.24),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: outlined
                ? const BorderSide(color: AppColors.primary)
                : BorderSide.none,
          ),
          textStyle: theme.textTheme.titleMedium,
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : icon == null
            ? Text(label, textAlign: TextAlign.center)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Flexible(child: Text(label, textAlign: TextAlign.center)),
                ],
              ),
      ),
    );
  }
}
