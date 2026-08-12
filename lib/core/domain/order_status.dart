enum OrderStatus {
  pending('pending'),
  confirmed('confirmed'),
  canceled('canceled'),
  unknown('unknown');

  final String apiValue;

  const OrderStatus(this.apiValue);

  static OrderStatus fromApi(Object? value) {
    return OrderStatus.values.firstWhere(
      (status) => status.apiValue == value?.toString(),
      orElse: () => OrderStatus.unknown,
    );
  }
}

enum PaymentStatus {
  pending('pending'),
  paid('paid'),
  failed('failed'),
  refunded('refunded'),
  unknown('unknown');

  final String apiValue;

  const PaymentStatus(this.apiValue);

  static PaymentStatus fromApi(Object? value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.apiValue == value?.toString(),
      orElse: () => PaymentStatus.unknown,
    );
  }
}

String orderStatusLabel(String value) {
  return switch (value.toLowerCase()) {
    'pending' => 'Pendente',
    'confirmed' => 'Confirmado',
    'canceled' || 'cancelled' => 'Cancelado',
    'paid' => 'Pago',
    'failed' => 'Falhou',
    'refunded' => 'Estornado',
    'completed' => 'Concluido',
    _ => value,
  };
}
