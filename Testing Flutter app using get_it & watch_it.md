# Testing Flutter app using get_it & watch_it

## Introduction

In this article we are going to lean how to architect our Flutter app state management using [get_it](https://pub.dev/packages/get_it) and [watch_it](https://pub.dev/packages/watch_it) packages.
We will also learn how to test our app using these packages.

So first thing first, let's start by creating a new Flutter project.

## Creating a new Flutter project

Open your terminal and run the following command:

```bash
flutter create get_it_test
```

## Adding dependencies

Open your `pubspec.yaml` file and add the following dependencies:

```bash
dart pub add get_it watch_it hive hive_flutter freezed_annotation json_annotation uuid mockito watch_it -d freezed -d build_runner -d json_serializable
```

## Folder structure / Architecture

```
lib
├── app.dart
├── features
│   ├── core <- Shared code
│   │   ├── models
│   │   │   ├── todo.dart
│   │   │   ├── todo.freezed.dart <- Generated file
│   │   │   └── todo.g.dart <- Generated file
│   │   └── services
│   │       └── store_service.dart
│   └── todo <- Codes related to Todo Feature
│       ├── managers
│       │   └── todo_manager.dart
│       ├── screens
│       │   └── todo_screen.dart
│       ├── services
│       │   └── todo_service.dart
│       └── widgets
│           ├── add_todo_sheet.dart
│           ├── todo_list.dart
│           └── todo_tile.dart
├── main.dart
└── service_locator.dart
```

### Creating a Todo model
Add the following code to `lib/features/core/models/todo.dart` file:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

/// Represents a [Todo]
@freezed
class Todo with _$Todo {
  const factory Todo({
    /// The id of the Todo
    required String id,

    /// The title of the Todo
    required String title,

    /// The description of the Todo
    String? description,

    /// Indicates if the Todo is completed
     @Default(false) bool isCompleted,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) =>
      _$TodoFromJson(json);
}
```

### Creating a Todo Service
Add the following code to `lib/features/todo/services/todo_service.dart` file:

### Creating Store Service
Store service is a simple service that uses [Hive](https://pub.dev/packages/hive) to store data locally.

Add the following code to `lib/features/core/services/store_service.dart` file:

```dart
import 'dart:convert';

import 'package:hive/hive.dart';

class StoreService {
  final Box box;
  StoreService(this.box);

  Future<void> save(String key, dynamic value) async {
    await box.put(key, jsonEncode(value));
  }

  dynamic get(String key) {
    final data = box.get(key);

    if (data == null) {
      return null;
    }

    return jsonDecode(data);
  }
}
```

### Creating Todo Service
Add the following code to `lib/features/todo/services/todo_service.dart` file:

```dart
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
}
```

### Creating Todo Manager
Add the following code to `lib/features/todo/managers/todo_manager.dart` file:

```dart
import 'package:flutter/foundation.dart';

import '../../core/models/todo.dart';
import '../services/todo_service.dart';

/// Manages the list of todos
class TodoManager {
  final TodoService _todoService;

  TodoManager(this._todoService) {
    _init();
  }

  /// Initialize the manager, gets all the todos from the store
  /// and sets the value of the [todosNotifier]
  Future<void> _init() async {
    todosNotifier.value = _todoService.getTodos();
  }

  final todosNotifier = ValueNotifier<List<Todo>>([]);

  List<Todo> get _todos => todosNotifier.value;

  List<Todo> get sortedTodos => _todos..sort(_sortCompletedLast);

  int get firstCompletedIndex =>
      sortedTodos.indexWhere((todo) => todo.isCompleted);

  /// Adds a new todo to the list of todos and saves it to the store
  Future<void> addTodo(Todo todo) async {
    todosNotifier.value = [..._todos, todo];
    await _todoService.saveTodos(_todos);
  }

  /// Updates a todo from the list of todos and saves it to the store
  Future<void> updateTodo(Todo todo) async {
    todosNotifier.value = _todos
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
    todosNotifier.dispose();
  }
}
```

### Creating Todo Widgets
Now let's create the widgets that we will use in our Todo feature.

#### Add Todo Sheet
Add the following code to `lib/features/todo/widgets/add_todo_sheet.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:todo_get_it_mixin/features/todo/managers/todo_manager.dart';
import 'package:todo_get_it_mixin/service_locator.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/todo.dart';

class AddTodoSheet extends StatefulWidget {
  const AddTodoSheet({super.key});

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  final formKey = GlobalKey<FormState>();

  final titleTextController = TextEditingController();
  final descriptionTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: titleTextController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionTextController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                onPressed: addTodo,
                child: const Text('Add Todo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addTodo() {
    if (formKey.currentState?.validate() ?? false) {
      final todo = Todo(
        id: const Uuid().v4(),
        title: titleTextController.text,
        description: descriptionTextController.text.isEmpty
            ? null
            : descriptionTextController.text,
      );
      locator<TodoManager>().addTodo(todo);

      Navigator.of(context).pop();
    }
  }
}
```

#### Todo List
Add the following code to `lib/features/todo/widgets/todo_list.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../service_locator.dart';
import '../managers/todo_manager.dart';
import 'todo_tile.dart';

class TodoList extends StatelessWidget with WatchItMixin {
  TodoList({super.key});

  final todoManager = locator<TodoManager>();

  @override
  Widget build(BuildContext context) {
    watchValue((TodoManager m) => m.todosNotifier);
    final todos = todoManager.sortedTodos;

    final firstCompletedIndex = todoManager.firstCompletedIndex;

    if (todos.isEmpty) {
      return const Center(
        child: Text('No todos yet!'),
      );
    }

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        final child = TodoTile(todo: todo);

        if (firstCompletedIndex == index) {
          return Column(
            children: [
              const Divider(height: 0),
              child,
            ],
          );
        }

        return child;
      },
    );
  }
}
```

#### Todo Tile
Add the following code to `lib/features/todo/widgets/todo_tile.dart` file:

```dart
import 'package:flutter/material.dart';

