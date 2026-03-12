String categoryAssetByName(String name) {
  final key = name.toLowerCase().trim();

  if (key.contains('beleza')) return 'assets/categories/beleza.png';
  if (key.contains('perfum')) return 'assets/categories/perfumaria.png';
  if (key.contains('higiene')) return 'assets/categories/higiene.png';
  if (key.contains('mãe') || key.contains('bebe')) {
    return 'assets/categories/mae_bebe.png';
  }
  if (key.contains('medic')) return 'assets/categories/medicamentos.png';
  if (key.contains('skin')) return 'assets/categories/skincare.png';
  if (key.contains('cabelo')) return 'assets/categories/cabelo.png';
  if (key.contains('cuidado')) return 'assets/categories/cuidados.png';

  // fallback
  return 'assets/categories/medicamentos.png';
}
