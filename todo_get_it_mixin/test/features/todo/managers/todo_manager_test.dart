import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_get_it_signals/features/core/models/todo.dart';
import 'package:todo_get_it_signals/features/todo/managers/todo_manager.dart';
import 'package:todo_get_it_signals/features/todo/services/todo_service.dart';

import 'todo_manager_test.mocks.dart';

@GenerateMocks([TodoService])
void main() {
  late MockTodoService mockTodoService;

  setUp(() {
    mockTodoService = MockTodoService();
  });

  group('initialize', () {
    final tTodos = [const Todo(id: 'id', title: 'Todo Title')];
    test('should get todos and set it to todosNotifier when initialized',
        () async {
      // arrange
      when(mockTodoService.getTodos()).thenAnswer((_) => tTodos);
      // act
      final todoManager = TodoManager(mockTodoService);

      // assert
      verify(mockTodoService.getTodos());
      expect(todoManager.todosSignal.value, tTodos);
      verifyNoMoreInteractions(mockTodoService);
    });
  });

  group('addTodo', () {
    final tTodos = [const Todo(id: 'id', title: 'Todo Title')];
    const tTodo = Todo(id: 'id 2', title: 'Todo Title 2');
    test('should add todo to todosNotifier and save it to the store', () async {
      // arrange
      when(mockTodoService.saveTodos(any)).thenAnswer((_) async {});
      when(mockTodoService.getTodos()).thenAnswer((_) => tTodos);
      // act
      final todoManager = TodoManager(mockTodoService);
      await todoManager.addTodo(tTodo);

      // assert
      assert(
        listEquals(todoManager.todosSignal.value, [...tTodos, tTodo]) == true,
      );
      verify(mockTodoService.saveTodos(any));
      verify(mockTodoService.getTodos());
      verifyNoMoreInteractions(mockTodoService);
    });

    test('should throw an exception if StoreService.save throws an exception',
        () async {
      // arrange
      when(mockTodoService.saveTodos(any)).thenThrow(Exception());
      when(mockTodoService.getTodos()).thenAnswer((_) => tTodos);
      // act
      final todoManager = TodoManager(mockTodoService);
      final call = todoManager.addTodo;

      // assert
      expect(() => call(tTodo), throwsException);
      verify(mockTodoService.getTodos());
      verify(mockTodoService.saveTodos(any));
      verifyNoMoreInteractions(mockTodoService);
    });
  });

  group('updateTodo', () {
    final tTodos = [const Todo(id: 'id', title: 'Todo Title')];
    const tTodo = Todo(id: 'id', title: 'Todo Title 2');
    test('should update todo to todosNotifier and save it to the store',
        () async {
      // arrange
      when(mockTodoService.saveTodos(any)).thenAnswer((_) async {});
      when(mockTodoService.getTodos()).thenAnswer((_) => tTodos);
      // act
      final todoManager = TodoManager(mockTodoService);
      await todoManager.updateTodo(tTodo);

      // assert
      assert(
        listEquals(todoManager.todosSignal.value, [tTodo]) == true,
      );
      verify(mockTodoService.saveTodos(any));
      verify(mockTodoService.getTodos());
      verifyNoMoreInteractions(mockTodoService);
    });

    test('should throw an exception if StoreService.save throws an exception',
        () async {
      // arrange
      when(mockTodoService.saveTodos(any)).thenThrow(Exception());
      when(mockTodoService.getTodos()).thenAnswer((_) => tTodos);
      // act
      final todoManager = TodoManager(mockTodoService);
      final call = todoManager.updateTodo;

      // assert
      expect(() => call(tTodo), throwsException);
      verify(mockTodoService.getTodos());
      verify(mockTodoService.saveTodos(any));
      verifyNoMoreInteractions(mockTodoService);
    });
  });

  group('sortedTodos', () {
    final tTodos = [
      const Todo(id: 'id 1', title: 'Todo Title 1'),
      const Todo(
        id: 'id 2',
        title: 'Todo Title 2',
        isCompleted: true,
      ),
      const Todo(id: 'id 3', title: 'Todo Title 3'),
    ];
    test('should return todos sorted by completed at last', () async {
      // arrange
      when(mockTodoService.getTodos()).thenAnswer((_) => tTodos);
      // act
      final todoManager = TodoManager(mockTodoService);

      // assert
      expect(
        todoManager.sortedTodos,
        [
          const Todo(id: 'id 1', title: 'Todo Title 1'),
          const Todo(id: 'id 3', title: 'Todo Title 3'),
          const Todo(
            id: 'id 2',
            title: 'Todo Title 2',
            isCompleted: true,
          ),
        ],
      );
    });
  });

  group('firstCompletedIndex', () {
    final tTodos = [
      const Todo(id: 'id 1', title: 'Todo Title 1'),
      const Todo(
        id: 'id 2',
        title: 'Todo Title 2',
        isCompleted: true,
      ),
      const Todo(id: 'id 3', title: 'Todo Title 3'),
    ];
    test('should return the index of the first completed todo', () async {
      // arrange
      when(mockTodoService.getTodos()).thenAnswer((_) => tTodos);
      // act
      final todoManager = TodoManager(mockTodoService);

      // assert
      expect(todoManager.firstCompletedIndex, 2);
    });
  });

  group('dispose', () {
    test('should dispose todosNotifier', () async {
      // arrange
      when(mockTodoService.getTodos()).thenAnswer((_) => []);
      // act
      final todoManager = TodoManager(mockTodoService);
      todoManager.dispose();

      // assert
      // ignore: invalid_use_of_protected_member
      expect(todoManager.todosSignal.disposed, true);
    });
  });
}