import '../../../service_locator.dart';
import '../../core/models/todo.dart';
import '../managers/todo_manager.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final description = todo.description;
    final isCompleted = todo.isCompleted;

    return ListTile(
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: description != null ? Text(description) : null,
      trailing: Checkbox(
        value: todo.isCompleted,
        onChanged: (value) {
          if (value == null) return;
          final newTodo = todo.copyWith(isCompleted: value);
          locator<TodoManager>().updateTodo(newTodo);
        },
      ),
    );
  }
}
```

### Creating Todo Screen
Add the following code to `lib/features/todo/screens/todo_screen.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:todo_get_it_mixin/features/todo/widgets/todo_list.dart';

import '../widgets/add_todo_sheet.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Get It Mixin'),
      ),
      body: TodoList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openAddTodoSheet(context),
        label: const Row(
          children: [
            Icon(Icons.add),
            SizedBox(width: 8),
            Text('Add Todo'),
          ],
        ),
      ),
    );
  }

  void openAddTodoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return const AddTodoSheet();
      },
    );
  }
}
```

### Creating App Widget
Add the following code to `lib/app.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:todo_get_it_mixin/features/todo/screens/todo_screen.dart';

class TodoGetItMixinApp extends StatelessWidget {
  const TodoGetItMixinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Watch It ',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.teal,
      ),
      home: const TodoScreen(),
    );
  }
}
```

### Creating Service Locator
Add the following code to `lib/service_locator.dart` file:

```dart
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/core/services/store_service.dart';
import 'features/todo/managers/todo_manager.dart';
import 'features/todo/services/todo_service.dart';

final locator = GetIt.instance;

