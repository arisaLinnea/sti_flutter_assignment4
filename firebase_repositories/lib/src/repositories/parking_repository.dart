import 'package:firebase_repositories/src/repositories/repository.dart';
import 'package:shared_client/shared_client.dart';

class ParkingRepository extends Repository<Parking> {
  static final ParkingRepository _instance =
      ParkingRepository._internal(path: 'parking');

  ParkingRepository._internal({required super.path});

  factory ParkingRepository() => _instance;

  @override
  Future<Parking> deserialize(Map<String, dynamic> json) async =>
      await Parking.fromJsonAsync(json);

  @override
  Map<String, dynamic> serialize(Parking item) => item.toJson();

  Stream<List<Parking>> parkingStream() {
    return db.collection(path).snapshots().asyncMap((snapshot) async {
      final futures =
          snapshot.docs.map((doc) => Parking.fromJsonAsync(doc.data()));
      return Future.wait(futures);
    });
  }
}
