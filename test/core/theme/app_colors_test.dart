import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/theme/app_colors.dart';

double contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test('functional colors meet AA contrast against white', () {
    for (final color in [
      AppColors.primary,
      AppColors.primaryDark,
      AppColors.danger,
      AppColors.success,
      AppColors.textLight,
    ]) {
      expect(contrastRatio(color, Colors.white), greaterThanOrEqualTo(4.5));
    }
  });
}
