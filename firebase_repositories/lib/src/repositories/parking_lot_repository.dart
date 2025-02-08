import 'package:firebase_repositories/src/repositories/repository.dart';
import 'package:shared_client/shared_client.dart';

class ParkingLotRepository extends Repository<ParkingLot> {
  static final ParkingLotRepository _instance =
      ParkingLotRepository._internal(path: 'parkinglot');

  ParkingLotRepository._internal({required super.path});

  factory ParkingLotRepository() => _instance;

  @override
  Future<ParkingLot> deserialize(Map<String, dynamic> json) async =>
      await ParkingLot.fromJsonAsync(json);

  @override
  Map<String, dynamic> serialize(ParkingLot item) => item.toJson();

  Stream<List<ParkingLot>> parkingLotStream() {
    return db.collection(path).snapshots().asyncMap((snapshot) async {
      final futures =
          snapshot.docs.map((doc) => ParkingLot.fromJsonAsync(doc.data()));
      return Future.wait(futures);
    });
  }

  Stream<List<ParkingLot>> freeParkingLotStream() async* {
    final now = DateTime.now();
    final parkingStream =
        db.collection('parking').snapshots().asyncMap((snapshot) async {
      final futures = snapshot.docs.map((doc) async {
        final parking = await Parking.fromJsonAsync(doc.data());

        // Filter out items where endTime is null or after the current time
        if (parking.endTime == null || parking.endTime!.isAfter(now)) {
          return parking;
        } else {
          return null;
        }
      });
      // Wait for all futures to resolve
      final results = await Future.wait(futures);

      // Filter out null values
      return results.where((parking) => parking != null).toList();
    });

    final parkingLotStream =
        db.collection(path).snapshots().asyncMap((snapshot) async {
      final futures =
          snapshot.docs.map((doc) => ParkingLot.fromJsonAsync(doc.data()));
      return Future.wait(futures);
    });

    // Go through the parking data and parking lot data and filter out the
    // parking lots that are not in the parking data
    await for (var parkingData in parkingStream) {
      final filteredParkings = parkingData;

      await for (var parkingLotData in parkingLotStream) {
        final parkingLots = parkingLotData;

        yield parkingLots.where((lot) {
          return !filteredParkings
              .any((parking) => parking?.parkinglot?.id == lot.id);
        }).toList();
      }
    }
  }
}
