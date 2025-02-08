import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_client/shared_client.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserLoginRepository userLoginRepository;
  final OwnerRepository ownerRepository;

  AuthBloc({required this.ownerRepository, required this.userLoginRepository})
      : super(AuthInitialState()) {
    on<AuthEvent>((event, emit) async {
      try {
        if (event is AuthLoginEvent) {
          await _handleLoginToState(event, emit);
        } else if (event is AuthLogoutEvent) {
          await _handleLogoutToState(emit);
        } else if (event is AuthUserSubscription) {
          return emit.onEach(userLoginRepository.userStream,
              onData: (authUser) async {
            if (authUser != null) {
              Owner newUser =
                  await ownerRepository.getElementByAuthId(id: authUser.uid);
              return emit(AuthAuthenticatedState(newUser: newUser));
            } else {
              return emit(AuthUnauthorizedState());
            }
          });
        }
      } catch (e) {
        if (e is FirebaseAuthException) {
          emit(AuthFailedState(
              message: e.message ?? 'An unknown error occurred'));
        } else {
          emit(AuthFailedState(message: 'An unknown error occurred'));
        }
        emit(AuthUnauthorizedState());
      }
    });
  }

  Future<void> _handleLoginToState(
      AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    await userLoginRepository.login(userName: event.userName, pwd: event.pwd);
  }

  Future<void> _handleLogoutToState(Emitter<AuthState> emit) async {
    await userLoginRepository.logout();
  }
}
