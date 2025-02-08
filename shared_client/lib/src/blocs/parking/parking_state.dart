part of 'parking_bloc.dart';

abstract class ParkingState extends Equatable {
  @override
  List<Object> get props => [];
}

class ParkingInitial extends ParkingState {}

class ParkingLoading extends ParkingState {}

class ParkingLoaded extends ParkingState {
  final List<Parking> parkings;

  ParkingLoaded({required this.parkings});

  @override
  List<Object> get props => [parkings];
}

class ParkingSuccess extends ParkingState {
  final String message;

  ParkingSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ParkingFailure extends ParkingState {
  final String error;

  ParkingFailure(this.error);

  @override
  List<Object> get props => [error];
}
