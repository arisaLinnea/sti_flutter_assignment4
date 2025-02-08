import 'package:flutter/material.dart';

Widget parkingFormEditTextField({
  required String label,
  required String? initialValue,
  required Function(String) onChanged,
  required Function(String?) onSaved,
}) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          filled: true,
          labelText: label,
        ),
        initialValue: initialValue,
        onChanged: onChanged,
        onSaved: onSaved,
      ));
}
