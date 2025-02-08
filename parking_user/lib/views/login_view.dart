import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/auth/auth_bloc.dart';
import 'package:parking_user/blocs/user/user_reg_bloc.dart';
import 'package:parking_user/utils/utils.dart';
import 'package:shared_client/shared_client.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final ValueNotifier<bool> passwordNotifier = ValueNotifier(true);
    final usernameFocus = FocusNode();
    final passwordFocus = FocusNode();
    final authState = context.watch<AuthBloc>().state;
    String? userName;
    String? pwd;

    // Request focus only when not authenticating
    if (authState is AuthUnauthorizedState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        usernameFocus.requestFocus();
      });
    }

    return BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthAuthenticatedState) {
            Utils.toastMessage('Login Successful');
          }
          if (authState is AuthFailedState) {
            Utils.toastMessage('Login Failed: ${authState.message}', time: 2);
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
                    'Welcome to',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Text(
                    'Find Me A Spot',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    focusNode: usernameFocus,
                    onSaved: (newValue) => userName = newValue,
                    enabled: authState is! AuthLoadingState, // Not loading
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => value?.isValidEmail() ?? true
                        ? null
                        : 'Please enter a username/email',
                    onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder(
                    valueListenable: passwordNotifier,
                    builder: (_, passwordObscure, __) {
                      return TextFormField(
                        focusNode: passwordFocus,
                        onSaved: (newValue) => pwd = newValue,
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
                        validator: (value) => value?.isValidPassword() ?? true
                            ? null
                            : 'Please enter a password',
                        onFieldSubmitted: (_) {
                          if (formKey.currentState!.validate()) {}
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
                                formKey.currentState!.save();
                                context.read<AuthBloc>().add(AuthLoginEvent(
                                    userName: userName!.trim(),
                                    pwd: pwd!.trim()));
                              }
                            },
                            child: const Text('Login'),
                          ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () => showRegistrationDialog(context),
                      child: const Text('Create account'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void showRegistrationDialog(BuildContext context) async {
    final regFormKey = GlobalKey<FormState>();
    // final authState = Provider.of<AuthState>(context, listen: false);
    String? userName;
    String? pwd;
    String? name;
    String? ssn;

    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              child: SingleChildScrollView(
            child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor, //Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary,
                      offset: const Offset(4, 4),
                      spreadRadius: 2,
                      blurStyle: BlurStyle.solid,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: regFormKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              "Create a new account",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            Align(
                              alignment: Alignment.topRight,
                              child: CloseButton(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                            onSaved: (newValue) => name = newValue,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(Icons.account_circle),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please fill in a name';
                              }
                              return null;
                            }),
                        const SizedBox(height: 24),
                        TextFormField(
                          onSaved: (newValue) => ssn = newValue,
                          decoration: const InputDecoration(
                            labelText: 'SSN',
                            prefixIcon: Icon(Icons.key),
                          ),
                          validator: (value) => value?.isValidSsn() ?? true
                              ? null
                              : 'Please fill in a valid ssn, eg YYMMDDNNNN',
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                            onSaved: (newValue) => userName = newValue,
                            decoration: const InputDecoration(
                              labelText: 'Email / Username',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) => value?.isValidEmail() ?? true
                                ? null
                                : 'Please fill in a valid email address'),
                        const SizedBox(height: 24),
                        TextFormField(
                            onSaved: (newValue) => pwd = newValue,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            validator: (value) =>
                                value?.isValidPassword() ?? true
                                    ? null
                                    : 'Please fill in a password'),
                        const SizedBox(height: 24),
                        BlocConsumer<UserRegBloc, UserRegState>(
                            listener: (context, state) {
                          if (state is UserRegFailedState) {
                            Utils.toastMessage(state.message);
                          }
                          if (state is AuthRegistrationState) {
                            Utils.toastMessage('Registration successful');
                            Navigator.of(context).pop();
                          }
                        }, builder: (context, state) {
                          if (state is UserRegLoadingState) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton(
                              onPressed: () async {
                                if (regFormKey.currentState!.validate()) {
                                  // context.read<AuthState>().setUser(youruserinfo);
                                  regFormKey.currentState!.save();

                                  context.read<UserRegBloc>().add(
                                        UserRegisterEvent(
                                          username: userName!.trim(),
                                          password: pwd!.trim(),
                                          name: name!.trim(),
                                          ssn: ssn!.trim(),
                                        ),
                                      );
                                }
                              },
                              child: const Text('Add'),
                            ),
                          );
                        }),
                        const SizedBox(height: 24)
                      ]),
                )),
          ));
        });
  }
}
