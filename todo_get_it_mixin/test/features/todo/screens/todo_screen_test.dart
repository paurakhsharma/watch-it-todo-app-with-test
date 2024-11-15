import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:signals/signals.dart';
import 'package:todo_get_it_signals/features/core/models/todo.dart';
import 'package:todo_get_it_signals/features/todo/managers/todo_manager.dart';
import 'package:todo_get_it_signals/features/todo/screens/todo_screen.dart';
import 'package:todo_get_it_signals/features/todo/widgets/todo_list.dart';
import 'package:todo_get_it_signals/features/todo/widgets/todo_tile.dart';

import '../widgets/test_wrapper.dart';
import 'todo_screen_test.mocks.dart';

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

  testWidgets('Should open add todo sheet', (tester) async {
    // arrange
    when(mockTodoManager.todosSignal).thenReturn(Signal([]));
    when(mockTodoManager.sortedTodos).thenReturn([]);
    when(mockTodoManager.firstCompletedIndex).thenReturn(0);

    // act
    await tester.pumpWidget(const TestWrapper(child: TodoScreen()));
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // assert
    final todoElevatedButton = find.byType(ElevatedButton);
    expect(todoElevatedButton, findsOneWidget);
    // Child of ElevatedButton is Text widget with 'Add Todo' text
    expect(
      find.descendant(of: todoElevatedButton, matching: find.text('Add Todo')),
      findsOneWidget,
    );
  });

  testWidgets('Should show empty message', (tester) async {
    // arrange
    when(mockTodoManager.todosSignal).thenReturn(Signal([]));
    when(mockTodoManager.sortedTodos).thenReturn([]);
    when(mockTodoManager.firstCompletedIndex).thenReturn(0);

    // act
    await tester.pumpWidget(const TestWrapper(child: TodoScreen()));

    // assert
    expect(find.byType(TodoScreen), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(TodoList), findsOneWidget);
    expect(find.text('No todos yet!'), findsOneWidget);
  });

  testWidgets('Should show todos', (tester) async {
    // arrange
    const tTodo = Todo(
      id: '1',
      title: 'Title',
      description: 'Description',
      isCompleted: false,
    );

    when(mockTodoManager.todosSignal).thenReturn(Signal([tTodo]));
    when(mockTodoManager.sortedTodos).thenReturn([tTodo]);
    when(mockTodoManager.firstCompletedIndex).thenReturn(0);

    // act
    await tester.pumpWidget(const TestWrapper(child: TodoScreen()));

    // assert
    expect(find.byType(TodoScreen), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(TodoList), findsOneWidget);
    expect(find.byType(TodoTile), findsOneWidget);
    expect(find.text(tTodo.title), findsOneWidget);
    expect(find.text(tTodo.description!), findsOneWidget);
  });
}
