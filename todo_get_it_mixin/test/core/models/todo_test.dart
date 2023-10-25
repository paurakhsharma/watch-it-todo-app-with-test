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