Future<void> setupServiceLocator() async {
  await Hive.initFlutter();
  final box = await Hive.openBox('todo_get_it_mixin');
  // External
  locator.registerSingleton<Box>(box);

  // services
  locator.registerSingleton<StoreService>(StoreService(locator()));
  locator.registerSingleton<TodoService>(TodoService(locator()));

  // managers
  locator.registerSingleton<TodoManager>(TodoManager(locator()));
}
```

### Creating Main entry point for the app
Add the following code to `lib/main.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:todo_get_it_mixin/service_locator.dart';

import 'app.dart';

Future<void> main() async {
  await setupServiceLocator();
  runApp(const TodoGetItMixinApp());
}
```

Now take a long breath, we are done with the app related code, run the app and make sure that everything is working as expected.

You'll need to run `build_runner` to generate the freezed classes, run the following command:

```bash
dart run build_runner build --delete-conflicting-outputs
```



## Testing the app

Now let's test our app, we will start by testing the core code, then we will test the Todo feature.

### Testing the core code

#### Testing Todo Model
Add the following code to `test/features/core/models/todo_test.dart` file:

```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_get_it_mixin/features/core/models/todo.dart';

import '../../fixtures/fixture_reader.dart';

void main() {
  group('fromJson', () {
    test(
      'should be able to create a model from a json map',
      () async {
        // arrange
        final jsonString = fixture('todo.json');
        final map = json.decode(jsonString);
        // act
        final result = Todo.fromJson(map);
        // assert
        expect(result, isA<Todo>());
        expect(result.title, map['title']);
        expect(result.description, map['description']);
        expect(result.isCompleted, map['isCompleted']);
      },
    );
  });

  group('toJson', () {
    test(
      'should be able to export the model to json',
      () async {
        // arrange
        final jsonString = fixture('todo.json');
        final map = json.decode(jsonString);
        final episode = Todo.fromJson(map);
        // act
        final result = episode.toJson();
        // assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['title'], map['title']);
        expect(result['description'], map['description']);
        expect(result['isCompleted'], map['isCompleted']);
      },
    );
  });
}
```

#### Testing Store Service
Add the following code to `test/features/core/services/store_service_test.dart` file:

```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_get_it_mixin/features/core/services/store_service.dart';

import 'store_service_test.mocks.dart';

@GenerateMocks([Box])
void main() {
  late StoreService storeService;
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    storeService = StoreService(mockBox);
  });

  group('save', () {
    const tKey = 'key';
    const tValue = {"title": "Title"};

    test(
      'should jsonEncode the value while saving it in the store',
      () async {
        // arrange
        when(mockBox.put(any, any)).thenAnswer((_) async => {});

        // act
        await storeService.save(tKey, tValue);

        // assert
        final encodedValue = jsonEncode(tValue);
        verify(mockBox.put(tKey, encodedValue));
      },
    );

    test(
      'should throw an exception if the store throws an exception',
      () async {
        // arrange
        when(mockBox.put(any, any)).thenThrow(Exception());

        // act
        final call = storeService.save;

        // assert
        expect(() => call(tKey, tValue), throwsException);
      },
    );
  });

  group('get', () {
    const tKey = 'key';
    const tValue = '{"title": "Title"}';

    test(
      'should jsonDecode the value while getting it from the store',
      () async {
        // arrange
        when(mockBox.get(any)).thenReturn(tValue);

        // act
        final result = storeService.get(tKey);

        // assert
        final decodedValue = jsonDecode(tValue);
        expect(result, decodedValue);
      },
    );

    test(
      'should return null if the store returns null',
      () async {
        // arrange
        when(mockBox.get(any)).thenReturn(null);

        // act
        final result = storeService.get(tKey);

        // assert
        expect(result, null);
      },
    );

    test(
      'should throw an exception if the store throws an exception',
      () async {
        // arrange
        when(mockBox.get(any)).thenThrow(Exception());

        // act
        final call = storeService.get;

        // assert
        expect(() => call(tKey), throwsException);
      },
    );
  });
}
```

You'll need to run `build_runner` to generate the mock classes, run the following command:

```bash
dart run build_runner build --delete-conflicting-outputs
```

#### Testing Todo Service
Add the following code to `test/features/todo/services/todo_service_test.dart` file:

```dart
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
```

Again you'll need to run `build_runner` to generate the mock classes. This is a common theme as we use new mocks in our tests.

#### Testing Todo Manager
Add the following code to `test/features/todo/managers/todo_manager_test.dart` file:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_get_it_mixin/features/core/models/todo.dart';
import 'package:todo_get_it_mixin/features/todo/managers/todo_manager.dart';
import 'package:todo_get_it_mixin/features/todo/services/todo_service.dart';

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
      expect(todoManager.todosNotifier.value, tTodos);
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
        listEquals(todoManager.todosNotifier.value, [...tTodos, tTodo]) == true,
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
        listEquals(todoManager.todosNotifier.value, [tTodo]) == true,
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
      expect(todoManager.todosNotifier.hasListeners, false);
    });
  });
}
```

