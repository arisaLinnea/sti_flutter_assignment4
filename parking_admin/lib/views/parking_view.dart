import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_admin/widgets/parking_widget.dart';
import 'package:shared_client/shared_client.dart';

class ParkingView extends StatefulWidget {
  const ParkingView({super.key});

  @override
  State<ParkingView> createState() => _ParkingViewState();
}

class _ParkingViewState extends State<ParkingView> {
  @override
  void initState() {
    super.initState();
    context.read<ParkingBloc>().add(LoadParkingsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text("Parkings"),
      ),
      body: BlocBuilder<ParkingBloc, ParkingState>(builder: (context, state) {
        if (state is ParkingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ParkingLoaded && state.parkings.isEmpty) {
          return const Center(child: Text('No parkings available.'));
        }

        if (state is ParkingLoaded) {
          // filter active parkings
          var activeList =
              state.parkings.where((parking) => parking.isActive).toList();
          // filter inactive parkings
          var inactiveList =
              state.parkings.where((parking) => !parking.isActive).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  'ACTIVE PARKINGS:'),
              Expanded(
                  child: ListView.builder(
                      itemCount: activeList.length,
                      itemBuilder: (context, index) {
                        return ParkingWidget(
                            item: activeList[index], number: index + 1);
                      })),
              const Text(
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  'INACTIVE PARKINGS:'),
              Expanded(
                  child: inactiveList.isEmpty
                      ? const Text('Empty List')
                      : ListView.builder(
                          itemCount: inactiveList.length,
                          itemBuilder: (context, index) {
                            return ParkingWidget(
                                item: inactiveList[index], number: index + 1);
                          }))
            ],
          );
        }
        // Default case to handle unexpected state
        return const Center(child: Text('Unknown state'));
      }),
    );
  }
}
