import 'package:savemed/core/utils/number_parser.dart';

class Pharmacy {
  final int id;
  final String name;
  final String? image;
  final String? cnpj;
  final String? phone;
  final String? city;
  final String? state;
  final String? zipcode;
  final bool acceptsOwnDelivery;
  final bool acceptsPickup;
  final double? ownDeliveryPrice;
  final double? ownDeliveryPricePerKm;
  final double? ownDeliveryMaxDistanceKm;
  final String? ownDeliveryNote;
  final bool isActive;
  final bool isOpen;
  final int? preparationMinutes;
  final String? inactiveReason;

  const Pharmacy({
    required this.id,
    required this.name,
    this.image,
    this.cnpj,
    this.phone,
    this.city,
    this.state,
    this.zipcode,
    this.acceptsOwnDelivery = false,
    this.acceptsPickup = false,
    this.ownDeliveryPrice,
    this.ownDeliveryPricePerKm,
    this.ownDeliveryMaxDistanceKm,
    this.ownDeliveryNote,
    this.isActive = true,
    this.isOpen = true,
    this.preparationMinutes,
    this.inactiveReason,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['ID']);
    final name = json['NAME']?.toString().trim() ?? '';
    if (id == null || name.isEmpty) {
      throw const FormatException('Farmácia com dados obrigatórios inválidos.');
    }
    return Pharmacy(
      id: id,
      name: name,
      image: _optionalString(json['IMAGE']),
      cnpj: _optionalString(json['CNPJ']),
      phone: _optionalString(json['PHONE']),
      city: _optionalString(json['CITY']),
      state: _optionalString(json['STATE']),
      zipcode: _optionalString(json['ZIPCODE']),
      acceptsOwnDelivery: json['ACCEPTS_OWN_DELIVERY'] == true,
      acceptsPickup: json['ACCEPTS_PICKUP'] == true,
      ownDeliveryPrice: parseFiniteNumber(json['OWN_DELIVERY_PRICE']),
      ownDeliveryPricePerKm: parseFiniteNumber(
        json['OWN_DELIVERY_PRICE_PER_KM'],
      ),
      ownDeliveryMaxDistanceKm: parseFiniteNumber(
        json['OWN_DELIVERY_MAX_DISTANCE_KM'],
      ),
      ownDeliveryNote: json['OWN_DELIVERY_NOTE']?.toString(),
      isActive: json['IS_ACTIVE'] != false,
      isOpen: json['IS_OPEN'] != false,
      preparationMinutes: _asInt(json['PREPARATION_MINUTES']),
      inactiveReason: _optionalString(json['INACTIVE_REASON']),
    );
  }

  String get addressLine => [
    city,
    state,
    zipcode,
  ].whereType<String>().where((value) => value.isNotEmpty).join(' - ');

  static int? _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _optionalString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
