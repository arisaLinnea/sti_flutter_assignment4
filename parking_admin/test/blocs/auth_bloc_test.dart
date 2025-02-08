import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parking_admin/blocs/auth/auth_bloc.dart';

import '../mocks/mock_data.dart';

void main() {
  late AuthBloc authBloc;

  setUp(() {
    // Initialize the AuthBloc
    authBloc = AuthBloc();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitialState', () {
      // Assert that the initial state is AuthInitialState
      expect(authBloc.state, equals(AuthInitialState()));
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoadingState, AuthAuthenticatedState] when AuthLoginEvent is added and login succeeds',
      build: () => authBloc,
      act: (bloc) async {
        bloc.add(AuthLoginEvent(email: username, password: password));
        await Future.delayed(
            const Duration(seconds: 2)); // Simulate login delay
      },
      expect: () => [
        AuthLoadingState(),
        AuthAuthenticatedState(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthorizedState] when AuthLogoutEvent is added',
      build: () => authBloc,
      act: (bloc) => bloc.add(AuthLogoutEvent()),
      expect: () => [AuthUnauthorizedState()],
    );
  });
}
