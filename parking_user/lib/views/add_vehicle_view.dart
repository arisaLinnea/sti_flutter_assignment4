import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/auth/auth_bloc.dart';
import 'package:parking_user/blocs/vehicle/vehicle_bloc.dart';
import 'package:shared_client/shared_client.dart';

class AddVehicleView extends StatelessWidget {
  const AddVehicleView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final loggedInUser = context.read<AuthBloc>().state.user;
    String? regNo;
    CarBrand type = CarBrand.None;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Add new vehicle",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
        body: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
            child: Form(
                key: formKey,
                child: Column(
                  children: [
                    parkingFormAddTextField(
                        label: 'Registration number',
                        onSaved: (newValue) => regNo = newValue,
                        validator: (value) => value?.isValidRegNo() ?? true
                            ? null
                            : 'Enter a valid registration number'),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<CarBrand>(
                          decoration: const InputDecoration(
                            labelText: 'Car brand',
                          ),
                          value: type,
                          hint: const Text('Select a vehicle type'),
                          onSaved: (newValue) => type = newValue!,
                          onChanged: (CarBrand? value) {},
                          validator: (value) {
                            if (value == null || value == CarBrand.None) {
                              return 'Please select a car brand';
                            }
                            return null;
                          },
                          items:
                              // CarBrand
                              CarBrand.values.map<DropdownMenuItem<CarBrand>>(
                                  (CarBrand value) {
                            return DropdownMenuItem<CarBrand>(
                              value: value,
                              child: Text(value.name),
                            );
                          }).toList(),
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 24.0),
                      child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();

                                Vehicle newVehicle = Vehicle(
                                    registrationNo: regNo!,
                                    type: type,
                                    owner: loggedInUser);
                                context
                                    .read<VehicleBloc>()
                                    .add(AddVehicleEvent(vehicle: newVehicle));
                                formKey.currentState?.reset();
                              }
                            },
                            child: const Text('Add'),
                          )),
                    ),
                  ],
                ))));
  }
}
