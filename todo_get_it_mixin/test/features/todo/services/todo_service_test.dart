import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_get_it_mixin/features/core/models/todo.dart';
import 'package:todo_get_it_mixin/features/core/services/store_service.dart';
import 'package:todo_get_it_mixin/features/todo/services/todo_service.dart';

import '../../../fixtures/fixture_reader.dart';
import 'todo_service_test.mocks.dart';

@GenerateMocks([StoreService])
void main() {
  late MockStoreService mockStoreService;
  late TodoService todoService;

  setUp(() {
    mockStoreService = MockStoreService();
    todoService = TodoService(mockStoreService);
  });

  group('saveTodos', () {
    final tTodos = [const Todo(id: 'id', title: 'Todo Title')];

    test('should call StoreService.save with correct data', () async {
      // act
      await todoService.saveTodos(tTodos);

      // assert
      verify(mockStoreService.save(todoService.todosKey, tTodos));
    });

    test('should throw an exception if StoreService.save throws an exception',
        () async {
      // arrange
      when(mockStoreService.save(any, any)).thenThrow(Exception());

      // act
      final call = todoService.saveTodos;

      // assert
      expect(() => call(tTodos), throwsException);
    });
  });

  group('getTodos', () {
    final tTodos = jsonDecode(fixture('todos.json'));

    test('should call StoreService.get with correct data', () async {
      // arrange
      when(mockStoreService.get(any)).thenReturn(tTodos);

      // act
      final result = todoService.getTodos();

      // assert
      verify(mockStoreService.get(todoService.todosKey));
      final todos = (tTodos as List).map((e) => Todo.fromJson(e)).toList();
      assert(listEquals(result, todos) == true);
    });

    test('should return an empty list if StoreService.get returns null',
        () async {
      // arrange
      when(mockStoreService.get(any)).thenReturn(null);

      // act
      final result = todoService.getTodos();

      // assert
      expect(result, []);
    });
  });
}
