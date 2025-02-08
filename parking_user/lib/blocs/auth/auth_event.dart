part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String userName;
  final String pwd;

  AuthLoginEvent({required this.userName, required this.pwd});

  @override
  List<Object?> get props => [userName, pwd];
}

class AuthLogoutEvent extends AuthEvent {}

class AuthUserSubscription extends AuthEvent {}
