part of 'vehicle_bloc.dart';

// Define the States
abstract class VehicleState extends Equatable {
  late final List<Vehicle> vehicleList;

  @override
  List<Object?> get props => [];
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  VehicleLoaded({required vehicles}) {
    vehicleList = vehicles;
  }
  @override
  List<Object?> get props => [vehicleList];
}

class VehicleSuccess extends VehicleState {
  final String message;

  VehicleSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class VehicleFailure extends VehicleState {
  final String error;

  VehicleFailure(this.error);

  @override
  List<Object?> get props => [error];
}
