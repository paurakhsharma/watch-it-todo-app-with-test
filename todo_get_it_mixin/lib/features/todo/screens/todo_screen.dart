import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:todo_get_it_mixin/features/todo/managers/todo_manager.dart';
import 'package:todo_get_it_mixin/features/todo/widgets/todo_tile.dart';
import 'package:todo_get_it_mixin/service_locator.dart';

import '../widgets/add_todo_sheet.dart';

class TodoScreen extends StatelessWidget with GetItMixin {
  TodoScreen({super.key});

  final todoManager = locator<TodoManager>();

  @override
  Widget build(BuildContext context) {
    watchX((TodoManager m) => m.todosNotifier);
    final todos = todoManager.sortedTodos;

    final firstCompletedIndex = todoManager.firstCompletedIndex;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Get It Mixin'),
      ),
      body: ListView.builder(
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
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => openAddTodoSheet(context),
          label: Row(
            children: const [
              Icon(Icons.add),
              SizedBox(width: 8),
              Text('Add Todo'),
            ],
          )),
    );
  }

  void openAddTodoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return const AddTodoSheet();
      },
    );
  }
}
