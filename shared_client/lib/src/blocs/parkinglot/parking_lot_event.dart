part of 'parking_lot_bloc.dart';

class ParkingLotEvent {}

class SubscribeToParkingLots extends ParkingLotEvent {
  SubscribeToParkingLots();
}

class LoadParkingLotsEvent extends ParkingLotEvent {}

class RemoveParkingLotEvent extends ParkingLotEvent {
  final String lotId;

  RemoveParkingLotEvent({required this.lotId});
}

class AddParkingLotEvent extends ParkingLotEvent {
  final ParkingLot lot;

  AddParkingLotEvent({required this.lot});
}

class EditParkingLotEvent extends ParkingLotEvent {
  final ParkingLot lot;

  EditParkingLotEvent({required this.lot});
}
