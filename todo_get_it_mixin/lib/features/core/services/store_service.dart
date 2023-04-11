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
