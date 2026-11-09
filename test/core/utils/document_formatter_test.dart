import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/utils/document_formatter.dart';

void main() {
  test('formats only a complete CPF for display', () {
    expect(formatCpfForDisplay('52998224725'), '529.982.247-25');
    expect(formatCpfForDisplay(null), 'Não informado');
    expect(formatCpfForDisplay('123'), 'Não informado');
  });
}
