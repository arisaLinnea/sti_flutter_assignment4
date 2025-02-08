import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_client/shared_client.dart';

class FreeLotsWidget extends StatelessWidget {
  const FreeLotsWidget({super.key, required this.item, required this.number});

  final ParkingLot item;
  final int number;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        title: Text(
            textAlign: TextAlign.left,
            style: const TextStyle(fontWeight: FontWeight.bold),
            'Parkinglot $number:'),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Address: ${item.address.toString()}'),
              Text('Hourly price: ${item.hourlyPrice.toStringAsFixed(1)}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: const Text('Start parking'),
                    onPressed: () {
                      context.go('/parking/addParking', extra: item);
                    },
                  ),
                ],
              )
            ]),
      ),
    );
  }
}
