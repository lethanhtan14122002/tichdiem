class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final int points;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.points = 0,
  });

  String get lastFourPhone {
    if (phone.length < 4) return phone;
    return phone.substring(phone.length - 4);
  }
}
