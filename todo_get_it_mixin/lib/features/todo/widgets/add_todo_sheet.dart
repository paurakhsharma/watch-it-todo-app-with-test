import 'package:flutter/material.dart';
import 'package:todo_get_it_signals/features/todo/managers/todo_manager.dart';
import 'package:todo_get_it_signals/service_locator.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/todo.dart';

class AddTodoSheet extends StatefulWidget {
  const AddTodoSheet({super.key});

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  final formKey = GlobalKey<FormState>();

  final titleTextController = TextEditingController();
  final descriptionTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: titleTextController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionTextController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                onPressed: addTodo,
                child: const Text('Add Todo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addTodo() {
    if (formKey.currentState?.validate() ?? false) {
      final todo = Todo(
        id: const Uuid().v4(),
        title: titleTextController.text,
        description: descriptionTextController.text.isEmpty
            ? null
            : descriptionTextController.text,
      );
      locator<TodoManager>().addTodo(todo);

      Navigator.of(context).pop();
    }
  }
}
