part of 'parking_lot_bloc.dart';

abstract class ParkingLotState extends Equatable {
  @override
  List<Object> get props => [];
}

class ParkingLotInitial extends ParkingLotState {}

class ParkingLotLoading extends ParkingLotState {}

class ParkingLotLoaded extends ParkingLotState {
  final List<ParkingLot> parkingLots;

  ParkingLotLoaded({required this.parkingLots});

  @override
  List<Object> get props => [parkingLots];
}

class ParkingLotSuccess extends ParkingLotState {
  final String message;

  ParkingLotSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ParkingLotFailure extends ParkingLotState {
  final String error;

  ParkingLotFailure(this.error);

  @override
  List<Object> get props => [error];
}
