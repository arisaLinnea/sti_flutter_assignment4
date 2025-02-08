import 'package:flutter/material.dart';

import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

Future<DateTime?> showEndTimePicker(BuildContext context) async {
  return await showDialog<DateTime>(
    context: context,
    builder: (context) {
      DateTime? selectedTime;

      return AlertDialog(
        title: Text("Select time from now"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(" Hours : Minutes : Seconds"),
            TimePickerSpinner(
              time: DateTime.now()
                  .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0),
              is24HourMode: true,
              isShowSeconds: true,
              minutesInterval: 5,
              secondsInterval: 5,
              onTimeChange: (time) {
                selectedTime = time;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(selectedTime);
            },
            child: Text('Done'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null); // In case user cancels
            },
            child: Text('Cancel'),
          ),
        ],
      );
    },
  );
}
