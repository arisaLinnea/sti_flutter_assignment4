import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/auth/auth_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    AuthState authState = context.watch<AuthBloc>().state;

    return Scaffold(
      // appBar: AppBar(title: const Text('Home')),
      body: Column(
        children: [
          Center(
            child: Text(
              'Welcome to Find Me A Spot',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Center(
            child: Text(
              'You are logged in as ${authState.user.name}',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
