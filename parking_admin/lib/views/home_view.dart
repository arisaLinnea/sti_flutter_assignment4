import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Me A Spot Admin'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Welcome to Admin for', style: TextStyle(fontSize: 20)),
          Text('Find Me A Spot', style: TextStyle(fontSize: 24)),
        ]),
      ),
    );
  }
}
