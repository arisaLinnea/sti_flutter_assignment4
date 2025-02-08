import 'package:flutter/material.dart';
import 'package:go_router/src/misc/errors.dart';

class PageDoesNotExistView extends StatelessWidget {
  final GoException? error;

  const PageDoesNotExistView({this.error, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: <Widget>[
        const Text("Page Does Not Exist"),
        Text(error?.message ?? "")
      ],
    ));
  }
}
