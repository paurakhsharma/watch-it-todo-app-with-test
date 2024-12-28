import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:signals/signals.dart';
import 'package:todo_get_it_signals/features/core/models/todo.dart';
import 'package:todo_get_it_signals/features/todo/managers/todo_manager.dart';
import 'package:todo_get_it_signals/features/todo/widgets/add_todo_sheet.dart';

import 'add_todo_sheet_test.mocks.dart';
import 'test_wrapper.dart';

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

  const tTodo = Todo(
    id: '1',
    title: 'Title 1',
    description: 'Description',
    isCompleted: false,
  );

  testWidgets('Should add todo', (tester) async {
    // arrange
    when(mockTodoManager.todosSignal).thenReturn(Signal([]));
    when(mockTodoManager.sortedTodos).thenReturn([]);
    when(mockTodoManager.firstCompletedIndex).thenReturn(0);

    // act
    await tester.pumpWidget(const TestWrapper(child: AddTodoSheet()));
    await tester.enterText(find.byType(TextFormField).at(0), tTodo.title);
    await tester.pump();

    await tester.enterText(
        find.byType(TextFormField).at(1), tTodo.description!);
    await tester.pump();

    await tester.tap(find.byType(ElevatedButton));

    // assert
    verify(mockTodoManager.addTodo(any));
  });
}
