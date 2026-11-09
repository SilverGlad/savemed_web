import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../theme/app_colors.dart';
import 'savemed_logo.dart';

class SaveMedFooter extends StatelessWidget {
  const SaveMedFooter({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SaveMedLogoMark(width: 18, height: 28),
                    SizedBox(width: 8),
                    Text(
                      'SaveMed',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final brand in [
                      'visa',
                      'mastercard',
                      'elo',
                      'amex',
                      'hipercard',
                    ])
                      SizedBox(
                        width: 36,
                        height: 24,
                        child: Image.asset(
                          'assets/cards/$brand.png',
                          fit: BoxFit.contain,
                          semanticLabel: brand,
                        ),
                      ),
                    const Text(
                      'Pix',
                      style: TextStyle(color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'CNPJ: 62.250.078/0001-11',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'v${ApiClient.appVersion.split('+').first}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textLight,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
