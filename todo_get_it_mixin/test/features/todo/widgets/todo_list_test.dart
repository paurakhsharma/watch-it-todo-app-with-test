import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:signals/signals.dart';
import 'package:todo_get_it_signals/features/core/models/todo.dart';
import 'package:todo_get_it_signals/features/todo/managers/todo_manager.dart';
import 'package:todo_get_it_signals/features/todo/widgets/todo_list.dart';
import 'package:todo_get_it_signals/features/todo/widgets/todo_tile.dart';

import 'test_wrapper.dart';
import 'todo_list_test.mocks.dart';

final locator = GetIt.instance;

@GenerateMocks([TodoManager])
void main() {
  late final MockTodoManager mockTodoManager;

  setUpAll(() {
    mockTodoManager = MockTodoManager();

    locator.registerSingleton<TodoManager>(mockTodoManager);
  });

  setUp(() {
    reset(mockTodoManager);
  });

  const tTodos = [
    Todo(
      id: '1',
      title: 'Title 1',
      description: 'Description',
      isCompleted: false,
    ),
    Todo(
      id: '2',
      title: 'Title 2',
      description: 'Description',
      isCompleted: true,
    ),
  ];

  testWidgets('Should show todos', (tester) async {
    // arrange
    when(mockTodoManager.todosSignal).thenReturn(Signal(tTodos));
    when(mockTodoManager.sortedTodos).thenReturn(tTodos);
    when(mockTodoManager.firstCompletedIndex).thenReturn(1);

    // act
    await tester.pumpWidget(TestWrapper(child: TodoList()));

    // assert
    expect(find.byType(TodoList), findsOneWidget);
    expect(find.byType(TodoTile), findsNWidgets(tTodos.length));

    final todoTiles =
        tester.widgetList<TodoTile>(find.byType(TodoTile)).toList();
    expect(todoTiles.length, tTodos.length);
    for (var i = 0; i < todoTiles.length; i++) {
      expect(todoTiles[i].todo, tTodos[i]);
    }
  });

  testWidgets('Should show empty message', (tester) async {
    // arrange
    when(mockTodoManager.todosSignal).thenReturn(Signal([]));
    when(mockTodoManager.sortedTodos).thenReturn([]);
    when(mockTodoManager.firstCompletedIndex).thenReturn(0);

    // act
    await tester.pumpWidget(TestWrapper(child: TodoList()));

    // assert
    expect(find.byType(TodoList), findsOneWidget);
    expect(find.byType(TodoTile), findsNothing);
    expect(find.text('No todos yet!'), findsOneWidget);
  });

  testWidgets('Should show Divider before first completed todo',
      (tester) async {
    // arrange
    when(mockTodoManager.todosSignal).thenReturn(Signal(tTodos));
    when(mockTodoManager.sortedTodos).thenReturn(tTodos);
    when(mockTodoManager.firstCompletedIndex).thenReturn(1);

    // act
    await tester.pumpWidget(TestWrapper(child: TodoList()));

    // assert
    expect(find.byType(Divider), findsOneWidget);

    final todoTiles =
        tester.widgetList<TodoTile>(find.byType(TodoTile)).toList();

    final completedTodoIsInColumn = find.ancestor(
        of: find.byWidget(todoTiles[1]), matching: find.byType(Column));
    expect(completedTodoIsInColumn, findsOneWidget);

    final completedColumnHasDivider = find.descendant(
        of: completedTodoIsInColumn, matching: find.byType(Divider));
    expect(completedColumnHasDivider, findsOneWidget);

    final unCompletedTodoIsNotInColumn = find.ancestor(
        of: find.byWidget(todoTiles[0]), matching: find.byType(Column));
    expect(unCompletedTodoIsNotInColumn, findsNothing);
  });
}
