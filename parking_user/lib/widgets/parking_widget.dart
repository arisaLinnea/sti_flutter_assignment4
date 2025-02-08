import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:parking_user/blocs/notification/notification_bloc.dart';
import 'package:parking_user/widgets/time_spinner_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_client/shared_client.dart';

class ParkingWidget extends StatelessWidget {
  const ParkingWidget(
      {super.key,
      required this.item,
      required this.number,
      required this.isActive});

  final Parking item;
  final int number;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    NotificationState notificationState =
        context.watch<NotificationBloc>().state;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        title: Text(
            textAlign: TextAlign.left,
            style: const TextStyle(fontWeight: FontWeight.bold),
            'Parking $number:'),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Address: ${item.parkinglot?.address.toString()}'),
              Text(
                  'Hourly price: ${item.parkinglot?.hourlyPrice.toStringAsFixed(1)}'),
              Text(
                  'Car: ${item.vehicle?.registrationNo} (${item.vehicle?.type.name})'),
              Text('Start time: ${item.startTime.parkingFormat()}'),
              Text('End time: ${item.endTime?.parkingFormat() ?? 'Ongoing'}'),
              Builder(
                builder: (context) {
                  if (isActive) {
                    bool is_scheduled =
                        notificationState.isIdScheduled(item.id);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: const Text('Set stop time'),
                          onPressed: () async {
                            DateTime? picked = await showEndTimePicker(context);

                            if (picked != null &&
                                picked != item.endTime &&
                                context.mounted) {
                              item.endTime = DateTime.now().add(Duration(
                                hours: picked.hour,
                                minutes: picked.minute,
                                seconds: picked.second,
                              ));
                              context
                                  .read<ParkingBloc>()
                                  .add(EditParkingEvent(parking: item));
                            }
                          },
                        ),
                        item.endTime != null
                            ? IconButton(
                                icon: const FaIcon(FontAwesomeIcons.bell),
                                onPressed: () => {
                                      context.read<NotificationBloc>().add(
                                          ScheduleNotification(
                                              id: item.id,
                                              title: "Parking expiration",
                                              content:
                                                  'Parking at ${item.parkinglot?.address.toString()}',
                                              deliveryTime: item.endTime!
                                                  .subtract(const Duration(
                                                      seconds: 5)))),
                                    })
                            : const SizedBox.shrink(),

                        /*
                             IconButton(
                            icon: const FaIcon(FontAwesomeIcons.bell_slash),
                            onPressed: () => {}),
                            */
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ]),
      ),
    );
  }
}
