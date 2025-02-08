import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/auth/auth_bloc.dart';
import 'package:shared_client/shared_client.dart';
import 'package:equatable/equatable.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository vehicleRepository;
  final AuthBloc authBloc;

  VehicleBloc({required this.vehicleRepository, required this.authBloc})
      : super(VehicleInitial()) {
    on<VehicleEvent>((event, emit) async {
      final Owner user = authBloc.state.user;
      try {
        if (event is RemoveVehicleEvent) {
          await _handleRemoveVehicle(event, emit, user);
        } else if (event is AddVehicleEvent) {
          await _handleAddVehicle(event, emit, user);
        } else if (event is LoadVehiclesEvent) {
          await _handleLoadVehicle(emit, user);
        } else if (event is EditVehicleEvent) {
          await _handleEditVehicle(event, emit, user);
        } else if (event is SubscribeToUserVehicles) {
          final userId = event.userId;
          await emit.onEach(vehicleRepository.userVehicleStream(userId),
              onData: (vehicles) {
            emit(VehicleLoaded(vehicles: vehicles));
          });
        }
      } catch (e) {
        emit(VehicleFailure(e.toString()));
      }
    });
  }

  Future<void> _handleLoadVehicle(Emitter<VehicleState> emit, owner) async {
    emit(VehicleLoading());
    List<Vehicle> list = await vehicleRepository.getList();
    List<Vehicle> vehicleList =
        list.where((v) => v.owner?.id == owner.id).toList();
    emit(VehicleLoaded(vehicles: vehicleList));
  }

  Future<void> _handleRemoveVehicle(
      RemoveVehicleEvent event, Emitter<VehicleState> emit, owner) async {
    emit(VehicleLoading());

    bool success = await vehicleRepository.remove(id: event.vehicleId);

    if (success) {
      emit(VehicleSuccess('Vehicle removed successfully'));
      await _handleLoadVehicle(emit, owner);
    } else {
      emit(VehicleFailure('Failed to remove vehicle'));
    }
  }

  Future<void> _handleAddVehicle(
      AddVehicleEvent event, Emitter<VehicleState> emit, owner) async {
    emit(VehicleLoading());
    String? vehicleid = await vehicleRepository.addToList(item: event.vehicle);

    if (vehicleid != null) {
      emit(VehicleSuccess('Vehicle added successfully'));
      await _handleLoadVehicle(emit, owner);
    } else {
      emit(VehicleFailure('Failed to add vehicle'));
    }
  }

  Future<void> _handleEditVehicle(
      EditVehicleEvent event, Emitter<VehicleState> emit, Owner user) async {
    emit(VehicleLoading());
    bool success = await vehicleRepository.update(
        id: event.vehicle.id, item: event.vehicle);

    if (success) {
      emit(VehicleSuccess('Vehicle updated successfully'));
      await _handleLoadVehicle(emit, user);
    } else {
      emit(VehicleFailure('Failed to update vehicle'));
    }
  }

  Vehicle getVehicleById({required String id}) {
    return state.vehicleList.firstWhere((element) => element.id == id);
  }
}
