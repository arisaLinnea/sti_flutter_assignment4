part of 'vehicle_bloc.dart';

class VehicleEvent {}

class SubscribeToUserVehicles extends VehicleEvent {
  final String userId;

  SubscribeToUserVehicles({required this.userId});
}

class LoadVehiclesEvent extends VehicleEvent {
  LoadVehiclesEvent();
}

class RemoveVehicleEvent extends VehicleEvent {
  final String vehicleId;

  RemoveVehicleEvent({required this.vehicleId});
}

class AddVehicleEvent extends VehicleEvent {
  final Vehicle vehicle;

  AddVehicleEvent({required this.vehicle});
}

class EditVehicleEvent extends VehicleEvent {
  final Vehicle vehicle;

  EditVehicleEvent({required this.vehicle});
}
