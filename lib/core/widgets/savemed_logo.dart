import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The capsule mark from the SaveMed visual identity, rendered natively so it
/// stays crisp at every device pixel ratio.
class SaveMedLogoMark extends StatelessWidget {
  final double width;
  final double height;

  const SaveMedLogoMark({super.key, this.width = 24, this.height = 42});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(width, height),
        painter: _SaveMedLogoPainter(),
      ),
    );
  }
}

class _SaveMedLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(size.width * 0.48);
    final capsule = RRect.fromRectAndRadius(rect.deflate(1.5), radius);

    canvas.drawRRect(capsule, Paint()..color = AppColors.greenTint);

    final lower = Path()
      ..moveTo(1.5, size.height * 0.5)
      ..cubicTo(
        size.width * 0.33,
        size.height * 0.39,
        size.width * 0.66,
        size.height * 0.62,
        size.width - 1.5,
        size.height * 0.5,
      )
      ..lineTo(size.width - 1.5, size.height - 1.5)
      ..lineTo(1.5, size.height - 1.5)
      ..close();

    canvas.save();
    canvas.clipRRect(capsule);
    canvas.drawPath(lower, Paint()..color = AppColors.brandGreen);
    canvas.restore();

    canvas.drawRRect(
      capsule,
      Paint()
        ..color = AppColors.primaryDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
