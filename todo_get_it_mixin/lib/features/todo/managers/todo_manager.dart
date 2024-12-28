import 'package:signals/signals.dart';

import '../../core/models/todo.dart';
import '../services/todo_service.dart';

/// Manages the list of todos
class TodoManager {
  final TodoService _todoService;

  TodoManager(this._todoService) {
    _init();
  }

  /// Initialize the manager, gets all the todos from the store
  /// and sets the value of the [todosSignal]
  Future<void> _init() async {
    todosSignal.value = _todoService.getTodos();
  }

  final todosSignal = Signal<List<Todo>>([]);

  List<Todo> get _todos => todosSignal.value;

  List<Todo> get sortedTodos => _todos..sort(_sortCompletedLast);

  int get firstCompletedIndex =>
      sortedTodos.indexWhere((todo) => todo.isCompleted);

  /// Adds a new todo to the list of todos and saves it to the store
  Future<void> addTodo(Todo todo) async {
    todosSignal.value = [..._todos, todo];
    await _todoService.saveTodos(_todos);
  }

  /// Updates a todo from the list of todos and saves it to the store
  Future<void> updateTodo(Todo todo) async {
    todosSignal.value = _todos
        .map(
          (element) => element.id == todo.id ? todo : element,
        )
        .toList();
    await _todoService.saveTodos(_todos);
  }

  int _sortCompletedLast(Todo a, Todo b) {
    if (a.isCompleted && b.isCompleted) {
      return 0;
    }
    return a.isCompleted ? 1 : -1;
  }

  /// Disposes the [TodoManager]
  dispose() {
    todosSignal.dispose();
  }
}
