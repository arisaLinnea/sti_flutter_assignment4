import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_client/shared_client.dart';

import '../mock_data.dart';

class MockParkingLotRepo extends Mock implements ParkingLotRepository {}

class MockParkingRepo extends Mock implements ParkingRepository {}

void main() {
  late ParkingLotBloc parkingLotBloc;
  late MockParkingLotRepo mockParkingLotRepository;
  late MockParkingRepo mockParkingRepository;

  setUp(() {
    mockParkingLotRepository = MockParkingLotRepo();
    mockParkingRepository = MockParkingRepo();

    parkingLotBloc = ParkingLotBloc(
      parkingLotRepository: mockParkingLotRepository,
      parkingRepository: mockParkingRepository,
    );
  });

  setUpAll(() {
    registerFallbackValue(newParkinglot);
  });

  tearDown(() {
    parkingLotBloc.close();
  });

  group('ParkingLotBloc Tests', () {
    test('initial state is ParkingLotInitial', () {
      expect(parkingLotBloc.state, equals(ParkingLotInitial()));
    });

    blocTest<ParkingLotBloc, ParkingLotState>(
      'emits ParkingLotLoaded when LoadParkingLotsEvent is added',
      build: () {
        when(() => mockParkingLotRepository.getList()).thenAnswer(
          (_) async => [newParkinglot],
        );
        return parkingLotBloc;
      },
      act: (bloc) => bloc.add(LoadParkingLotsEvent()),
      expect: () => [
        ParkingLotLoading(),
        ParkingLotLoaded(parkingLots: [newParkinglot]),
      ],
      verify: (_) {
        verify(() => mockParkingLotRepository.getList()).called(1);
      },
    );

    blocTest<ParkingLotBloc, ParkingLotState>(
      'emits ParkingLotLoaded with empty array',
      build: () {
        when(() => mockParkingLotRepository.getList()).thenAnswer(
          (_) async => [],
        );
        return parkingLotBloc;
      },
      act: (bloc) => bloc.add(LoadParkingLotsEvent()),
      expect: () => [
        ParkingLotLoading(),
        ParkingLotLoaded(parkingLots: []),
      ],
      verify: (_) {
        verify(() => mockParkingLotRepository.getList()).called(1);
      },
    );
    blocTest<ParkingLotBloc, ParkingLotState>(
      'emits ParkingLotFailure when LoadParkingLotsEvent throws an exception',
      build: () {
        when(() => mockParkingLotRepository.getList())
            .thenThrow(Exception('Get List Failed'));
        return parkingLotBloc;
      },
      act: (bloc) => bloc.add(LoadParkingLotsEvent()),
      expect: () => [
        ParkingLotLoading(),
        ParkingLotFailure('Exception: Get List Failed'),
      ],
      verify: (_) {
        verify(() => mockParkingLotRepository.getList()).called(1);
      },
    );

    blocTest<ParkingLotBloc, ParkingLotState>(
      'emits ParkingLotSuccess when RemoveParkingLotEvent is successful',
      build: () {
        // Arrange: Mock the repository to return true for remove
        when(() => mockParkingLotRepository.remove(id: any(named: 'id')))
            .thenAnswer((_) async => true);
        when(() => mockParkingLotRepository.getList())
            .thenAnswer((_) async => [newParkinglot]);
        return parkingLotBloc;
      },
      act: (bloc) => bloc.add(RemoveParkingLotEvent(lotId: mockLotId)),
      expect: () => [
        ParkingLotLoading(),
        ParkingLotSuccess('Parking lot removed successfully'),
        ParkingLotLoading(),
        ParkingLotLoaded(parkingLots: [newParkinglot]),
      ],
      verify: (_) {
        verify(() => mockParkingLotRepository.remove(id: mockLotId)).called(1);
        verify(() => mockParkingLotRepository.getList()).called(1);
      },
    );

    blocTest<ParkingLotBloc, ParkingLotState>(
        'emits ParkingLotFailure when RemoveParkingLotEvent fails',
        build: () {
          // Arrange: Mock the repository to return false for remove
          when(() => mockParkingLotRepository.remove(id: any(named: 'id')))
              .thenAnswer((_) async => false);
          return parkingLotBloc;
        },
        act: (bloc) => bloc.add(RemoveParkingLotEvent(lotId: mockLotId)),
        expect: () => [
              ParkingLotLoading(),
              ParkingLotFailure('Failed to remove parking lot'),
            ],
        verify: (_) {
          verify(() => mockParkingLotRepository.remove(id: mockLotId))
              .called(1);
          verifyNever(() => mockParkingLotRepository.getList());
        });

    blocTest<ParkingLotBloc, ParkingLotState>(
      'emits ParkingLotFailure when RemoveParkingLotEvent throws an exception',
      build: () {
        when(() => mockParkingLotRepository.remove(id: any(named: 'id')))
            .thenThrow(Exception('Remove Parking Lot Failed'));
        return parkingLotBloc;
      },
      act: (bloc) => bloc.add(RemoveParkingLotEvent(lotId: mockLotId)),
      expect: () => [
        ParkingLotLoading(),
        ParkingLotFailure('Exception: Remove Parking Lot Failed'),
      ],
      verify: (_) {
        verify(() => mockParkingLotRepository.remove(id: mockLotId)).called(1);
        verifyNever(() => mockParkingLotRepository.getList());
      },
    );

    blocTest<ParkingLotBloc, ParkingLotState>(
        'emits ParkingLotSuccess when AddParkingLotEvent is successful',
        build: () {
          // Arrange: Mock the repository to return a valid vehicle ID
          when(() =>
                  mockParkingLotRepository.addToList(item: any(named: 'item')))
              .thenAnswer((_) async => 'new_vehicle_id');
          when(() => mockParkingLotRepository.getList())
              .thenAnswer((_) async => [newParkinglot]);
          return parkingLotBloc;
        },
        act: (bloc) => bloc.add(AddParkingLotEvent(lot: newParkinglot)),
        expect: () => [
              ParkingLotLoading(),
              ParkingLotSuccess('Parking lot added successfully'),
              ParkingLotLoading(),
              ParkingLotLoaded(parkingLots: [newParkinglot]),
            ],
        verify: (_) {
          verify(() => mockParkingLotRepository.addToList(item: newParkinglot))
              .called(1);
          verify(() => mockParkingLotRepository.getList()).called(1);
        });

    blocTest<ParkingLotBloc, ParkingLotState>(
        'emits ParkingLotFailure when AddParkingLotEvent fails',
        build: () {
          // Arrange: Mock the repository to return null for add
          when(() =>
                  mockParkingLotRepository.addToList(item: any(named: 'item')))
              .thenAnswer((_) async => null);
          return parkingLotBloc;
        },
        act: (bloc) => bloc.add(AddParkingLotEvent(lot: newParkinglot)),
        expect: () => [
              ParkingLotLoading(),
              ParkingLotFailure('Failed to add parking lot'),
            ],
        verify: (_) {
          verify(() => mockParkingLotRepository.addToList(item: newParkinglot))
              .called(1);
          verifyNever(() => mockParkingLotRepository.getList());
        });
    blocTest<ParkingLotBloc, ParkingLotState>(
        'emits ParkingLotFailure when AddParkingLotEvent throws an exception',
        build: () {
          // Arrange: Mock the repository to return null for add
          when(() =>
                  mockParkingLotRepository.addToList(item: any(named: 'item')))
              .thenThrow(Exception('Add Parking Lot Failed'));
          return parkingLotBloc;
        },
        act: (bloc) => bloc.add(AddParkingLotEvent(lot: newParkinglot)),
        expect: () => [
              ParkingLotLoading(),
              ParkingLotFailure('Exception: Add Parking Lot Failed'),
            ],
        verify: (_) {
          verify(() => mockParkingLotRepository.addToList(item: newParkinglot))
              .called(1);
          verifyNever(() => mockParkingLotRepository.getList());
        });

    blocTest<ParkingLotBloc, ParkingLotState>(
        'emit ParkingLotSuccess when EditParkingLotEvent is successful',
        build: () {
          // Arrange: Mock the repository to return true for update
          when(() => mockParkingLotRepository.update(
              id: any(named: 'id'),
              item: any(named: 'item'))).thenAnswer((_) async => true);
          when(() => mockParkingLotRepository.getList())
              .thenAnswer((_) async => [newParkinglot]);
          return parkingLotBloc;
        },
        act: (bloc) => bloc.add(EditParkingLotEvent(lot: newParkinglot)),
        expect: () => [
              ParkingLotLoading(),
              ParkingLotSuccess('Parking lot updated successfully'),
              ParkingLotLoading(),
              ParkingLotLoaded(parkingLots: [newParkinglot]),
            ],
        verify: (_) {
          verify(() => mockParkingLotRepository.update(
              id: newParkinglot.id, item: newParkinglot)).called(1);
          verify(() => mockParkingLotRepository.getList()).called(1);
        });
    blocTest<ParkingLotBloc, ParkingLotState>(
        'emit ParkingLotFailure when EditParkingLotEvent fails',
        build: () {
          // Arrange: Mock the repository to return false for update
          when(() => mockParkingLotRepository.update(
              id: any(named: 'id'),
              item: any(named: 'item'))).thenAnswer((_) async => false);
          return parkingLotBloc;
        },
        act: (bloc) => bloc.add(EditParkingLotEvent(lot: newParkinglot)),
        expect: () => [
              ParkingLotLoading(),
              ParkingLotFailure('Failed to update parking lot'),
            ],
        verify: (_) {
          verify(() => mockParkingLotRepository.update(
              id: newParkinglot.id, item: newParkinglot)).called(1);
          verifyNever(() => mockParkingLotRepository.getList());
        });
    blocTest<ParkingLotBloc, ParkingLotState>(
        'emit ParkingLotFailure when EditParkingLotEvent throws an exception',
        build: () {
          // Arrange: Mock the repository to return false for update
          when(() => mockParkingLotRepository.update(
              id: any(named: 'id'),
              item: any(named: 'item'))).thenThrow(Exception('Update Failed'));
          return parkingLotBloc;
        },
        act: (bloc) => bloc.add(EditParkingLotEvent(lot: newParkinglot)),
        expect: () => [
              ParkingLotLoading(),
              ParkingLotFailure('Exception: Update Failed'),
            ],
        verify: (_) {
          verify(() => mockParkingLotRepository.update(
              id: newParkinglot.id, item: newParkinglot)).called(1);
          verifyNever(() => mockParkingLotRepository.getList());
        });
  });
}
