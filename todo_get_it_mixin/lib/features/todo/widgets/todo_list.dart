import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../service_locator.dart';
import '../managers/todo_manager.dart';
import 'todo_tile.dart';

class TodoList extends StatelessWidget with WatchItMixin {
  TodoList({super.key});

  final todoManager = locator<TodoManager>();

  @override
  Widget build(BuildContext context) {
    watchValue((TodoManager m) => m.todosNotifier);
    final todos = todoManager.sortedTodos;

    final firstCompletedIndex = todoManager.firstCompletedIndex;

    if (todos.isEmpty) {
      return const Center(
        child: Text('No todos yet!'),
      );
    }

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        final child = TodoTile(todo: todo);

        if (firstCompletedIndex == index) {
          return Column(
            children: [
              const Divider(height: 0),
              child,
            ],
          );
        }

        return child;
      },
    );
  }
}
