import 'package:equatable/equatable.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_client/shared_client.dart';

part 'parking_event.dart';
part 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository;
  List<Parking> _parkings = [];

  ParkingBloc({required this.parkingRepository}) : super(ParkingInitial()) {
    on<ParkingEvent>((event, emit) async {
      try {
        if (event is LoadParkingsEvent) {
          await _handleLoadParkings(emit);
        } else if (event is RemoveParkingEvent) {
          await _handleRemoveParking(event, emit);
        } else if (event is AddParkingEvent) {
          await _handleAddParking(event, emit);
        } else if (event is EditParkingEvent) {
          await _handleEditParking(event, emit);
        } else if (event is SubscribeToParkings) {
          return emit.onEach(
            parkingRepository.parkingStream(),
            onData: (parkings) {
              emit(ParkingLoading());
              _parkings = parkings;
              return emit(ParkingLoaded(parkings: parkings));
            },
          );
        }
      } catch (e) {
        emit(ParkingFailure(e.toString()));
      }
    });
  }

  Future<void> _handleLoadParkings(Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    _parkings = await parkingRepository.getList();
    emit(ParkingLoaded(parkings: _parkings));
  }

  Future<void> _handleRemoveParking(
      RemoveParkingEvent event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    bool success = await parkingRepository.remove(id: event.parkingId);
    if (success) {
      emit(ParkingSuccess('Parking removed successfully'));
      await _handleLoadParkings(emit);
    } else {
      emit(ParkingFailure('Failed to remove parking'));
    }
  }

  Future<void> _handleAddParking(
      AddParkingEvent event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    String? lotId = await parkingRepository.addToList(item: event.parking);
    emit(ParkingSuccess('Parking added successfully'));
    await _handleLoadParkings(emit);
  }

  Future<void> _handleEditParking(
      EditParkingEvent event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    bool success = await parkingRepository.update(
        id: event.parking.id, item: event.parking);
    if (success) {
      emit(ParkingSuccess('Parking updated successfully'));
      await _handleLoadParkings(emit);
    } else {
      emit(ParkingFailure('Failed to update parking'));
    }
  }

  List<Parking> getUserParkings({required Owner owner}) {
    List<Parking> userParkings =
        _parkings.where((park) => park.vehicle?.owner?.id == owner.id).toList();
    return userParkings;
  }

  List<Parking> getUserActiveParkings({required Owner owner}) {
    List<Parking> userParkings = getUserParkings(owner: owner);
    List<Parking> activeParkings = userParkings
        .where((lot) =>
            (lot.endTime == null || lot.endTime!.isAfter(DateTime.now())))
        .toList();
    return activeParkings;
  }

  List<Parking> getUserEndedParkings({required Owner owner}) {
    List<Parking> userParkings = getUserParkings(owner: owner);
    List<Parking> endedParkings = userParkings
        .where((lot) =>
            (lot.endTime != null && lot.endTime!.isBefore(DateTime.now())))
        .toList();
    return endedParkings;
  }

  List<ParkingLot> getPopularParkingLots() {
    if (_parkings.isEmpty) return [];

    Map<String, int> parkingLotCount = {};

    for (var parking in _parkings) {
      var lotId = parking.parkinglot?.id;
      if (lotId != null) {
        parkingLotCount[lotId] = (parkingLotCount[lotId] ?? 0) + 1;
      }
    }
    // Find the maximum occurrence
    int maxCount = parkingLotCount.values.isEmpty
        ? 0
        : parkingLotCount.values.reduce((a, b) => a > b ? a : b);

    // Get all parking lots with the max occurrence
    List<String> maxIds = [];
    parkingLotCount.forEach((lot, count) {
      if (count == maxCount) {
        maxIds.add(lot);
      }
    });
    List<ParkingLot> mostCommon = _parkings
        .where((parking) => maxIds.contains(parking.parkinglot?.id))
        .map((parking) => parking.parkinglot)
        .whereType<
            ParkingLot>() // Ensures we only get non-null ParkingLot objects
        .toSet() // Removes duplicates (compare operator== needed in ParkingLot)
        .toList();

    return mostCommon;
  }

  double getSumParkings() {
    double sumParking = 0;
    DateTime now = DateTime.now();
    for (var parking in _parkings) {
      if (parking.endTime != null &&
          parking.endTime!.isBefore(now) &&
          parking.parkinglot?.hourlyPrice != null) {
        Duration differenceTime =
            parking.endTime!.difference(parking.startTime);
        int minutes = differenceTime.inMinutes;
        int startedHours = (minutes / 60).ceil();
        double cost = parking.parkinglot!.hourlyPrice * startedHours;
        sumParking += cost;
      }
    }
    return sumParking;
  }
}
