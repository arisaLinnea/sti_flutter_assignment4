import 'package:flutter/material.dart';
import 'package:shared_client/shared_client.dart';

class ParkingWidget extends StatelessWidget {
  const ParkingWidget({super.key, required this.item, required this.number});

  final Parking item;
  final int number;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        title: Text(
            textAlign: TextAlign.left,
            style: const TextStyle(fontWeight: FontWeight.bold),
            'PARKING $number:'),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Space: ${item.parkinglot?.address?.toString()}'),
          Text('Cost: ${item.parkinglot?.hourlyPrice.toStringAsFixed(1)}'),
          Text(
              'Car: ${item.vehicle?.type.name}  ${item.vehicle?.registrationNo}'),
          Text('Owner: ${item.vehicle?.owner?.name}'),
          Text('Start time: ${item.startTime.parkingFormat()}'),
          Text('End time: ${item.endTime?.parkingFormat() ?? 'Ongoing'}'),
          // TODO Add later
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: <Widget>[
          //     TextButton(
          //       child: const Text('Edit'),
          //       onPressed: () {},
          //     ),
          //   ],
          // )
        ]),
      ),
    );
  }
}
