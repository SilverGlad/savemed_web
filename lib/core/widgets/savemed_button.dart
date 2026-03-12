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

    final backgroundColor = outlined
        ? Colors.transparent
        : (isDisabled ? Colors.green.shade200 : AppColors.primary);

    final foregroundColor = outlined ? AppColors.primary : Colors.white;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: outlined
                ? BorderSide(color: AppColors.primary)
                : BorderSide.none,
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
            ? Text(label)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              ),
      ),
    );
  }
}
