import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_admin/utils/utils.dart';
import 'package:parking_admin/widgets/parking_lot_widget.dart';
import 'package:shared_client/shared_client.dart';

class ParkingLotView extends StatefulWidget {
  const ParkingLotView({super.key});

  @override
  State<ParkingLotView> createState() => _ParkingLotViewState();
}

class _ParkingLotViewState extends State<ParkingLotView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text("Available parking lots"),
      ),
      body: BlocListener<ParkingLotBloc, ParkingLotState>(
          listener: (context, state) {
        if (state is ParkingLotSuccess) {
          Utils().showSnackBar(context, state.message);
        }
        if (state is ParkingLotFailure) {
          Utils().showSnackBar(context, state.error);
        }
      }, child: BlocBuilder<ParkingLotBloc, ParkingLotState>(
              builder: (context, state) {
        if (state is ParkingLotLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ParkingLotLoaded && state.parkingLots.isEmpty) {
          return const Text('No parking lots available.');
        }
        if (state is ParkingLotLoaded) {
          return ListView.builder(
            itemCount: state.parkingLots.length,
            itemBuilder: (context, index) {
              return ParkingLotWidget(
                  item: state.parkingLots[index], number: index + 1);
            },
          );
        }

        // Default case to handle unexpected state
        return const Center(child: Text('Unknown state'));
      })),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        tooltip: 'Add new parking lot',
        onPressed: () {
          context.go('/parkinglot/addParkinglot');
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
