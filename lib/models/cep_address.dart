class CepAddress {
  final String zipcode;
  final String city;
  final String state;
  final String street;
  final String neighborhood;

  const CepAddress({
    required this.zipcode,
    required this.city,
    required this.state,
    this.street = '',
    this.neighborhood = '',
  });
}
