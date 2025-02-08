part of 'user_reg_bloc.dart';

enum RegStatus { ok, loading }

abstract class UserRegState extends Equatable {
  late final RegStatus status;

  @override
  List<Object?> get props => [];
}

class UserRegInitialState extends UserRegState {}

class UserRegLoadingState extends UserRegState {
  UserRegLoadingState() {
    status = RegStatus.loading;
  }

  @override
  List<Object?> get props => [status];
}

class UserRegFailedState extends UserRegState {
  final String message;

  UserRegFailedState({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthRegistrationState extends UserRegState {
  AuthRegistrationState() {
    status = RegStatus.ok;
  }

  @override
  List<Object?> get props => [status];
}
