import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parking_user/blocs/auth/auth_bloc.dart';
import 'package:parking_user/blocs/vehicle/vehicle_bloc.dart';

import '../mocks/mock_data.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockVehicleRepo extends Mock implements VehicleRepository {}

void main() {
  late VehicleBloc vehicleBloc;
  late MockAuthBloc mockAuthBloc;
  late MockVehicleRepo mockVehicleRepository;
  String vehicleId = '123';

  setUp(() {
    mockVehicleRepository = MockVehicleRepo();
    mockAuthBloc = MockAuthBloc();

    vehicleBloc = VehicleBloc(
      vehicleRepository: mockVehicleRepository,
      authBloc: mockAuthBloc,
    );
  });

  setUpAll(() {
    registerFallbackValue(newVehicle);
  });

  tearDown(() {
    vehicleBloc.close();
  });

  group('VehicleBloc Tests', () {
    // Mocking AuthBloc state and the user
    setUp(() {
      when(() => mockAuthBloc.state)
          .thenReturn(AuthAuthenticatedState(newUser: mockOwner));
    });

    test('initial state is VehicleInitial', () {
      expect(vehicleBloc.state, equals(VehicleInitial()));
    });

    blocTest<VehicleBloc, VehicleState>(
      'emits VehicleLoaded when LoadVehiclesEvent is added',
      build: () {
        when(() => mockVehicleRepository.getList()).thenAnswer(
          (_) async => [newVehicle],
        );
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(LoadVehiclesEvent()),
      expect: () => [
        VehicleLoading(),
        VehicleLoaded(vehicles: [newVehicle]),
      ],
      verify: (_) {
        verify(() => mockVehicleRepository.getList()).called(1);
      },
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits VehicleSuccess when RemoveVehicleEvent is successful',
      build: () {
        // Arrange: Mock the repository to return true for remove
        when(() => mockVehicleRepository.remove(id: any(named: 'id')))
            .thenAnswer((_) async => true);
        when(() => mockVehicleRepository.getList())
            .thenAnswer((_) async => [newVehicle]);
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(RemoveVehicleEvent(vehicleId: vehicleId)),
      expect: () => [
        VehicleLoading(),
        VehicleSuccess('Vehicle removed successfully'),
        VehicleLoading(),
        VehicleLoaded(vehicles: [newVehicle]),
      ],
      verify: (_) {
        verify(() => mockVehicleRepository.remove(id: vehicleId)).called(1);
        verify(() => mockVehicleRepository.getList()).called(1);
      },
    );

    blocTest<VehicleBloc, VehicleState>(
        'emits VehicleFailure when RemoveVehicleEvent fails',
        build: () {
          // Arrange: Mock the repository to return false for remove
          when(() => mockVehicleRepository.remove(id: any(named: 'id')))
              .thenAnswer((_) async => false);
          return vehicleBloc;
        },
        act: (bloc) => bloc.add(RemoveVehicleEvent(vehicleId: vehicleId)),
        expect: () => [
              VehicleLoading(),
              VehicleFailure('Failed to remove vehicle'),
            ],
        verify: (_) {
          verify(() => mockVehicleRepository.remove(id: vehicleId)).called(1);
          verifyNever(() => mockVehicleRepository.getList());
        });

    blocTest<VehicleBloc, VehicleState>(
        'emits VehicleSuccess when AddVehicleEvent is successful',
        build: () {
          // Arrange: Mock the repository to return a valid vehicle ID
          when(() => mockVehicleRepository.addToList(item: any(named: 'item')))
              .thenAnswer((_) async => 'new_vehicle_id');
          when(() => mockVehicleRepository.getList())
              .thenAnswer((_) async => [newVehicle]);
          return vehicleBloc;
        },
        act: (bloc) => bloc.add(AddVehicleEvent(vehicle: newVehicle)),
        expect: () => [
              VehicleLoading(),
              VehicleSuccess('Vehicle added successfully'),
              VehicleLoading(),
              VehicleLoaded(vehicles: [newVehicle]),
            ],
        verify: (_) {
          verify(() => mockVehicleRepository.addToList(item: newVehicle))
              .called(1);
          verify(() => mockVehicleRepository.getList()).called(1);
        });

    blocTest<VehicleBloc, VehicleState>(
        'emits VehicleFailure when AddVehicleEvent fails',
        build: () {
          // Arrange: Mock the repository to return null for add
          when(() => mockVehicleRepository.addToList(item: any(named: 'item')))
              .thenAnswer((_) async => null);
          return vehicleBloc;
        },
        act: (bloc) => bloc.add(AddVehicleEvent(vehicle: newVehicle)),
        expect: () => [
              VehicleLoading(),
              VehicleFailure('Failed to add vehicle'),
            ],
        verify: (_) {
          verify(() => mockVehicleRepository.addToList(item: newVehicle))
              .called(1);
          verifyNever(() => mockVehicleRepository.getList());
        });

    blocTest<VehicleBloc, VehicleState>(
        'emit VehicleSuccess when EditVehicleEvent is successful',
        build: () {
          // Arrange: Mock the repository to return true for update
          when(() => mockVehicleRepository.update(
              id: any(named: 'id'),
              item: any(named: 'item'))).thenAnswer((_) async => true);
          when(() => mockVehicleRepository.getList())
              .thenAnswer((_) async => [newVehicle]);
          return vehicleBloc;
        },
        act: (bloc) => bloc.add(EditVehicleEvent(vehicle: newVehicle)),
        expect: () => [
              VehicleLoading(),
              VehicleSuccess('Vehicle updated successfully'),
              VehicleLoading(),
              VehicleLoaded(vehicles: [newVehicle]),
            ],
        verify: (_) {
          verify(() => mockVehicleRepository.update(
              id: newVehicle.id, item: newVehicle)).called(1);
          verify(() => mockVehicleRepository.getList()).called(1);
        });
    blocTest<VehicleBloc, VehicleState>(
        'emit VehicleFailure when EditVehicleEvent fails',
        build: () {
          // Arrange: Mock the repository to return false for update
          when(() => mockVehicleRepository.update(
              id: any(named: 'id'),
              item: any(named: 'item'))).thenAnswer((_) async => false);
          return vehicleBloc;
        },
        act: (bloc) => bloc.add(EditVehicleEvent(vehicle: newVehicle)),
        expect: () => [
              VehicleLoading(),
              VehicleFailure('Failed to update vehicle'),
            ],
        verify: (_) {
          verify(() => mockVehicleRepository.update(
              id: newVehicle.id, item: newVehicle)).called(1);
          verifyNever(() => mockVehicleRepository.getList());
        });
  });
}
