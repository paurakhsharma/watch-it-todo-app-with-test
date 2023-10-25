import 'package:flutter/material.dart';
import 'package:todo_get_it_mixin/features/todo/screens/todo_screen.dart';

class TodoGetItMixinApp extends StatelessWidget {
  const TodoGetItMixinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Watch It ',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.teal,
      ),
      home: const TodoScreen(),
    );
  }
}
