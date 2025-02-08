import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_client/shared_client.dart';

class AddParkingLotView extends StatelessWidget {
  const AddParkingLotView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    String? street;
    String? city;
    String? zip;
    String? price;

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Add new parking lot",
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
                        onSaved: (newValue) => street = newValue,
                        label: 'Street address:',
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Enter a valid registration number'
                            : null),
                    parkingFormAddTextField(
                        label: 'Zip code:',
                        onSaved: (newValue) => zip = newValue,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Enter a zip number'
                            : null),
                    parkingFormAddTextField(
                        label: 'City: ',
                        onSaved: (newValue) => city = newValue,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Enter a city name'
                            : null),
                    parkingFormAddTextField(
                        label: 'Price per hour: ',
                        onSaved: (newValue) => price = newValue,
                        validator: (value) => (value == null ||
                                value.isEmpty ||
                                double.tryParse(value) == null)
                            ? 'Enter a valid double/int/float value'
                            : null),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();

                                Address address = Address(
                                    street: street!,
                                    zipCode: zip!,
                                    city: city!);
                                double hourlyPrice =
                                    double.tryParse(price!) == null
                                        ? 0
                                        : double.parse(price!);
                                ParkingLot newLot = ParkingLot(
                                    address: address, hourlyPrice: hourlyPrice);

                                context
                                    .read<ParkingLotBloc>()
                                    .add(AddParkingLotEvent(lot: newLot));
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
