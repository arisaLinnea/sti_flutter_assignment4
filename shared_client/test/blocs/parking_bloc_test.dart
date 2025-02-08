import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shared_client/shared_client.dart';

import '../mock_data.dart';

class MockParkingRepo extends Mock implements ParkingRepository {}

void main() {
  late ParkingBloc parkingBloc;
  late MockParkingRepo mockParkingRepository;

  setUp(() {
    mockParkingRepository = MockParkingRepo();

    parkingBloc = ParkingBloc(
      parkingRepository: mockParkingRepository,
    );
  });

  setUpAll(() {
    registerFallbackValue(newParking);
  });

  tearDown(() {
    parkingBloc.close();
  });

  group('ParkingBloc Tests', () {
    test('initial state is ParkingInitial', () {
      expect(parkingBloc.state, equals(ParkingInitial()));
    });

    blocTest<ParkingBloc, ParkingState>(
      'emits ParkingLoaded when LoadParkingsEvent is added',
      build: () {
        when(() => mockParkingRepository.getList()).thenAnswer(
          (_) async => [newParking],
        );
        return parkingBloc;
      },
      act: (bloc) => bloc.add(LoadParkingsEvent()),
      expect: () => [
        ParkingLoading(),
        ParkingLoaded(parkings: [newParking]),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.getList()).called(1);
      },
    );
    blocTest<ParkingBloc, ParkingState>(
      'emits ParkingLoaded with empty array',
      build: () {
        when(() => mockParkingRepository.getList()).thenAnswer(
          (_) async => [],
        );
        return parkingBloc;
      },
      act: (bloc) => bloc.add(LoadParkingsEvent()),
      expect: () => [
        ParkingLoading(),
        ParkingLoaded(parkings: []),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.getList()).called(1);
      },
    );
    blocTest<ParkingBloc, ParkingState>(
      'emits ParkingFailure when LoadParkingsEvent throws an error',
      build: () {
        when(() => mockParkingRepository.getList())
            .thenThrow(Exception('Get List Failed'));
        return parkingBloc;
      },
      act: (bloc) => bloc.add(LoadParkingsEvent()),
      expect: () => [
        ParkingLoading(),
        ParkingFailure('Exception: Get List Failed'),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.getList()).called(1);
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits ParkingSuccess when RemoveParkingEvent is successful',
      build: () {
        // Arrange: Mock the repository to return true for remove
        when(() => mockParkingRepository.remove(id: any(named: 'id')))
            .thenAnswer((_) async => true);
        when(() => mockParkingRepository.getList())
            .thenAnswer((_) async => [newParking]);
        return parkingBloc;
      },
      act: (bloc) => bloc.add(RemoveParkingEvent(parkingId: mockParkingId)),
      expect: () => [
        ParkingLoading(),
        ParkingSuccess('Parking removed successfully'),
        ParkingLoading(),
        ParkingLoaded(parkings: [newParking]),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.remove(id: mockParkingId)).called(1);
        verify(() => mockParkingRepository.getList()).called(1);
      },
    );

    blocTest<ParkingBloc, ParkingState>(
        'emits ParkingFailure when RemoveParkingEvent fails',
        build: () {
          // Arrange: Mock the repository to return false for remove
          when(() => mockParkingRepository.remove(id: any(named: 'id')))
              .thenAnswer((_) async => false);
          return parkingBloc;
        },
        act: (bloc) => bloc.add(RemoveParkingEvent(parkingId: mockParkingId)),
        expect: () => [
              ParkingLoading(),
              ParkingFailure('Failed to remove parking'),
            ],
        verify: (_) {
          verify(() => mockParkingRepository.remove(id: mockParkingId))
              .called(1);
          verifyNever(() => mockParkingRepository.getList());
        });

    blocTest<ParkingBloc, ParkingState>(
      'emits ParkingFailure when RemoveParkingEvent throws an error',
      build: () {
        when(() => mockParkingRepository.remove(id: any(named: 'id')))
            .thenThrow(Exception('Remove Parking Failed'));
        return parkingBloc;
      },
      act: (bloc) => bloc.add(RemoveParkingEvent(parkingId: mockParkingId)),
      expect: () => [
        ParkingLoading(),
        ParkingFailure('Exception: Remove Parking Failed'),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.remove(id: mockParkingId)).called(1);
        verifyNever(() => mockParkingRepository.getList());
      },
    );

    blocTest<ParkingBloc, ParkingState>(
        'emits ParkingSuccess when AddVParkingEvent is successful',
        build: () {
          // Arrange: Mock the repository to return a valid vehicle ID
          when(() => mockParkingRepository.addToList(item: any(named: 'item')))
              .thenAnswer((_) async => 'new_vehicle_id');
          when(() => mockParkingRepository.getList())
              .thenAnswer((_) async => [newParking]);
          return parkingBloc;
        },
        act: (bloc) => bloc.add(AddParkingEvent(parking: newParking)),
        expect: () => [
              ParkingLoading(),
              ParkingSuccess('Parking added successfully'),
              ParkingLoading(),
              ParkingLoaded(parkings: [newParking]),
            ],
        verify: (_) {
          verify(() => mockParkingRepository.addToList(item: newParking))
              .called(1);
          verify(() => mockParkingRepository.getList()).called(1);
        });

    blocTest<ParkingBloc, ParkingState>(
        'emits ParkingFailure when AddParkingEvent fails',
        build: () {
          // Arrange: Mock the repository to return null for add
          when(() => mockParkingRepository.addToList(item: any(named: 'item')))
              .thenAnswer((_) async => null);
          return parkingBloc;
        },
        act: (bloc) => bloc.add(AddParkingEvent(parking: newParking)),
        expect: () => [
              ParkingLoading(),
              ParkingFailure('Failed to add parking'),
            ],
        verify: (_) {
          verify(() => mockParkingRepository.addToList(item: newParking))
              .called(1);
          verifyNever(() => mockParkingRepository.getList());
        });
    blocTest<ParkingBloc, ParkingState>(
        'emits ParkingFailure when AddParkingEvent throws an error',
        build: () {
          // Arrange: Mock the repository to return null for add
          when(() => mockParkingRepository.addToList(item: any(named: 'item')))
              .thenThrow(Exception('Add Parking Failed'));
          return parkingBloc;
        },
        act: (bloc) => bloc.add(AddParkingEvent(parking: newParking)),
        expect: () => [
              ParkingLoading(),
              ParkingFailure('Exception: Add Parking Failed'),
            ],
        verify: (_) {
          verify(() => mockParkingRepository.addToList(item: newParking))
              .called(1);
          verifyNever(() => mockParkingRepository.getList());
        });

    blocTest<ParkingBloc, ParkingState>(
        'emit ParkingSuccess when EditParkingEvent is successful',
        build: () {
          // Arrange: Mock the repository to return true for update
          when(() => mockParkingRepository.update(
              id: any(named: 'id'),
              item: any(named: 'item'))).thenAnswer((_) async => true);
          when(() => mockParkingRepository.getList())
              .thenAnswer((_) async => [newParking]);
          return parkingBloc;
        },
        act: (bloc) => bloc.add(EditParkingEvent(parking: newParking)),
        expect: () => [
              ParkingLoading(),
              ParkingSuccess('Parking updated successfully'),
              ParkingLoading(),
              ParkingLoaded(parkings: [newParking]),
            ],
        verify: (_) {
          verify(() => mockParkingRepository.update(
              id: newParking.id, item: newParking)).called(1);
          verify(() => mockParkingRepository.getList()).called(1);
        });
    blocTest<ParkingBloc, ParkingState>(
        'emit ParkingFailure when EditParkingEvent fails',
        build: () {
          // Arrange: Mock the repository to return false for update
          when(() => mockParkingRepository.update(
              id: any(named: 'id'),
              item: any(named: 'item'))).thenAnswer((_) async => false);
          return parkingBloc;
        },
        act: (bloc) => bloc.add(EditParkingEvent(parking: newParking)),
        expect: () => [
              ParkingLoading(),
              ParkingFailure('Failed to update parking'),
            ],
        verify: (_) {
          verify(() => mockParkingRepository.update(
              id: newParking.id, item: newParking)).called(1);
          verifyNever(() => mockParkingRepository.getList());
        });
    blocTest<ParkingBloc, ParkingState>(
        'emit ParkingFailure when EditParkingEvent throws an error',
        build: () {
          // Arrange: Mock the repository to return false for update
          when(() => mockParkingRepository.update(
              id: any(named: 'id'),
              item: any(named: 'item'))).thenThrow(Exception('Update Failed'));
          return parkingBloc;
        },
        act: (bloc) => bloc.add(EditParkingEvent(parking: newParking)),
        expect: () => [
              ParkingLoading(),
              ParkingFailure('Exception: Update Failed'),
            ],
        verify: (_) {
          verify(() => mockParkingRepository.update(
              id: newParking.id, item: newParking)).called(1);
          verifyNever(() => mockParkingRepository.getList());
        });
  });
}
