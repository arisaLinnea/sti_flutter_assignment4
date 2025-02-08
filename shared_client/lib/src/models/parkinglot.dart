import 'package:shared_client/src/models/identifiable.dart';
import 'package:uuid/uuid.dart';

class Address {
  String _id;
  String street;
  String zipCode;
  String city;

  Address(
      {required this.street,
      required this.zipCode,
      required this.city,
      String? id})
      : _id = id ?? Uuid().v4();

  String get id => _id;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
        id: json['id'],
        street: json['street'],
        zipCode: json['zipCode'],
        city: json['city']);
  }
  static Future<Address> fromJsonAsync(Map<String, dynamic> json) async {
    return Address(
        id: json['id'],
        street: json['street'],
        zipCode: json['zipCode'],
        city: json['city']);
  }

  Map<String, dynamic> toJson() =>
      {'id': _id, 'street': street, 'zipCode': zipCode, 'city': city};

  @override
  String toString() {
    return '$street, $zipCode $city';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParkingLot && other.id == _id;
  }

  @override
  int get hashCode => _id.hashCode;
}

class ParkingLot implements Identifiable {
  String _id;
  Address? address;
  double hourlyPrice;

  ParkingLot({required this.address, required this.hourlyPrice, String? id})
      : _id = id ?? Uuid().v4();

  @override
  String get id => _id;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ParkingLot) return false;
    return other.id == _id;
  }

  @override
  int get hashCode => _id.hashCode;

  factory ParkingLot.fromJson(Map<String, dynamic> json) {
    return ParkingLot(
        id: json['id'],
        address:
            json['address'] != null ? Address.fromJson(json['address']) : null,
        hourlyPrice: json['hourlyPrice']);
  }

  static Future<ParkingLot> fromJsonAsync(Map<String, dynamic> json) async {
    Address? address = json['address'] != null
        ? await Address.fromJsonAsync(json['address'])
        : null;

    double hourlyPrice = json['hourlyPrice'] is int
        ? json['hourlyPrice'].roundToDouble()
        : json['hourlyPrice'];
    ParkingLot parking =
        ParkingLot(id: json['id'], address: address, hourlyPrice: hourlyPrice);

    return parking;
  }

  Map<String, dynamic> toJson() =>
      {'id': _id, 'address': address?.toJson(), 'hourlyPrice': hourlyPrice};

  @override
  String toString() {
    return 'Address: ${address.toString()}, hourly price: $hourlyPrice';
  }
}