### Testing the todo widgets
Before writing tests for the widgets, we need to create a wrapper widget that will wrap our widget with the required providers.

#### Creating Test Wrapper
Add the following code to `test/features/todo/widgets/test_wrapper.dart` file:

```dart
import 'package:flutter/material.dart';

class TestWrapper extends StatelessWidget {
  final Widget child;
  const TestWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }
}
```

#### Testing Add Todo Sheet

Add the following code to `test/features/todo/widgets/add_todo_sheet_test.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_get_it_mixin/features/core/models/todo.dart';
import 'package:todo_get_it_mixin/features/todo/managers/todo_manager.dart';
import 'package:todo_get_it_mixin/features/todo/widgets/add_todo_sheet.dart';

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
    when(mockTodoManager.todosNotifier).thenReturn(ValueNotifier([]));
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
```

#### Testing Todo List
Add the following code to `test/features/todo/widgets/todo_list_test.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_get_it_mixin/features/core/models/todo.dart';
import 'package:todo_get_it_mixin/features/todo/managers/todo_manager.dart';
import 'package:todo_get_it_mixin/features/todo/widgets/todo_list.dart';
import 'package:todo_get_it_mixin/features/todo/widgets/todo_tile.dart';

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
    when(mockTodoManager.todosNotifier).thenReturn(ValueNotifier(tTodos));
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
    when(mockTodoManager.todosNotifier).thenReturn(ValueNotifier([]));
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
    when(mockTodoManager.todosNotifier).thenReturn(ValueNotifier(tTodos));
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
```

#### Testing Todo Tile
Add the following code to `test/features/todo/widgets/todo_tile_test.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_get_it_mixin/features/core/models/todo.dart';
import 'package:todo_get_it_mixin/features/todo/widgets/todo_tile.dart';

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
```

### Testing the Todo Screen
Add the following code to `test/features/todo/screens/todo_screen_test.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_get_it_mixin/features/todo/managers/todo_manager.dart';
import 'package:todo_get_it_mixin/features/todo/screens/todo_screen.dart';

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
    when(mockTodoManager.todosNotifier).thenReturn(ValueNotifier([]));
    when(mockTodoManager.sortedTodos).thenReturn([]);
    when(mockTodoManager.firstCompletedIndex).thenReturn(0);

    // act
    await tester.pumpWidget(const TestWrapper(child: TodoScreen()));
    await tester.tap(find.byType(FloatingActionButton));

    // assert
    verify(mockTodoManager.addTodoSheet());
  });

  testWidgets('Should show empty message', (tester) async {
    // arrange
    when(mockTodoManager.todosNotifier).thenReturn(ValueNotifier([]));
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

    when(mockTodoManager.todosNotifier).thenReturn(ValueNotifier([tTodo]));
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
```
