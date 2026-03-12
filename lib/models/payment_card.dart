class PaymentCard {
  final String id;

  // Exibição
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;

  // Dados sensíveis (NÃO exibir em UI)
  final String number;
  final String holderName;
  final String cvv;

  PaymentCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.number,
    required this.holderName,
    required this.cvv,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'],
      brand: json['brand'],
      last4: json['last4'],
      expMonth: json['expMonth'],
      expYear: json['expYear'],
      number: json['number'] ?? '',
      holderName: json['holderName'] ?? '',
      cvv: json['cvv'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'brand': brand,
    'last4': last4,
    'expMonth': expMonth,
    'expYear': expYear,
    'number': number,
    'holderName': holderName,
    'cvv': cvv,
  };
}
