import 'package:firebase_repositories/src/repositories/repository.dart';
import 'package:shared_client/shared_client.dart';

class VehicleRepository extends Repository<Vehicle> {
  static final VehicleRepository _instance =
      VehicleRepository._internal(path: 'vehicle');

  VehicleRepository._internal({required super.path});

  factory VehicleRepository() => _instance;

  @override
  Future<Vehicle> deserialize(Map<String, dynamic> json) async =>
      await Vehicle.fromJsonAsync(json);

  @override
  Map<String, dynamic> serialize(Vehicle item) => item.toJson();

  Stream<List<Vehicle>> userVehicleStream(String userId) {
    Stream<List<Vehicle>> stream = db
        .collection(path)
        .where("ownerId", isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final docs = snapshot.docs;
      // Wait for all futures to complete and return the list of Vehicles
      final vehicles = await Future.wait(
          docs.map((doc) async => await Vehicle.fromJsonAsync(doc.data())));
      return vehicles;
    });
    return stream;
  }
}
