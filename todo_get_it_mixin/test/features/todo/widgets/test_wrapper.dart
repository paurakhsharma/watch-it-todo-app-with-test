import 'package:flutter/material.dart';

class TestWrapper extends StatelessWidget {
  final Widget child;
  const TestWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }
}
