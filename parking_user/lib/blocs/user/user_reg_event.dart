part of 'user_reg_bloc.dart';

abstract class UserRegEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserRegisterEvent extends UserRegEvent {
  final String name;
  final String ssn;
  final String username;
  final String password;

  UserRegisterEvent({
    required this.name,
    required this.ssn,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [name, ssn, username, password];
}
