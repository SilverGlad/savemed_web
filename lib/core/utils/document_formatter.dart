String formatCpfForDisplay(Object? value) {
  final digits = value?.toString().replaceAll(RegExp(r'\D'), '') ?? '';
  if (digits.length != 11) return 'Não informado';
  return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.'
      '${digits.substring(6, 9)}-${digits.substring(9)}';
}
