import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/core/services/store_service.dart';
import 'features/todo/managers/todo_manager.dart';
import 'features/todo/services/todo_service.dart';

final locator = GetIt.instance;

Future<void> setupServiceLocator() async {
  await Hive.initFlutter();
  final box = await Hive.openBox('todo_signals');
  // External
  locator.registerSingleton<Box>(box);

  // services
  locator.registerSingleton<StoreService>(StoreService(locator()));
  locator.registerSingleton<TodoService>(TodoService(locator()));

  // managers
  locator.registerSingleton<TodoManager>(TodoManager(locator()));
}
