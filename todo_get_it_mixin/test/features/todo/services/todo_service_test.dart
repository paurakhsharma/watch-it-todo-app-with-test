import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:todo_get_it_mixin/features/core/services/store_service.dart';
import 'package:todo_get_it_mixin/features/todo/services/todo_service.dart';

import 'todo_service_test.mocks.dart';

@GenerateMocks([StoreService])
void main() {
  late MockStoreService mockStoreService;
  late TodoService todoService;

  setUp(() {
    mockStoreService = MockStoreService();
    todoService = TodoService(mockStoreService);
  });

  group('save', () {});
}
