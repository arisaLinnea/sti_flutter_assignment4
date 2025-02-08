part of 'auth_bloc.dart';

enum AuthStatus { unauthorized, loading, authenticated }

abstract class AuthState extends Equatable {
  late final AuthStatus status;

  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthFailedState extends AuthState {
  final String message;

  AuthFailedState({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticatedState extends AuthState {}

class AuthUnauthorizedState extends AuthState {}
