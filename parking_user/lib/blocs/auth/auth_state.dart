part of 'auth_bloc.dart';

enum AuthStatus { unauthorized, loading, authenticated }

abstract class AuthState extends Equatable {
  late final AuthStatus status;
  late final Owner user;

  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthFailedState extends AuthState {
  final String message;

  AuthFailedState({required this.message}) {
    status = AuthStatus.unauthorized;
  }

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticatedState extends AuthState {
  AuthAuthenticatedState({required newUser}) {
    user = newUser;
    status = AuthStatus.authenticated;
  }

  @override
  List<Object?> get props => [user];
}

class AuthUnauthorizedState extends AuthState {
  AuthUnauthorizedState() {
    status = AuthStatus.unauthorized;
  }
}
