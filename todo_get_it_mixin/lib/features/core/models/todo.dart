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
