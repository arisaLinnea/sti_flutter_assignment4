import 'package:flutter/material.dart';

Widget parkingFormAddTextField({
  required String label,
  required FormFieldSetter<String> onSaved,
  required FormFieldValidator<String> validator,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      onSaved: onSaved,
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: validator,
      onFieldSubmitted: (_) {},
    ),
  );
}
