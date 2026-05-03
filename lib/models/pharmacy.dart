class Pharmacy {
  final int id;
  final String name;
  final String? image;
  final bool acceptsOwnDelivery;
  final bool acceptsPickup;
  final double? ownDeliveryPrice;
  final double? ownDeliveryPricePerKm;
  final double? ownDeliveryMaxDistanceKm;
  final String? ownDeliveryNote;

  Pharmacy({
    required this.id,
    required this.name,
    this.image,
    this.acceptsOwnDelivery = false,
    this.acceptsPickup = false,
    this.ownDeliveryPrice,
    this.ownDeliveryPricePerKm,
    this.ownDeliveryMaxDistanceKm,
    this.ownDeliveryNote,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: json['ID'],
      name: json['NAME'],
      image: json['IMAGE'],
      acceptsOwnDelivery: json['ACCEPTS_OWN_DELIVERY'] == true,
      acceptsPickup: json['ACCEPTS_PICKUP'] == true,
      ownDeliveryPrice: json['OWN_DELIVERY_PRICE'] == null
          ? null
          : double.tryParse(json['OWN_DELIVERY_PRICE'].toString()),
      ownDeliveryPricePerKm: json['OWN_DELIVERY_PRICE_PER_KM'] == null
          ? null
          : double.tryParse(json['OWN_DELIVERY_PRICE_PER_KM'].toString()),
      ownDeliveryMaxDistanceKm: json['OWN_DELIVERY_MAX_DISTANCE_KM'] == null
          ? null
          : double.tryParse(json['OWN_DELIVERY_MAX_DISTANCE_KM'].toString()),
      ownDeliveryNote: json['OWN_DELIVERY_NOTE']?.toString(),
    );
  }
}
