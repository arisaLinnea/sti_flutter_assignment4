import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_client/shared_client.dart';

class EditParkingLotView extends StatefulWidget {
  final String lotId;

  const EditParkingLotView({super.key, required this.lotId});

  @override
  State<EditParkingLotView> createState() => _ParkingLotViewState();
}

class _ParkingLotViewState extends State<EditParkingLotView> {
  late ParkingLot? parkingLot;
  final _formKey = GlobalKey<FormState>();
  String? street = '';
  String? zipcode = '';
  String? city = '';
  double? price;
  int maxValue = 50;

  @override
  void initState() {
    super.initState();
    parkingLot =
        context.read<ParkingLotBloc>().getParkingLotById(id: widget.lotId);
    print('ParkingLot: $parkingLot');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ParkingLotBloc, ParkingLotState>(
        listener: (context, state) {
          if (state is ParkingLotSuccess) {
            context.pop();
          }
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Edit Parking Lot'),
              backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            body: parkingLot == null
                ? const Text('Some error occurred')
                : Form(
                    key: _formKey,
                    child: Scrollbar(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Card(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ...[
                                    parkingFormEditTextField(
                                        label: 'Street',
                                        initialValue:
                                            parkingLot?.address?.street,
                                        onChanged: (value) {
                                          setState(() {
                                            street = value;
                                          });
                                        },
                                        onSaved: (value) {
                                          street = value;
                                        }),
                                    parkingFormEditTextField(
                                        label: 'ZipCode',
                                        initialValue:
                                            parkingLot?.address?.zipCode,
                                        onChanged: (value) {
                                          setState(() {
                                            zipcode = value;
                                          });
                                        },
                                        onSaved: (value) {
                                          zipcode = value;
                                        }),
                                    parkingFormEditTextField(
                                        label: 'City',
                                        initialValue: parkingLot?.address?.city,
                                        onChanged: (value) {
                                          setState(() {
                                            city = value;
                                          });
                                        },
                                        onSaved: (value) {
                                          city = value;
                                        }),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Price',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          intl.NumberFormat.currency(
                                                  symbol: "\$",
                                                  decimalDigits: 0)
                                              .format(price ??
                                                  parkingLot?.hourlyPrice),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        Slider(
                                          min: 0,
                                          max: maxValue.toDouble(),
                                          divisions: maxValue,
                                          value:
                                              price ?? parkingLot!.hourlyPrice,
                                          onChanged: (value) {
                                            setState(() {
                                              price = value;
                                            });
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 40.0, vertical: 24.0),
                                          child: SizedBox(
                                              width: double.infinity,
                                              height: 48,
                                              child: FilledButton(
                                                onPressed: () async {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    _formKey.currentState!
                                                        .save();

                                                    ParkingLot editedLot =
                                                        ParkingLot(
                                                            id: parkingLot!.id,
                                                            address: Address(
                                                                street: street!,
                                                                zipCode:
                                                                    zipcode!,
                                                                city: city!),
                                                            hourlyPrice: price ??
                                                                parkingLot!
                                                                    .hourlyPrice);

                                                    context
                                                        .read<ParkingLotBloc>()
                                                        .add(
                                                            EditParkingLotEvent(
                                                                lot:
                                                                    editedLot));
                                                    // _formKey.currentState?.reset();
                                                  }
                                                },
                                                child: const Text('Update'),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ].expand(
                                    (widget) => [
                                      widget,
                                      const SizedBox(
                                        height: 24,
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )));
  }
}
