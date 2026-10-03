import 'package:savemed/core/utils/number_parser.dart';

class OrderFulfillment {
  final Map<String, dynamic> data;
  const OrderFulfillment(this.data);

  int get id => (data['id'] as num).toInt();
  int get version => (data['version'] as num?)?.toInt() ?? 0;
  String get status => data['status']?.toString() ?? 'pending';
  String get paymentStatus => data['paymentStatus']?.toString() ?? 'pending';
  String? get inventoryLabel => const {
    'untracked': 'Sem reserva automática registrada',
    'reserved': 'Unidades reservadas para pagamento',
    'deducted': 'Baixa de estoque registrada',
    'released': 'Reserva liberada para venda',
    'return_review': 'Estorno sem reposição automática de estoque',
  }[data['inventoryState']];
  Map<String, dynamic> get delivery => _map(data['fulfillment']);
  String get stage => delivery['stage']?.toString() ?? 'new';
  String get mode => delivery['mode']?.toString() ?? '';
  bool get pickup => data['deliveryMethod'] == 'pickup';
  bool get canOperate => paymentStatus == 'paid' && status != 'canceled';
  bool get pedMotoAvailable => data['pedMotoAvailable'] == true;
  Map<String, dynamic> get pedMoto => _map(delivery['pedmoto']);
  Map<String, dynamic> get pedMotoQuote => _map(delivery['pedmotoQuote']);
  double get pedMotoPrice =>
      parseFiniteNumber(
        mode == 'pedmoto' ? pedMoto['estimatedPrice'] : pedMotoQuote['price'],
      ) ??
      0;
  double get total => parseFiniteNumber(data['total']) ?? 0;
  double get shippingPrice => parseFiniteNumber(data['shippingPrice']) ?? 0;
  String get customerName =>
      _map(data['customer'])['name']?.toString() ?? 'Cliente';
  String get customerPhone => _map(data['customer'])['phone']?.toString() ?? '';
  String get origin => _address(data['origin']);
  String get destination => _address(data['destination']);
  List<Map<String, dynamic>> get items => _list(data['items']);
  List<Map<String, dynamic>> get history => _list(delivery['history']);

  static Map<String, dynamic> _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  static List<Map<String, dynamic>> _list(Object? value) => value is List
      ? value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
      : [];
  static String _address(Object? value) {
    final address = _map(value);
    return [
          'STREET',
          'NUMBER',
          'COMPLEMENT',
          'NEIGHBORHOOD',
          'CITY',
          'STATE',
          'CEP',
        ]
        .map((key) => address[key]?.toString() ?? '')
        .where((part) => part.isNotEmpty)
        .join(', ');
  }
}

String fulfillmentStageLabel(String stage) =>
    const {
      'new': 'Aguardando aceite',
      'preparing': 'Em preparação',
      'ready': 'Pronto',
      'on_way': 'Em entrega',
      'pedmoto_pending': 'Solicitando PedMoto',
      'pedmoto_uncertain': 'Conferir solicitação PedMoto',
      'pedmoto_requested': 'Aguardando coleta PedMoto',
      'delivered': 'Entregue',
      'refund_pending': 'Estorno em processamento',
      'canceled': 'Cancelado',
    }[stage] ??
    'Aguardando atualização';

bool fulfillmentBlocksRefund(String stage) => const {
  'on_way',
  'refund_pending',
  'pedmoto_pending',
  'pedmoto_uncertain',
  'pedmoto_requested',
}.contains(stage);
