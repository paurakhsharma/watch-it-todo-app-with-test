import 'package:flutter/material.dart';

import '../../../service_locator.dart';
import '../../core/models/todo.dart';
import '../managers/todo_manager.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final description = todo.description;
    final isCompleted = todo.isCompleted;

    return ListTile(
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: description != null ? Text(description) : null,
      trailing: Checkbox(
        value: todo.isCompleted,
        onChanged: (value) {
          if (value == null) return;
          final newTodo = todo.copyWith(isCompleted: value);
          locator<TodoManager>().updateTodo(newTodo);
        },
      ),
    );
  }
}
