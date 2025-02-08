import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitialState()) {
    on<AuthEvent>((event, emit) async {
      try {
        if (event is AuthLoginEvent) {
          await _handleLoginToState(event, emit);
        } else if (event is AuthLogoutEvent) {
          await _handleLogoutToState(emit);
        }
      } catch (e) {
        emit(AuthUnauthorizedState());
      }
    });
  }

  Future<void> _handleLoginToState(
      AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      emit(AuthAuthenticatedState());
    } catch (e) {
      emit(AuthFailedState(message: 'Login Failed'));
      emit(AuthUnauthorizedState());
    }
  }

  Future<void> _handleLogoutToState(Emitter<AuthState> emit) async {
    emit(AuthUnauthorizedState());
  }
}
