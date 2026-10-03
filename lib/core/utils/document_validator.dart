bool isValidCPF(String cpf) {
  cpf = cpf.replaceAll(RegExp(r'\D'), '');
  if (cpf.length != 11) return false;
  if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;

  int sum = 0;
  for (int i = 0; i < 9; i++) {
    sum += int.parse(cpf[i]) * (10 - i);
  }
  int d1 = 11 - (sum % 11);
  if (d1 >= 10) d1 = 0;
  if (d1 != int.parse(cpf[9])) return false;

  sum = 0;
  for (int i = 0; i < 10; i++) {
    sum += int.parse(cpf[i]) * (11 - i);
  }
  int d2 = 11 - (sum % 11);
  if (d2 >= 10) d2 = 0;

  return d2 == int.parse(cpf[10]);
}

bool isValidCNPJ(String cnpj) {
  cnpj = cnpj.replaceAll(RegExp(r'\D'), '');
  if (cnpj.length != 14) return false;
  if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) return false;

  final weight1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  final weight2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

  int sum = 0;
  for (int i = 0; i < 12; i++) {
    sum += int.parse(cnpj[i]) * weight1[i];
  }
  int d1 = sum % 11 < 2 ? 0 : 11 - (sum % 11);
  if (d1 != int.parse(cnpj[12])) return false;

  sum = 0;
  for (int i = 0; i < 13; i++) {
    sum += int.parse(cnpj[i]) * weight2[i];
  }
  int d2 = sum % 11 < 2 ? 0 : 11 - (sum % 11);

  return d2 == int.parse(cnpj[13]);
}
