import 'package:shared_client/shared_client.dart';

String mockParkingId = '123';
String mockLotId = '123';

Vehicle vehicle = Vehicle(
  id: 'af75d24f-68d3-4e81-8001-59df5454fbb7',
  registrationNo: 'MMM111',
  type: CarBrand.BMW,
  owner: mockOwner,
);

Owner mockOwner = Owner(id: '123', ssn: '', name: '');
Address mockAddress = Address(
  id: '123',
  street: 'Testgatan 1',
  city: 'Teststad',
  zipCode: '12345',
);
ParkingLot newParkinglot = ParkingLot(address: mockAddress, hourlyPrice: 2.5);

Parking newParking = Parking(
    vehicle: vehicle, parkinglot: newParkinglot, startTime: DateTime.now());
