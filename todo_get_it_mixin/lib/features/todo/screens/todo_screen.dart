import 'package:flutter/material.dart';
import 'package:todo_get_it_signals/features/todo/widgets/todo_list.dart';

import '../widgets/add_todo_sheet.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Get It Mixin'),
      ),
      body: TodoList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openAddTodoSheet(context),
        label: const Row(
          children: [
            Icon(Icons.add),
            SizedBox(width: 8),
            Text('Add Todo'),
          ],
        ),
      ),
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
