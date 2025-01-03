// Mocks generated by Mockito 5.4.4 from annotations
// in todo_get_it_mixin/test/features/todo/widgets/todo_list_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:mockito/mockito.dart' as _i1;
import 'package:signals/signals.dart' as _i2;
import 'package:todo_get_it_signals/features/core/models/todo.dart' as _i4;
import 'package:todo_get_it_signals/features/todo/managers/todo_manager.dart'
    as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeSignal_0<T> extends _i1.SmartFake implements _i2.Signal<T> {
  _FakeSignal_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [TodoManager].
///
/// See the documentation for Mockito's code generation for more information.
class MockTodoManager extends _i1.Mock implements _i3.TodoManager {
  MockTodoManager() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Signal<List<_i4.Todo>> get todosSignal => (super.noSuchMethod(
        Invocation.getter(#todosSignal),
        returnValue: _FakeSignal_0<List<_i4.Todo>>(
          this,
          Invocation.getter(#todosSignal),
        ),
      ) as _i2.Signal<List<_i4.Todo>>);

  @override
  List<_i4.Todo> get sortedTodos => (super.noSuchMethod(
        Invocation.getter(#sortedTodos),
        returnValue: <_i4.Todo>[],
      ) as List<_i4.Todo>);

  @override
  int get firstCompletedIndex => (super.noSuchMethod(
        Invocation.getter(#firstCompletedIndex),
        returnValue: 0,
      ) as int);

  @override
  _i5.Future<void> addTodo(_i4.Todo? todo) => (super.noSuchMethod(
        Invocation.method(
          #addTodo,
          [todo],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> updateTodo(_i4.Todo? todo) => (super.noSuchMethod(
        Invocation.method(
          #updateTodo,
          [todo],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}
