import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:parking_user/blocs/notification/notification_bloc.dart';
import 'package:parking_user/utils/utils.dart';
import 'package:parking_user/widgets/time_spinner_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_client/shared_client.dart';

class ParkingWidget extends StatefulWidget {
  const ParkingWidget(
      {super.key,
      required this.item,
      required this.number,
      required this.isActive});

  final Parking item;
  final int number;
  final bool isActive;

  @override
  State<ParkingWidget> createState() => _ParkingWidgetState();
}

class _ParkingWidgetState extends State<ParkingWidget> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start a timer to check the parking's end time periodically
    _timer = Timer.periodic(Duration(seconds: 10), _checkParkingEndTime);
  }

  @override
  void dispose() {
    _timer
        .cancel(); // Make sure to cancel the timer when the widget is disposed
    super.dispose();
  }

  // Method to check the parking's end time and update the state if needed
  void _checkParkingEndTime(Timer timer) {
    if (widget.isActive && widget.item.endTime != null) {
      bool hasEnded = DateTime.now().isAfter(widget.item.endTime!);

      // If parking has ended and we are showing it as active, update state
      if (hasEnded) {
        context.read<ParkingBloc>().add(LoadParkingsEvent());
        // Cancel the notification if it was scheduled
        context
            .read<NotificationBloc>()
            .add(CancelNotification(id: widget.item.id));
      }
    }
  }

  void setParkingStopTime() async {
    DateTime? picked = await showEndTimePicker(context);

    if (picked != null && picked != widget.item.endTime && context.mounted) {
      widget.item.endTime = DateTime.now().add(Duration(
        hours: picked.hour,
        minutes: picked.minute,
        seconds: picked.second,
      ));
      context.read<ParkingBloc>().add(EditParkingEvent(parking: widget.item));
      // If there is a notification scheduled for this parking, cancel it
      context
          .read<NotificationBloc>()
          .add(CancelNotification(id: widget.item.id));
    }
  }

  void setNotification() async {
    DateTime? picked = await showEndTimePicker(context);

    if (picked != null && picked != widget.item.endTime && context.mounted) {
      Duration diff = Duration(
          hours: picked.hour, minutes: picked.minute, seconds: picked.second);

      if (widget.item.endTime!.isAfter(DateTime.now().add(diff))) {
        context.read<NotificationBloc>().add(ScheduleNotification(
            id: widget.item.id,
            title: "Parking expiration",
            content: 'Parking at ${widget.item.parkinglot?.address.toString()}',
            deliveryTime: widget.item.endTime!.subtract(diff)));
      } else {
        Utils.toastMessage('Too late to schedule notification');
      }
    }
  }

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
            'Parking ${widget.number}:'),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Address: ${widget.item.parkinglot?.address.toString()}'),
              Text(
                  'Hourly price: ${widget.item.parkinglot?.hourlyPrice.toStringAsFixed(1)}'),
              Text(
                  'Car: ${widget.item.vehicle?.registrationNo} (${widget.item.vehicle?.type.name})'),
              Text('Start time: ${widget.item.startTime.parkingFormat()}'),
              Text(
                  'End time: ${widget.item.endTime?.parkingFormat() ?? 'Ongoing'}'),
              Builder(
                builder: (context) {
                  if (widget.isActive) {
                    bool is_scheduled =
                        notificationState.isIdScheduled(widget.item.id);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: const Text('Set stop time'),
                          onPressed: () async {
                            setParkingStopTime();
                          },
                        ),
                        widget.item.endTime != null
                            ? IconButton(
                                icon: is_scheduled
                                    ? const FaIcon(FontAwesomeIcons.bell)
                                    : FaIcon(FontAwesomeIcons.bellSlash),
                                onPressed: () async => {
                                      if (is_scheduled)
                                        {
                                          context.read<NotificationBloc>().add(
                                              CancelNotification(
                                                  id: widget.item.id))
                                        }
                                      else
                                        {setNotification()}
                                    })
                            : const SizedBox.shrink(),
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
