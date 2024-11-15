import 'package:flutter/material.dart';
import 'package:todo_get_it_signals/features/todo/screens/todo_screen.dart';

class TodoSignalsApp extends StatelessWidget {
  const TodoSignalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Signals',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.teal,
      ),
      home: const TodoScreen(),
    );
  }
}
