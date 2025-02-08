part of 'parking_bloc.dart';

class ParkingEvent {}

class LoadParkingsEvent extends ParkingEvent {}

class RemoveParkingEvent extends ParkingEvent {
  final String parkingId;

  RemoveParkingEvent({required this.parkingId});
}

class AddParkingEvent extends ParkingEvent {
  final Parking parking;

  AddParkingEvent({required this.parking});
}

class EditParkingEvent extends ParkingEvent {
  final Parking parking;

  EditParkingEvent({required this.parking});
}

class SubscribeToParkings extends ParkingEvent {
  SubscribeToParkings();
}
