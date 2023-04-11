import 'package:flutter/foundation.dart';

import '../../core/models/todo.dart';
import '../services/todo_service.dart';

/// Manages the list of todos
class TodoManager {
  final TodoService _todoService;

  TodoManager(this._todoService) {
    init();
  }

  /// Initialize the manager, gets all the todos from the store
  /// and sets the value of the [todosNotifier]
  Future<void> init() async {
    todosNotifier.value = _todoService.getTodos();
  }

  final todosNotifier = ValueNotifier<List<Todo>>([]);

  List<Todo> get _todos => todosNotifier.value;

  List<Todo> get sortedTodos => _todos..sort(sortCompletedLast);

  int get firstCompletedIndex => sortedTodos.indexWhere((todo) => todo.isCompleted);

  /// Adds a new todo to the list of todos and saves it to the store
  Future<void> addTodo(Todo todo) async {
    todosNotifier.value = [..._todos, todo];
    await _todoService.saveTodos(_todos);
  }

  /// Deletes a todo from the list of todos and saves it to the store
  Future<void> deleteTodo(Todo todo) async {
    todosNotifier.value =
        _todos.where((element) => element.id != todo.id).toList();
    await _todoService.saveTodos(_todos);
  }

  /// Deletes all todos from the list of todos and clears the store
  Future<void> deleteAllTodos() async {
    todosNotifier.value = [];
    await _todoService.deleteTodos();
  }

  /// Updates a todo from the list of todos and saves it to the store
  Future<void> updateTodo(Todo todo) async {
    todosNotifier.value = _todos
        .map(
          (element) => element.id == todo.id ? todo : element,
        )
        .toList();
    await _todoService.saveTodos(_todos);
  }

  int sortCompletedLast(Todo a, Todo b) {
    if (a.isCompleted && b.isCompleted) {
      return 0;
    }
    return a.isCompleted ? 1 : -1;
  }
}
