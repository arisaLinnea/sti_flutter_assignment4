import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_user/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_user/utils/utils.dart';
import 'package:parking_user/widgets/vehicle_widget.dart';

class VehicleView extends StatefulWidget {
  const VehicleView({super.key});

  @override
  State<VehicleView> createState() => _VehicleViewState();
}

class _VehicleViewState extends State<VehicleView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My vehicles')),
      body: BlocListener<VehicleBloc, VehicleState>(listener: (context, state) {
        if (state is VehicleSuccess) {
          Utils.toastMessage(state.message);
        }
        if (state is VehicleFailure) {
          Utils.toastMessage(state.error);
        }
      }, child: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, state) {
          // Show a loading indicator when vehicles are loading
          if (state is VehicleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show a message if there are no vehicles
          if (state is VehicleLoaded && state.vehicleList.isEmpty) {
            return const Center(child: Text('No vehicles available.'));
          }

          // Show the list of vehicles when they are loaded
          if (state is VehicleLoaded) {
            return ListView.builder(
              itemCount: state.vehicleList.length,
              itemBuilder: (context, index) {
                return VehicleWidget(
                  item: state.vehicleList[index],
                  number: index + 1,
                );
              },
            );
          }

          // Show an error message if there's a failure
          if (state is VehicleFailure) {
            return Center(child: Text('Error: ${state.error}'));
          }

          // Default case to handle unexpected state
          return const Center(child: Text('Unknown state'));
        },
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        tooltip: 'Add new vehicle',
        onPressed: () {
          context.go('/vehicles/addVehicle');
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
