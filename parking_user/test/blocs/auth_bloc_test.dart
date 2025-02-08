import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parking_user/blocs/auth/auth_bloc.dart';

import '../mocks/mock_data.dart';

class MockUserLoginRepository extends Mock implements UserLoginRepository {}

class MockOwnerRepository extends Mock implements OwnerRepository {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockUserLoginRepository mockUserLoginRepository;
  late MockOwnerRepository mockOwnerRepository;
  late MockUserCredential mockCredential;
  late AuthBloc authBloc;

  setUp(() {
    mockUserLoginRepository = MockUserLoginRepository();
    mockOwnerRepository = MockOwnerRepository();
    mockCredential = MockUserCredential();
    authBloc = AuthBloc(
        userLoginRepository: mockUserLoginRepository,
        ownerRepository: mockOwnerRepository);
  });

  setUpAll(() {
    registerFallbackValue(mockOwner);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc Tests', () {
    test('initial state is AuthInitialState', () {
      expect(authBloc.state, equals(AuthInitialState()));
    });

    blocTest<AuthBloc, AuthState>(
      'emits AuthAuthenticatedState when login is successful',
      build: () {
        when(() => mockUserLoginRepository.login(
            userName: any(named: "userName"),
            pwd: any(named: "pwd"))).thenAnswer((_) async => mockCredential);
        return authBloc;
      },
      act: (bloc) => bloc.add(
        AuthLoginEvent(userName: mockUsername, pwd: mockPassword),
      ),
      expect: () => [
        AuthLoadingState(),
      ],
      verify: (_) {
        verify(() => mockUserLoginRepository.login(
            userName: any(named: "userName"),
            pwd: any(named: "pwd"))).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthFailedState when login is unsuccessful',
      build: () {
        when(() =>
            mockUserLoginRepository.login(
                userName: any(named: "userName"),
                pwd: any(named: "pwd"))).thenThrow(
            FirebaseAuthException(code: 'error', message: 'Failed to login'));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        AuthLoginEvent(userName: mockUsername, pwd: mockPassword),
      ),
      expect: () => [
        AuthLoadingState(),
        AuthFailedState(message: 'Failed to login'),
        AuthUnauthorizedState(),
      ],
      verify: (_) {
        verify(() => mockUserLoginRepository.login(
            userName: any(named: "userName"),
            pwd: any(named: "pwd"))).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthUnauthorizedState when logout is successful',
      build: () {
        when(() => mockUserLoginRepository.logout())
            .thenAnswer((_) async => Future.value());
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLogoutEvent()),
      expect: () => [],
      verify: (_) {
        verify(() => mockUserLoginRepository.logout()).called(1);
      },
    );
  });
}
