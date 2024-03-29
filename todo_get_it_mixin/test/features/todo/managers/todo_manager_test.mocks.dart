// Mocks generated by Mockito 5.4.2 from annotations
// in todo_get_it_mixin/test/features/todo/managers/todo_manager_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:todo_get_it_mixin/features/core/models/todo.dart' as _i5;
import 'package:todo_get_it_mixin/features/core/services/store_service.dart'
    as _i2;
import 'package:todo_get_it_mixin/features/todo/services/todo_service.dart'
    as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeStoreService_0 extends _i1.SmartFake implements _i2.StoreService {
  _FakeStoreService_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [TodoService].
///
/// See the documentation for Mockito's code generation for more information.
class MockTodoService extends _i1.Mock implements _i3.TodoService {
  MockTodoService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.StoreService get storeService => (super.noSuchMethod(
        Invocation.getter(#storeService),
        returnValue: _FakeStoreService_0(
          this,
          Invocation.getter(#storeService),
        ),
      ) as _i2.StoreService);
  @override
  String get todosKey => (super.noSuchMethod(
        Invocation.getter(#todosKey),
        returnValue: '',
      ) as String);
  @override
  _i4.Future<void> saveTodos(List<_i5.Todo>? todos) => (super.noSuchMethod(
        Invocation.method(
          #saveTodos,
          [todos],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  List<_i5.Todo> getTodos() => (super.noSuchMethod(
        Invocation.method(
          #getTodos,
          [],
        ),
        returnValue: <_i5.Todo>[],
      ) as List<_i5.Todo>);
}
