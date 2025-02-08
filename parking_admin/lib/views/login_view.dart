import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_admin/blocs/auth/auth_bloc.dart';
import 'package:parking_admin/utils/utils.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final ValueNotifier<bool> passwordNotifier = ValueNotifier(true);
    final usernameFocus = FocusNode();
    final passwordFocus = FocusNode();
    final authState = context.watch<AuthBloc>().state;

    // Request focus only when not authenticating
    if (authState is AuthUnauthorizedState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        usernameFocus.requestFocus();
      });
    }

    return BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthAuthenticatedState) {
            Utils().showSnackBar(context, 'Login Successful');
          }

          if (authState is AuthFailedState) {
            Utils().showSnackBar(context, 'Login Failed');
          }
        },
        child: Center(
          child: Form(
            key: formKey,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    focusNode: usernameFocus,
                    enabled: authState is! AuthLoadingState, // Not loading
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter a username'
                        : null,
                    onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder(
                    valueListenable: passwordNotifier,
                    builder: (_, passwordObscure, __) {
                      return TextFormField(
                        focusNode: passwordFocus,
                        obscureText: passwordObscure,
                        enabled: authState is! AuthLoadingState, // Not loading
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () =>
                                  passwordNotifier.value = !passwordObscure,
                              style: IconButton.styleFrom(
                                minimumSize: const Size.square(48),
                              ),
                              icon: Icon(
                                passwordObscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: Colors.black,
                              )),
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter a password'
                            : null,
                        onFieldSubmitted: (_) {
                          if (formKey.currentState!.validate()) {
                            // context.read<AuthState>().login();
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: authState is AuthLoadingState
                        ? const Center(child: CircularProgressIndicator())
                        : FilledButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                    AuthLoginEvent(email: '', password: ''));
                              }
                            },
                            child: const Text('Login'),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
