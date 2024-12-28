import 'package:flutter/material.dart';
import 'package:todo_get_it_signals/service_locator.dart';

import 'app.dart';

Future<void> main() async {
  await setupServiceLocator();
  runApp(const TodoSignalsApp());
}
