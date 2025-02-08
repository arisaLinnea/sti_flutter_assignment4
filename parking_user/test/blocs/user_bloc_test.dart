import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parking_user/blocs/user/user_reg_bloc.dart';
import 'package:parking_user/utils/utils.dart';

import '../mocks/mock_data.dart';

class MockUserLoginRepository extends Mock implements UserLoginRepository {}

class MockOwnerRepository extends Mock implements OwnerRepository {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockUtils extends Mock implements Utils {}

void main() {
  late MockUserLoginRepository mockUserLoginRepository;
  late MockOwnerRepository mockOwnerRepository;
  late MockUserCredential mockCredential;
  late MockUser mockUser;
  late UserRegBloc userRegBloc;

  setUp(() {
    mockUserLoginRepository = MockUserLoginRepository();
    mockOwnerRepository = MockOwnerRepository();
    mockCredential = MockUserCredential();
    mockUser = MockUser();
    userRegBloc = UserRegBloc(
        userLoginRepository: mockUserLoginRepository,
        ownerRepository: mockOwnerRepository);
  });

  setUpAll(() {
    registerFallbackValue(mockOwner);
  });

  tearDown(() {
    userRegBloc.close();
  });

  group('UserRegBloc Tests', () {
    test('initial state is UserRegInitialState', () {
      expect(userRegBloc.state, equals(UserRegInitialState()));
    });

    blocTest<UserRegBloc, UserRegState>(
      'emits AuthRegistrationState when registration is successful',
      build: () {
        when(() => mockOwnerRepository.addToList(item: any(named: 'item')))
            .thenAnswer((_) async => 'owner-123');
        when(() => mockUserLoginRepository.getCurrentUser())
            .thenAnswer((_) => mockUser);
        when(() => mockUser.uid).thenAnswer((_) => 'user-123');
        when(() => mockUserLoginRepository.registerAccount(
            userName: any(named: "userName"),
            pwd: any(named: "pwd"))).thenAnswer((_) async => mockCredential);
        when(() => mockUserLoginRepository.logout())
            .thenAnswer((_) async => Future.value());
        return userRegBloc;
      },
      act: (bloc) => bloc.add(
        UserRegisterEvent(
          username: mockUsername,
          password: mockPassword,
          name: mockName,
          ssn: mockSsn,
        ),
      ),
      expect: () => [
        UserRegLoadingState(),
        AuthRegistrationState(),
      ],
      verify: (_) {
        verify(() => mockOwnerRepository.addToList(item: any(named: 'item')))
            .called(1);
        verify(() => mockUserLoginRepository.registerAccount(
            userName: any(named: "userName"),
            pwd: any(named: "pwd"))).called(1);
        verify(() => mockUserLoginRepository.logout()).called(1);
      },
    );

    blocTest<UserRegBloc, UserRegState>(
      'emits UserRegFailedState when OwnerRepository fails to add owner',
      build: () {
        when(() => mockUserLoginRepository.registerAccount(
            userName: any(named: "userName"),
            pwd: any(named: "pwd"))).thenAnswer((_) async => mockCredential);
        when(() => mockUserLoginRepository.getCurrentUser())
            .thenAnswer((_) => mockUser);
        when(() => mockUser.uid).thenAnswer((_) => 'user-123');
        when(() => mockUserLoginRepository.logout())
            .thenAnswer((_) async => Future.value());
        when(() => mockUserLoginRepository.deleteAccount())
            .thenAnswer((_) async => Future.value());
        when(() => mockOwnerRepository.addToList(item: any(named: 'item')))
            .thenAnswer((_) async => null); // Simulate failure to add owner
        return userRegBloc;
      },
      act: (bloc) => bloc.add(
        UserRegisterEvent(
          username: mockUsername,
          password: mockPassword,
          name: mockName,
          ssn: mockSsn,
        ),
      ),
      expect: () => [
        UserRegLoadingState(),
        UserRegFailedState(message: 'Failed to add account'),
      ],
      verify: (_) {
        verify(() => mockOwnerRepository.addToList(item: any(named: 'item')))
            .called(1);
        verify(() => mockUserLoginRepository.deleteAccount()).called(1);
        verify(() => mockUserLoginRepository.registerAccount(
            userName: any(named: "userName"), pwd: any(named: "pwd")));
      },
    );

    blocTest<UserRegBloc, UserRegState>(
      'emits UserRegFailedState when UserLoginRepository fails to add user login',
      build: () {
        when(() => mockOwnerRepository.addToList(item: any(named: 'item')))
            .thenAnswer((_) async => 'uuid-123');
        when(() => mockUserLoginRepository.getCurrentUser())
            .thenAnswer((_) => mockUser);
        when(() => mockUser.uid).thenAnswer((_) => 'user-123');
        when(() => mockUserLoginRepository.logout())
            .thenAnswer((_) async => Future.value());
        when(() =>
            mockUserLoginRepository.registerAccount(
                userName: any(named: "userName"),
                pwd: any(named: "pwd"))).thenThrow(FirebaseAuthException(
            code: 'error',
            message:
                'Failed to add account')); // Simulate failure to add login user
        return userRegBloc;
      },
      act: (bloc) => bloc.add(
        UserRegisterEvent(
          username: mockUsername,
          password: mockPassword,
          name: mockName,
          ssn: mockSsn,
        ),
      ),
      expect: () => [
        UserRegLoadingState(),
        UserRegFailedState(
            message:
                'Failed to add account: [firebase_auth/error] Failed to add account'),
      ],
      verify: (_) {
        verify(() => mockUserLoginRepository.registerAccount(
            userName: any(named: "userName"),
            pwd: any(named: "pwd"))).called(1);
        verify(() => mockUserLoginRepository.logout()).called(1);
        verifyNever(
            () => mockOwnerRepository.addToList(item: any(named: 'item')));
      },
    );
  });
}
