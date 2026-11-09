import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

const categoryIcons = <String, IconData>{
  'Medicamentos': Icons.medication_outlined,
  'Vitaminas': Icons.health_and_safety_outlined,
  'Higiene': Icons.sanitizer_outlined,
  'Beleza': Icons.face_outlined,
  'Cabelo': Icons.shower_outlined,
  'Perfumaria': Icons.spa_outlined,
  'Mãe e bebê': Icons.child_care,
  'Cuidados': Icons.healing_outlined,
  'Proteção solar': Icons.wb_sunny_outlined,
  'Saúde bucal': Icons.clean_hands_outlined,
  'Bem-estar': Icons.self_improvement,
  'Primeiros socorros': Icons.medical_services_outlined,
  'Saúde dos olhos': Icons.visibility_outlined,
  'Alimentação': Icons.restaurant_outlined,
  'Esporte': Icons.fitness_center,
  'Acessórios': Icons.shopping_bag_outlined,
  'Saúde': Icons.favorite_border,
  'Farmácia': Icons.local_pharmacy_outlined,
};

Future<Uint8List> categoryIconPng(IconData icon) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawColor(Colors.white, BlendMode.src);
  final painter = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        fontSize: 180,
        color: const Color(0xFF4F8238),
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(
    canvas,
    Offset((256 - painter.width) / 2, (256 - painter.height) / 2),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(256, 256);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  painter.dispose();
  picture.dispose();
  image.dispose();
  return bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
}

IconData categoryIconByName(String name) {
  final value = name.toLowerCase();
  if (value.contains('vitamina') || value.contains('suplemento')) {
    return Icons.health_and_safety_outlined;
  }
  if (value.contains('medicamento')) return Icons.medication_outlined;
  if (value.contains('beb') || value.contains('infantil')) {
    return Icons.child_care;
  }
  if (value.contains('cabelo')) return Icons.shower_outlined;
  if (value.contains('higiene')) return Icons.sanitizer_outlined;
  if (value.contains('beleza') || value.contains('pele')) {
    return Icons.face_outlined;
  }
  if (value.contains('perfum')) return Icons.spa_outlined;
  return Icons.local_pharmacy_outlined;
}
