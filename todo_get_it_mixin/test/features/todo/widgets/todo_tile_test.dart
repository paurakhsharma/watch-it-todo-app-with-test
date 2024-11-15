import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_get_it_signals/features/core/models/todo.dart';
import 'package:todo_get_it_signals/features/todo/widgets/todo_tile.dart';

import 'test_wrapper.dart';

void main() {
  testWidgets('Should display un-completed todo', (tester) async {
    // arrange
    const tTodo = Todo(
      id: '1',
      title: 'Title',
      description: 'Description',
      isCompleted: false,
    );

    // act
    await tester.pumpWidget(const TestWrapper(child: TodoTile(todo: tTodo)));

    // assert
    // Title is displayed without decoration
    expect(find.text(tTodo.title), findsOneWidget);
    final title = tester.firstWidget<Text>(find.text(tTodo.title));
    expect(title.style?.decoration, null);

    expect(find.text(tTodo.description!), findsOneWidget);

    // Checkbox is displayed and unchecked
    expect(find.byType(Checkbox), findsOneWidget);
    final checkbox = tester.firstWidget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, false);
  });

  testWidgets('Should display completed todo', (tester) async {
    // arrange
    const tTodo = Todo(
      id: '1',
      title: 'Title',
      description: 'Description',
      isCompleted: true,
    );

    // act
    await tester.pumpWidget(const TestWrapper(child: TodoTile(todo: tTodo)));

    // assert
    // Title is displayed with decoration of lineThrough
    expect(find.text(tTodo.title), findsOneWidget);
    final title = tester.firstWidget<Text>(find.text(tTodo.title));
    expect(title.style?.decoration, TextDecoration.lineThrough);

    expect(find.text(tTodo.description!), findsOneWidget);

    // Checkbox is displayed and checked
    expect(find.byType(Checkbox), findsOneWidget);
    final checkbox = tester.firstWidget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, true);
  });
}
