import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_user/blocs/vehicle/vehicle_bloc.dart';
import 'package:shared_client/shared_client.dart';

class NewParkingView extends StatefulWidget {
  final ParkingLot lot;

  const NewParkingView({super.key, required this.lot});

  @override
  State<NewParkingView> createState() => _NewParkingViewState();
}

class _NewParkingViewState extends State<NewParkingView> {
  late List<Vehicle> myCars;
  Vehicle? vehicle;
  bool _isDropdownEnabled = false;
  String? _selectedHours;
  String? _selectedMinute;

  // List of hours for the dropdown
  final List<String> _hours = List.generate(24, (index) => (index).toString());

  // List of minutes for the dropdown
  final List<String> _minutes =
      List.generate(60, (index) => (index).toString());

  @override
  void initState() {
    super.initState();

    context.read<VehicleBloc>().add(LoadVehiclesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Start new parking",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
        body: BlocListener<ParkingBloc, ParkingState>(
          listener: (context, state) {
            if (state is ParkingSuccess) {
              context.pop();
            }
          },
          child: BlocBuilder<VehicleBloc, VehicleState>(
            builder: (context, state) {
              if (state is VehicleLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is VehicleLoaded) {
                myCars = state.vehicleList;
                return _buildNewParkingForm(formKey);
              }
              // Default case to handle unexpected state
              return const Center(child: Text('Unknown state'));
            },
          ),
        ));
  }

  Widget _buildNewParkingForm(GlobalKey<FormState> formKey) {
    return Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                child:
                    Text('New parking at: ${widget.lot.address.toString()}')),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                child: DropdownButtonFormField<Vehicle>(
                  decoration: const InputDecoration(
                    labelText: 'Car',
                  ),
                  value: vehicle,
                  hint: const Text('Select a car'),
                  onSaved: (newValue) => vehicle = newValue!,
                  onChanged: (Vehicle? value) {
                    setState(() {
                      vehicle = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a car';
                    }
                    return null;
                  },
                  items:
                      // CarBrand
                      myCars.map<DropdownMenuItem<Vehicle>>((Vehicle value) {
                    return DropdownMenuItem<Vehicle>(
                      value: value,
                      child:
                          Text('${value.registrationNo} (${value.type.name})'),
                    );
                  }).toList(),
                )),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _isDropdownEnabled,
                    onChanged: (bool? value) {
                      setState(() {
                        _isDropdownEnabled = value ?? false;
                        // Reset the dropdown selection when disabling
                        if (!_isDropdownEnabled) {
                          _selectedMinute = null;
                          _selectedHours = null;
                        }
                      });
                    },
                  ),
                  const Text('Choose end time'),
                ],
              ),
            ),
            if (_isDropdownEnabled)
              Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 24.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedHours,
                    hint: const Text('Select hours'),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select number of hours';
                      }
                      return null;
                    },
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedHours = newValue;
                      });
                    },
                    items: _hours
                        .map((hours) => DropdownMenuItem<String>(
                              value: hours,
                              child: Text(hours),
                            ))
                        .toList(),
                  )),
            if (_isDropdownEnabled)
              Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 16.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedMinute,
                    hint: const Text('Select minutes'),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select number of minutes';
                      }
                      return null;
                    },
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMinute = newValue;
                      });
                    },
                    items: _minutes
                        .map((minute) => DropdownMenuItem<String>(
                              value: minute,
                              child: Text(minute),
                            ))
                        .toList(),
                  )),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
              child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();

                        Parking newParking = Parking(
                          vehicle: vehicle,
                          parkinglot: widget.lot,
                          startTime: DateTime.now(),
                        );

                        if (_isDropdownEnabled) {
                          int endHours = _selectedHours != null
                              ? int.parse(_selectedHours!)
                              : 0;
                          int endMinutes = _selectedMinute != null
                              ? int.parse(_selectedMinute!)
                              : 0;
                          DateTime endTime = DateTime.now().add(
                              Duration(hours: endHours, minutes: endMinutes));
                          newParking.endTime = endTime;
                        }
                        context
                            .read<ParkingBloc>()
                            .add(AddParkingEvent(parking: newParking));

                        formKey.currentState?.reset();
                      }
                    },
                    child: const Text('Start'),
                  )),
            ),
          ],
        ));
  }
}
