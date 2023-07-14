import 'package:flutter/material.dart';

Future<List> showDateTimePicker(BuildContext context) async {
  final DateTime? pickedDateTime = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2021),
    lastDate: DateTime(2024),
  );

  final DateTime selectedDateTime;
  if (pickedDateTime != null) {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      selectedDateTime = DateTime(
        pickedDateTime.year,
        pickedDateTime.month,
        pickedDateTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      return [1, '$selectedDateTime'];
    }
  }

  return [
    0,
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().month)
  ];
}
