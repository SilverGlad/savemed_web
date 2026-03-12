class Pharmacy {
  final int id;
  final String name;
  final String? image;

  Pharmacy({required this.id, required this.name, this.image});

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(id: json['ID'], name: json['NAME'], image: json['IMAGE']);
  }
}
