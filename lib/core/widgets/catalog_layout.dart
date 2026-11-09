import 'package:flutter/material.dart';

class CatalogLayout {
  static double cardHeight(BuildContext context) =>
      412 + (MediaQuery.textScalerOf(context).scale(1) - 1).clamp(0, 2) * 280;

  static int columns(BuildContext context, double availableWidth) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final minimumWidth = scale > 1.3
        ? 280.0
        : availableWidth >= 600
        ? 220.0
        : 164.0;
    return ((availableWidth + 12) / (minimumWidth + 12)).floor().clamp(1, 4);
  }
}
