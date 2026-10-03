double? parseFiniteNumber(Object? value) {
  final number = value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');
  return number != null && number.isFinite ? number : null;
}
