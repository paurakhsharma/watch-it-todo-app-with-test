import 'package:todo_get_it_mixin/features/core/models/todo.dart';
import 'package:todo_get_it_mixin/features/core/services/store_service.dart';

class TodoService {
  final StoreService storeService;

  final todosKey = 'todos';

  TodoService(this.storeService);

  /// Saves the list of todos to the store
  Future<void> saveTodos(List<Todo> todos) async {
    await storeService.save(todosKey, todos);
  }

  /// Gets the list of todos from the store
  /// If the list of todos is not found in the store, returns an empty list
  List<Todo> getTodos() {
    final data = storeService.get(todosKey);

    if (data == null) {
      return [];
    }

    return (data as List).map((e) => Todo.fromJson(e)).toList();
  }

  /// Clears the todo store
  Future<void> deleteTodos() async {
    await storeService.delete(todosKey);
  }
}
