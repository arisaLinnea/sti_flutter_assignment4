import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/auth/auth_bloc.dart';
import 'package:parking_user/utils/utils.dart';
import 'package:parking_user/widgets/free_lots_widget.dart';
import 'package:parking_user/widgets/parking_widget.dart';
import 'package:shared_client/shared_client.dart';

class ParkingView extends StatefulWidget {
  const ParkingView({super.key});
  @override
  State<ParkingView> createState() => _ParkingViewState();
}

class _ParkingViewState extends State<ParkingView> {
  Owner? owner;
  @override
  void initState() {
    super.initState();
    owner = context.read<AuthBloc>().state.user;
    context.read<ParkingBloc>().add(LoadParkingsEvent());
    //context.read<ParkingLotBloc>().add(LoadParkingLotsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Parkings')),
        body: CustomScrollView(slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'FREE PARKING LOTS:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          BlocBuilder<ParkingLotBloc, ParkingLotState>(
            builder: (context, lotState) {
              final parkingState = context.read<ParkingBloc>().state;
              if (lotState is ParkingLotLoading ||
                  parkingState is ParkingLoading) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (parkingState is! ParkingLoaded &&
                  parkingState is! ParkingLoading) {
                return const SliverToBoxAdapter(
                  child: Center(
                      child: Text('Could not fetch available parkingspaces.')),
                );
              }
              if (lotState is ParkingLotLoaded) {
                List<ParkingLot> freeParkingLots = context
                    .read<ParkingLotBloc>()
                    .getFreeParkingLots(
                        allParkings: (parkingState as ParkingLoaded).parkings);
                if (freeParkingLots.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text('No parkinglots available.')),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return FreeLotsWidget(
                          item: freeParkingLots[index], number: index + 1);
                    },
                    childCount: freeParkingLots.length,
                  ),
                );
              }
              return const SliverToBoxAdapter(
                child: Center(child: Text('Error loading parking lots.')),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'MY ACTIVE PARKINGS:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          BlocListener<ParkingBloc, ParkingState>(
              listener: (context, parkingState) {
            if (parkingState is ParkingFailure) {
              Utils.toastMessage(parkingState.error);
            }
            if (parkingState is ParkingSuccess) {
              Utils.toastMessage(parkingState.message);
            }
            if (parkingState is ParkingLoaded) {
              context.read<ParkingLotBloc>().add(LoadParkingLotsEvent());
            }
          }, child: BlocBuilder<ParkingBloc, ParkingState>(
            builder: (context, parkState) {
              if (parkState is ParkingLoading) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (parkState is ParkingLoaded) {
                List<Parking> activeParkings = context
                    .read<ParkingBloc>()
                    .getUserActiveParkings(owner: owner!);

                if (activeParkings.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text('No active parkings.')),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ParkingWidget(
                          item: activeParkings[index],
                          number: index + 1,
                          isActive: true);
                    },
                    childCount: activeParkings.length,
                  ),
                );
              }
              return const SliverToBoxAdapter(
                child: Center(child: Text('Error loading active parkings.')),
              );
            },
          )),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'MY CLOSED PARKINGS:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          BlocBuilder<ParkingBloc, ParkingState>(
            builder: (context, parkState) {
              if (parkState is ParkingLoading) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (parkState is ParkingLoaded) {
                List<Parking> endedParkings = context
                    .read<ParkingBloc>()
                    .getUserEndedParkings(owner: owner!);

                if (endedParkings.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text('No ended parkings.')),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ParkingWidget(
                          item: endedParkings[index],
                          number: index + 1,
                          isActive: false);
                    },
                    childCount: endedParkings.length,
                  ),
                );
              }
              return const SliverToBoxAdapter(
                child: Center(child: Text('Error loading ended parkings.')),
              );
            },
          ),
        ]));
  }
}
