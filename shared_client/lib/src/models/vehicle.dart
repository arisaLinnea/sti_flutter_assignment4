import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:shared_client/src/enums/car_type.dart';
import 'package:shared_client/src/models/identifiable.dart';
import 'package:shared_client/src/models/owner.dart';
import 'package:uuid/uuid.dart';

class Vehicle implements Identifiable {
  final String _id;
  String registrationNo;
  CarBrand type;
  Owner? owner;

  Vehicle(
      {required this.registrationNo,
      required this.type,
      required this.owner,
      String? id})
      : _id = id ?? Uuid().v4();

  @override
  String get id => _id;

  static Future<Vehicle> fromJsonAsync(Map<String, dynamic> json) async {
    var typeIndex = json['type'];
    return Vehicle(
      id: json['id'],
      registrationNo: json['registrationNo'],
      type: CarBrand.values[typeIndex],
      owner: await OwnerRepository().getElementById(id: json['ownerId']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': _id,
        'registrationNo': registrationNo,
        'type': type.index,
        'ownerId': owner?.id
      };

  @override
  String toString() {
    return 'RegistrationNo: $registrationNo, type: $type, owner: (${owner.toString()})';
  }
}
