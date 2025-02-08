import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_client/shared_client.dart';

class ParkingStatView extends StatefulWidget {
  const ParkingStatView({super.key});

  @override
  State<ParkingStatView> createState() => _ParkingStatViewState();
}

class _ParkingStatViewState extends State<ParkingStatView> {
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
          title: const Text("Parking statistics"),
        ),
        body: CustomScrollView(slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Popular Parkings:',
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
                List<ParkingLot> popularLots =
                    context.read<ParkingBloc>().getPopularParkingLots();

                if (popularLots.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text('No popular parkings')),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60.0, vertical: 2.0),
                        child: Text(popularLots[index].address.toString(),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                    childCount: popularLots.length,
                  ),
                );
              }
              return const SliverToBoxAdapter(
                child: Center(child: Text('Error loading popular parkings.')),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Sum parking: (for ended parkings)',
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
                double sumParking =
                    context.read<ParkingBloc>().getSumParkings();

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60.0, vertical: 2.0),
                    child: Text(
                      'Sum $sumParking',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(
                child: Center(child: Text('Error loading popular parkings.')),
              );
            },
          ),
        ]));
  }
}
